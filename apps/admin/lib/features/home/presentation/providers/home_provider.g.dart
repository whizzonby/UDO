// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeStateHash() => r'c5f96d491bcef1d17cdd6d2fbd5056dcf5529734';

/// See also [homeState].
@ProviderFor(homeState)
final homeStateProvider = AutoDisposeProvider<HomeState>.internal(
  homeState,
  name: r'homeStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HomeStateRef = AutoDisposeProviderRef<HomeState>;
String _$weddingCountdownHash() => r'308998f51fb174908d2eaba972a97bb5b4dab707';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [weddingCountdown].
@ProviderFor(weddingCountdown)
const weddingCountdownProvider = WeddingCountdownFamily();

/// See also [weddingCountdown].
class WeddingCountdownFamily extends Family<AsyncValue<Duration>> {
  /// See also [weddingCountdown].
  const WeddingCountdownFamily();

  /// See also [weddingCountdown].
  WeddingCountdownProvider call(DateTime weddingDate) {
    return WeddingCountdownProvider(weddingDate);
  }

  @override
  WeddingCountdownProvider getProviderOverride(
    covariant WeddingCountdownProvider provider,
  ) {
    return call(provider.weddingDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'weddingCountdownProvider';
}

/// See also [weddingCountdown].
class WeddingCountdownProvider extends AutoDisposeStreamProvider<Duration> {
  /// See also [weddingCountdown].
  WeddingCountdownProvider(DateTime weddingDate)
    : this._internal(
        (ref) => weddingCountdown(ref as WeddingCountdownRef, weddingDate),
        from: weddingCountdownProvider,
        name: r'weddingCountdownProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$weddingCountdownHash,
        dependencies: WeddingCountdownFamily._dependencies,
        allTransitiveDependencies:
            WeddingCountdownFamily._allTransitiveDependencies,
        weddingDate: weddingDate,
      );

  WeddingCountdownProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.weddingDate,
  }) : super.internal();

  final DateTime weddingDate;

  @override
  Override overrideWith(
    Stream<Duration> Function(WeddingCountdownRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeddingCountdownProvider._internal(
        (ref) => create(ref as WeddingCountdownRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        weddingDate: weddingDate,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Duration> createElement() {
    return _WeddingCountdownProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeddingCountdownProvider &&
        other.weddingDate == weddingDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, weddingDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WeddingCountdownRef on AutoDisposeStreamProviderRef<Duration> {
  /// The parameter `weddingDate` of this provider.
  DateTime get weddingDate;
}

class _WeddingCountdownProviderElement
    extends AutoDisposeStreamProviderElement<Duration>
    with WeddingCountdownRef {
  _WeddingCountdownProviderElement(super.provider);

  @override
  DateTime get weddingDate => (origin as WeddingCountdownProvider).weddingDate;
}

String _$homeNotifierHash() => r'036622c889db00853787e7f883ef0260d4f9f9db';

/// See also [HomeNotifier].
@ProviderFor(HomeNotifier)
final homeNotifierProvider =
    AutoDisposeNotifierProvider<HomeNotifier, HomeState>.internal(
      HomeNotifier.new,
      name: r'homeNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$homeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HomeNotifier = AutoDisposeNotifier<HomeState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
