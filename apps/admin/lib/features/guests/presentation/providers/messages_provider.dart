import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/guest_message_model.dart';
import '../../data/repositories/messages_repository.dart';

part 'messages_provider.g.dart';

enum MessagesStatus { loading, loaded, sending, error }

class MessagesState {
  const MessagesState({
    this.status = MessagesStatus.loading,
    this.messages = const [],
    this.error,
  });

  final MessagesStatus status;
  final List<GuestMessageModel> messages;
  final String? error;

  MessagesState copyWith({
    MessagesStatus? status,
    List<GuestMessageModel>? messages,
    String? error,
  }) =>
      MessagesState(
        status: status ?? this.status,
        messages: messages ?? this.messages,
        error: error ?? this.error,
      );
}

@riverpod
class MessagesNotifier extends _$MessagesNotifier {
  @override
  MessagesState build() {
    _load();
    return const MessagesState();
  }

  Future<void> _load() async {
    try {
      final msgs = await ref.read(messagesRepositoryProvider).getMessages();
      state = MessagesState(status: MessagesStatus.loaded, messages: msgs);
    } catch (e) {
      state = MessagesState(status: MessagesStatus.error, error: e.toString());
    }
  }

  Future<void> refresh() => _load();

  Future<bool> send({
    String? subject,
    required String body,
    required String channel,
    required Map<String, dynamic> recipientFilter,
  }) async {
    state = state.copyWith(status: MessagesStatus.sending);
    try {
      final msg = await ref.read(messagesRepositoryProvider).sendMessage(
            subject: subject,
            body: body,
            channel: channel,
            recipientFilter: recipientFilter,
          );
      state = state.copyWith(
        status: MessagesStatus.loaded,
        messages: [msg, ...state.messages],
      );
      return true;
    } catch (e) {
      state = state.copyWith(
          status: MessagesStatus.loaded, error: e.toString());
      return false;
    }
  }

  Future<void> delete(String id) async {
    try {
      await ref.read(messagesRepositoryProvider).deleteMessage(id);
      state = state.copyWith(
        messages: state.messages.where((m) => m.id != id).toList(),
      );
    } catch (_) {}
  }
}
