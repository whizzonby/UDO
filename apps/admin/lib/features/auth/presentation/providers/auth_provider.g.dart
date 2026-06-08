// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStateHash() => r'1843695cda6a43eb147ce7e899bb75c9556e445a';

/// See also [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeProvider<AuthState>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateRef = AutoDisposeProviderRef<AuthState>;
String _$authStateNotifierHash() => r'b8524a93e4acf39d12479bb727810cf51ebca700';

/// See also [AuthStateNotifier].
@ProviderFor(AuthStateNotifier)
final authStateNotifierProvider =
    AutoDisposeNotifierProvider<AuthStateNotifier, AuthState>.internal(
      AuthStateNotifier.new,
      name: r'authStateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authStateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthStateNotifier = AutoDisposeNotifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
