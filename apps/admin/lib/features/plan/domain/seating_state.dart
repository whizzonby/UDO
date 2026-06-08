import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/models/seating_models.dart';

part 'seating_state.freezed.dart';

@freezed
sealed class SeatingState with _$SeatingState {
  const factory SeatingState.loading() = SeatingLoading;
  const factory SeatingState.loaded(SeatingData data) = SeatingLoaded;
  const factory SeatingState.error(String message) = SeatingError;
}
