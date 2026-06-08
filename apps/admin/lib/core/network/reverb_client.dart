import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../features/live/data/models/live_status_model.dart';

// Configured via --dart-define at build time.
const String _reverbHost   = String.fromEnvironment('REVERB_HOST',    defaultValue: 'localhost');
const String _reverbPort   = String.fromEnvironment('REVERB_PORT',    defaultValue: '8080');
const String _reverbKey    = String.fromEnvironment('REVERB_APP_KEY', defaultValue: 'udo-key');
const bool   _reverbTls    = bool.fromEnvironment('REVERB_TLS',       defaultValue: false);

/// Speaks the Pusher wire protocol to connect to a Laravel Reverb WebSocket
/// server and stream real-time [LiveActivity] events for a specific wedding.
class ReverbClient {
  const ReverbClient(this._dio);
  final Dio _dio;

  Stream<LiveActivity> activityStream(String weddingId) async* {
    final scheme   = _reverbTls ? 'wss' : 'ws';
    final wsUri    = Uri.parse(
      '$scheme://$_reverbHost:$_reverbPort/app/$_reverbKey'
      '?protocol=7&client=dart&version=1.0.0&flash=false',
    );
    final ws      = WebSocketChannel.connect(wsUri);
    final channel = 'private-wedding.$weddingId';

    try {
      await for (final raw in ws.stream) {
        if (raw is! String) continue;

        final msg   = jsonDecode(raw) as Map<String, dynamic>;
        final event = msg['event'] as String? ?? '';

        if (event == 'pusher:connection_established') {
          final connData = jsonDecode(msg['data'] as String) as Map<String, dynamic>;
          final socketId = connData['socket_id'] as String;

          final auth = await _authChannel(socketId, channel);
          if (auth == null) return; // Sanctum auth failed

          ws.sink.add(jsonEncode({
            'event': 'pusher:subscribe',
            'data': {'channel': channel, 'auth': auth},
          }));
        } else if (event == 'pusher:ping') {
          ws.sink.add(jsonEncode({'event': 'pusher:pong', 'data': {}}));
        } else if (event == 'activity.recorded') {
          final rawData = msg['data'];
          final payload = rawData is String
              ? jsonDecode(rawData) as Map<String, dynamic>
              : rawData as Map<String, dynamic>;
          yield LiveActivity.fromJson(payload);
        }
      }
    } finally {
      await ws.sink.close();
    }
  }

  // POST /broadcasting/auth — endpoint lives at server root, not under /api/.
  Future<String?> _authChannel(String socketId, String channelName) async {
    try {
      final serverRoot = _dio.options.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
      final resp = await _dio.post<Map<String, dynamic>>(
        '$serverRoot/broadcasting/auth',
        data: 'socket_id=${Uri.encodeQueryComponent(socketId)}'
            '&channel_name=${Uri.encodeQueryComponent(channelName)}',
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );
      return resp.data?['auth'] as String?;
    } catch (_) {
      return null;
    }
  }
}
