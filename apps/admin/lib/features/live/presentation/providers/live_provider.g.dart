// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentWeddingIdHash() => r'5290b3232fce91e621f59f405a345e189666cf0c';

/// See also [currentWeddingId].
@ProviderFor(currentWeddingId)
final currentWeddingIdProvider = AutoDisposeProvider<String?>.internal(
  currentWeddingId,
  name: r'currentWeddingIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentWeddingIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentWeddingIdRef = AutoDisposeProviderRef<String?>;
String _$liveActivitiesHash() => r'a6ce527cc644f75950bd1d091fb86099da061145';

/// See also [liveActivities].
@ProviderFor(liveActivities)
final liveActivitiesProvider =
    AutoDisposeStreamProvider<List<LiveActivity>>.internal(
      liveActivities,
      name: r'liveActivitiesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$liveActivitiesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LiveActivitiesRef = AutoDisposeStreamProviderRef<List<LiveActivity>>;
String _$liveNotifierHash() => r'f1fa5bafa1cebbc0618a3efc216b183d8101b933';

/// See also [LiveNotifier].
@ProviderFor(LiveNotifier)
final liveNotifierProvider =
    AutoDisposeNotifierProvider<LiveNotifier, LiveState>.internal(
      LiveNotifier.new,
      name: r'liveNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$liveNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LiveNotifier = AutoDisposeNotifier<LiveState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
