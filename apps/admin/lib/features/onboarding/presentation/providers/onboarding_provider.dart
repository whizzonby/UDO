import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/onboarding_data.dart';

part 'onboarding_provider.g.dart';

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingData build() => const OnboardingData();

  void updatePartnerNames({String? one, String? two}) {
    state = state.copyWith(
      partnerOneName: one ?? state.partnerOneName,
      partnerTwoName: two ?? state.partnerTwoName,
    );
  }

  void updateWeddingDate(DateTime? date, {bool notSet = false}) {
    state = state.copyWith(weddingDate: date, dateNotSet: notSet);
  }

  void updateGuestCount(String range) {
    state = state.copyWith(guestCountRange: range);
  }

  void updateUserRole(String role) {
    state = state.copyWith(userRole: role);
  }

  void updateVenueStatus(String status) {
    state = state.copyWith(venueStatus: status);
  }

  void updateVenue({String? name, String? city}) {
    state = state.copyWith(
      venueName: name ?? state.venueName,
      venueCity: city ?? state.venueCity,
    );
  }

  void updateBudgetRange(String range) {
    state = state.copyWith(budgetRange: range);
  }

  void updatePlanningStage(String stage) {
    state = state.copyWith(planningStage: stage);
  }

  void togglePlanningPriority(String priority) {
    final current = List<String>.from(state.planningPriorities);
    if (current.contains(priority)) {
      current.remove(priority);
    } else {
      current.add(priority);
    }
    state = state.copyWith(planningPriorities: current);
  }

  void updateGuestExperience(String value) {
    state = state.copyWith(guestExperience: value);
  }

  void updateCommunicationStyle(String style) {
    state = state.copyWith(communicationStyle: style);
  }

  void toggleInvitationChannel(String channel) {
    final current = List<String>.from(state.invitationChannels);
    if (current.contains(channel)) {
      current.remove(channel);
    } else {
      current.add(channel);
    }
    state = state.copyWith(invitationChannels: current);
  }

  void toggleWeddingVibe(String vibe) {
    final current = List<String>.from(state.weddingVibes);
    if (current.contains(vibe)) {
      current.remove(vibe);
    } else {
      current.add(vibe);
    }
    state = state.copyWith(weddingVibes: current);
  }

  void updateReferralSource(String source) {
    state = state.copyWith(referralSource: source);
  }
}

@riverpod
int onboardingStep(Ref ref) => 0;

@riverpod
class OnboardingStepNotifier extends _$OnboardingStepNotifier {
  static const int totalSteps = 14;

  @override
  int build() => 0;

  void next() {
    if (state < totalSteps - 1) state++;
  }

  void previous() {
    if (state > 0) state--;
  }

  void goTo(int step) {
    state = step.clamp(0, totalSteps - 1);
  }

  bool get isFirst => state == 0;
  bool get isLast => state == totalSteps - 1;
}
