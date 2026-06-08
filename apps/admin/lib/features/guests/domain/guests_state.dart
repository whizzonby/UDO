import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/models/guest_model.dart';

part 'guests_state.freezed.dart';

@freezed
abstract class GuestsListState with _$GuestsListState {
  const factory GuestsListState.loading() = _GuestsListLoading;
  const factory GuestsListState.loaded({
    required List<GuestModel> guests,
    required int total,
    @Default('') String query,
    @Default('all') String statusFilter,
  }) = _GuestsListLoaded;
  const factory GuestsListState.error(String message) = _GuestsListError;
}

@freezed
abstract class GuestsOverviewState with _$GuestsOverviewState {
  const factory GuestsOverviewState.loading() = _GuestsOverviewLoading;
  const factory GuestsOverviewState.loaded(GuestsOverview overview) =
      _GuestsOverviewLoaded;
  const factory GuestsOverviewState.error(String message) =
      _GuestsOverviewError;
}

@freezed
abstract class GuestDetailState with _$GuestDetailState {
  const factory GuestDetailState.idle() = _GuestDetailIdle;
  const factory GuestDetailState.loading() = _GuestDetailLoading;
  const factory GuestDetailState.loaded(GuestModel guest) = _GuestDetailLoaded;
  const factory GuestDetailState.error(String message) = _GuestDetailError;
}
