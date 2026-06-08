import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../models/live_status_model.dart';

part 'live_repository.g.dart';

@riverpod
LiveRepository liveRepository(Ref ref) =>
    ApiLiveRepository(ref.watch(apiClientProvider));

abstract class LiveRepository {
  Future<LiveStatus> getStatus();
  Future<void> activate();
  Future<void> deactivate();
  Future<void> checkInGuest(String guestId);
}

class ApiLiveRepository implements LiveRepository {
  const ApiLiveRepository(this._dio);
  final Dio _dio;

  @override
  Future<LiveStatus> getStatus() async {
    final resp = await _dio.get('/live/status');
    return LiveStatus.fromJson(resp.data as Map<String, dynamic>);
  }

  @override
  Future<void> activate() => _dio.post('/live/activate');

  @override
  Future<void> deactivate() => _dio.post('/live/deactivate');

  @override
  Future<void> checkInGuest(String guestId) =>
      _dio.post('/guests/$guestId/check-in');
}
