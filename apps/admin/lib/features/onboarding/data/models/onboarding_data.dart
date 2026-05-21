import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_data.freezed.dart';
part 'onboarding_data.g.dart';

@freezed
abstract class OnboardingData with _$OnboardingData {
  const factory OnboardingData({
    // Step 2 — Couple names
    String? partnerOneName,
    String? partnerTwoName,

    // Step 3 — Wedding date
    DateTime? weddingDate,
    @Default(false) bool dateNotSet,

    // Step 4 — Guest count estimate
    String? guestCountRange,

    // Step 5 — Role
    String? userRole,

    // Step 6 — Venue status
    String? venueStatus,

    // Step 7 — Venue name (if booked)
    String? venueName,
    String? venueCity,

    // Step 8 — Budget range
    String? budgetRange,

    // Step 9 — Planning stage
    String? planningStage,

    // Step 10 — Planning priorities
    @Default([]) List<String> planningPriorities,

    // Step 11 — Guest experience preference
    String? guestExperience,

    // Step 12 — Communication style
    String? communicationStyle,

    // Step 13 — Invitations sent via
    @Default([]) List<String> invitationChannels,

    // Step 14 — Aesthetic / vibe
    @Default([]) List<String> weddingVibes,

    // Step 15 — How they found us
    String? referralSource,
  }) = _OnboardingData;

  factory OnboardingData.fromJson(Map<String, dynamic> json) =>
      _$OnboardingDataFromJson(json);
}
