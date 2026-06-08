import 'package:freezed_annotation/freezed_annotation.dart';

part 'guest_message_model.freezed.dart';
part 'guest_message_model.g.dart';

@freezed
abstract class GuestMessageModel with _$GuestMessageModel {
  const factory GuestMessageModel({
    required String id,
    String? subject,
    required String body,
    @Default('in_app') String channel,
    @Default({}) Map<String, dynamic> recipientFilter,
    @Default(0) int recipientCount,
    @Default('sent') String status,
    String? sentAt,
    String? createdAt,
  }) = _GuestMessageModel;

  factory GuestMessageModel.fromJson(Map<String, dynamic> json) =>
      _$GuestMessageModelFromJson(json);
}
