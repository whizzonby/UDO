import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/models/plan_models.dart';

part 'plan_state.freezed.dart';

@freezed
sealed class PlanState with _$PlanState {
  const factory PlanState.loading() = _Loading;
  const factory PlanState.loaded(PlanData data) = _Loaded;
  const factory PlanState.error(String message) = _Error;
}
