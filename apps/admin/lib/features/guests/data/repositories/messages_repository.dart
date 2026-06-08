import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../models/guest_message_model.dart';

part 'messages_repository.g.dart';

@riverpod
MessagesRepository messagesRepository(Ref ref) =>
    ApiMessagesRepository(ref.watch(apiClientProvider));

abstract class MessagesRepository {
  Future<List<GuestMessageModel>> getMessages();
  Future<GuestMessageModel> sendMessage({
    String? subject,
    required String body,
    required String channel,
    required Map<String, dynamic> recipientFilter,
  });
  Future<void> deleteMessage(String id);
}

class ApiMessagesRepository implements MessagesRepository {
  const ApiMessagesRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<GuestMessageModel>> getMessages() async {
    final resp = await _dio.get('/messages/');
    final raw = (resp.data as Map<String, dynamic>)['messages'] as List<dynamic>;
    return raw
        .map((m) => GuestMessageModel.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GuestMessageModel> sendMessage({
    String? subject,
    required String body,
    required String channel,
    required Map<String, dynamic> recipientFilter,
  }) async {
    final resp = await _dio.post('/messages/', data: {
      if (subject != null && subject.isNotEmpty) 'subject': subject,
      'body': body,
      'channel': channel,
      'recipient_filter': recipientFilter,
    });
    return GuestMessageModel.fromJson(
        (resp.data as Map<String, dynamic>)['message'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteMessage(String id) async {
    await _dio.delete('/messages/$id');
  }
}
