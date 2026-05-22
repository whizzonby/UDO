import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/models/home_stats_model.dart';

part 'home_state.freezed.dart';

@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState.loading() = _Loading;
  const factory HomeState.loaded(HomeStats stats) = _Loaded;
  const factory HomeState.error(String message) = _Error;
}
