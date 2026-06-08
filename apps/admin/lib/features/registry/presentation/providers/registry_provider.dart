import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/registry_models.dart';
import '../../data/repositories/registry_repository.dart';

part 'registry_provider.g.dart';

enum RegistryLoadStatus { loading, loaded, error }

class RegistryState {
  const RegistryState({
    this.loadStatus = RegistryLoadStatus.loading,
    this.items = const [],
    this.fund,
    this.summary = const RegistrySummary(),
    this.error,
    this.busyIds = const {},
  });

  final RegistryLoadStatus loadStatus;
  final List<RegistryItem> items;
  final RegistryCashFund? fund;
  final RegistrySummary summary;
  final String? error;
  final Set<String> busyIds;

  List<RegistryItem> get unclaimed =>
      items.where((i) => !i.isClaimed).toList();
  List<RegistryItem> get claimed =>
      items.where((i) => i.isClaimed).toList();
  List<RegistryItem> get thankYouPending =>
      items.where((i) => i.isClaimed && !i.thankYouSent).toList();
  List<RegistryItem> get thanked =>
      items.where((i) => i.isClaimed && i.thankYouSent).toList();

  RegistryState copyWith({
    RegistryLoadStatus? loadStatus,
    List<RegistryItem>? items,
    RegistryCashFund? fund,
    RegistrySummary? summary,
    String? error,
    Set<String>? busyIds,
  }) =>
      RegistryState(
        loadStatus: loadStatus ?? this.loadStatus,
        items: items ?? this.items,
        fund: fund ?? this.fund,
        summary: summary ?? this.summary,
        error: error ?? this.error,
        busyIds: busyIds ?? this.busyIds,
      );
}

@riverpod
class RegistryNotifier extends _$RegistryNotifier {
  @override
  RegistryState build() {
    _load();
    return const RegistryState();
  }

  Future<void> _load() async {
    try {
      final data = await ref.read(registryRepositoryProvider).getAll();
      state = RegistryState(
        loadStatus: RegistryLoadStatus.loaded,
        items: data.items,
        fund: data.fund,
        summary: data.summary,
      );
    } catch (e) {
      state = RegistryState(
          loadStatus: RegistryLoadStatus.error, error: e.toString());
    }
  }

  Future<void> refresh() => _load();

  Future<void> addItem(Map<String, dynamic> data) async {
    final item = await ref.read(registryRepositoryProvider).createItem(data);
    state = state.copyWith(items: [...state.items, item]);
    _refreshSummary();
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    final updated =
        await ref.read(registryRepositoryProvider).updateItem(id, data);
    state = state.copyWith(
        items: state.items.map((i) => i.id == id ? updated : i).toList());
  }

  Future<void> deleteItem(String id) async {
    await ref.read(registryRepositoryProvider).deleteItem(id);
    state = state.copyWith(items: state.items.where((i) => i.id != id).toList());
    _refreshSummary();
  }

  Future<void> claimItem(String id, {String? claimedByName}) async {
    state = state.copyWith(busyIds: {...state.busyIds, id});
    try {
      final updated = await ref
          .read(registryRepositoryProvider)
          .claimItem(id, claimedByName: claimedByName);
      state = state.copyWith(
        items: state.items.map((i) => i.id == id ? updated : i).toList(),
        busyIds: state.busyIds.difference({id}),
      );
      _refreshSummary();
    } catch (_) {
      state = state.copyWith(busyIds: state.busyIds.difference({id}));
    }
  }

  Future<void> unclaimItem(String id) async {
    state = state.copyWith(busyIds: {...state.busyIds, id});
    try {
      final updated =
          await ref.read(registryRepositoryProvider).unclaimItem(id);
      state = state.copyWith(
        items: state.items.map((i) => i.id == id ? updated : i).toList(),
        busyIds: state.busyIds.difference({id}),
      );
      _refreshSummary();
    } catch (_) {
      state = state.copyWith(busyIds: state.busyIds.difference({id}));
    }
  }

  Future<void> markThanked(String id) async {
    state = state.copyWith(busyIds: {...state.busyIds, id});
    try {
      final updated =
          await ref.read(registryRepositoryProvider).markThanked(id);
      state = state.copyWith(
        items: state.items.map((i) => i.id == id ? updated : i).toList(),
        busyIds: state.busyIds.difference({id}),
      );
      _refreshSummary();
    } catch (_) {
      state = state.copyWith(busyIds: state.busyIds.difference({id}));
    }
  }

  Future<void> updateFund(Map<String, dynamic> data) async {
    final fund =
        await ref.read(registryRepositoryProvider).updateFund(data);
    state = state.copyWith(fund: fund);
  }

  void _refreshSummary() {
    final claimed = state.items.where((i) => i.isClaimed).toList();
    state = state.copyWith(
      summary: RegistrySummary(
        totalItems: state.items.length,
        claimed: claimed.length,
        unclaimed: state.items.where((i) => !i.isClaimed).length,
        thankYousPending:
            claimed.where((i) => !i.thankYouSent).length,
        totalValue: state.items.fold(0.0, (s, i) => s + (i.price ?? 0)),
        claimedValue: claimed.fold(0.0, (s, i) => s + (i.price ?? 0)),
      ),
    );
  }
}
