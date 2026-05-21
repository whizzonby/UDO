import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/models/user_model.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.loading() = _Loading;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.onboarding() = _Onboarding;
  const factory AuthState.authenticated(UserModel user) = _Authenticated;
}
