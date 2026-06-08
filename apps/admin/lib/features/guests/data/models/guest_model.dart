import 'package:freezed_annotation/freezed_annotation.dart';

part 'guest_model.freezed.dart';
part 'guest_model.g.dart';

@freezed
abstract class GuestModel with _$GuestModel {
  const factory GuestModel({
    required String id,
    required String firstName,
    required String lastName,
    required String fullName,
    String? email,
    String? phone,
    @Default('pending') String rsvpStatus,
    String? group,
    String? relationship,
    @Default('adult') String ageGroup,
    @Default(false) bool isVip,
    String? dietaryRequirements,
    @Default(false) bool plusOneAllowed,
    String? plusOneName,
    String? invitationSentAt,
    String? rsvpRespondedAt,
    String? checkedInAt,
    @Default(false) bool needsTransport,
    @Default(false) bool needsAccommodation,
    String? token,
    String? notes,
    String? address,
    String? language,
  }) = _GuestModel;

  factory GuestModel.fromJson(Map<String, dynamic> json) =>
      _$GuestModelFromJson(json);
}

@freezed
abstract class GuestsOverview with _$GuestsOverview {
  const factory GuestsOverview({
    @Default(0) int totalGuests,
    @Default(0) int attending,
    @Default(0) int declined,
    @Default(0) int pending,
    @Default(0) int responseRate,
    @Default(GuestQuickStats()) GuestQuickStats quickStats,
    @Default({}) Map<String, dynamic> groups,
    @Default(0) int vipCount,
    @Default(0) int invitedCount,
    @Default(0) int notInvitedYet,
  }) = _GuestsOverview;

  factory GuestsOverview.fromJson(Map<String, dynamic> json) =>
      _$GuestsOverviewFromJson(json);
}

@freezed
abstract class GuestQuickStats with _$GuestQuickStats {
  const factory GuestQuickStats({
    @Default(0) int vegetarian,
    @Default(0) int allergies,
    @Default(0) int kids,
    @Default(0) int plusOnes,
  }) = _GuestQuickStats;

  factory GuestQuickStats.fromJson(Map<String, dynamic> json) =>
      _$GuestQuickStatsFromJson(json);
}
