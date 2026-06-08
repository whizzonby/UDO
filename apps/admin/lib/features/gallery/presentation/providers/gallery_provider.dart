import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/gallery_models.dart';
import '../../data/repositories/gallery_repository.dart';

part 'gallery_provider.g.dart';

enum GalleryLoadStatus { loading, loaded, error }

class GalleryState {
  const GalleryState({
    this.loadStatus = GalleryLoadStatus.loading,
    this.items = const [],
    this.summary = const GallerySummary(),
    this.error,
    this.busyIds = const {},
  });

  final GalleryLoadStatus loadStatus;
  final List<GalleryItem> items;
  final GallerySummary summary;
  final String? error;
  final Set<String> busyIds;

  List<GalleryItem> get inspirationItems =>
      items.where((i) => i.type == 'inspiration').toList();

  List<GalleryItem> get memoryItems =>
      items.where((i) => i.type == 'memory').toList();

  List<GalleryItem> get featuredItems =>
      items.where((i) => i.isFeatured).toList();

  GalleryState copyWith({
    GalleryLoadStatus? loadStatus,
    List<GalleryItem>? items,
    GallerySummary? summary,
    String? error,
    Set<String>? busyIds,
  }) =>
      GalleryState(
        loadStatus: loadStatus ?? this.loadStatus,
        items: items ?? this.items,
        summary: summary ?? this.summary,
        error: error ?? this.error,
        busyIds: busyIds ?? this.busyIds,
      );
}

@riverpod
class GalleryNotifier extends _$GalleryNotifier {
  @override
  GalleryState build() {
    _load();
    return const GalleryState();
  }

  Future<void> _load() async {
    try {
      final data = await ref.read(galleryRepositoryProvider).getAll();
      state = GalleryState(
        loadStatus: GalleryLoadStatus.loaded,
        items: data.items,
        summary: data.summary,
      );
    } catch (e) {
      state =
          GalleryState(loadStatus: GalleryLoadStatus.error, error: e.toString());
    }
  }

  Future<void> refresh() => _load();

  Future<void> addItem(Map<String, dynamic> data) async {
    final item = await ref.read(galleryRepositoryProvider).addItem(data);
    state = state.copyWith(items: [...state.items, item]);
    _refreshSummary();
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    final updated =
        await ref.read(galleryRepositoryProvider).updateItem(id, data);
    state = state.copyWith(
        items: state.items.map((i) => i.id == id ? updated : i).toList());
  }

  Future<void> deleteItem(String id) async {
    await ref.read(galleryRepositoryProvider).deleteItem(id);
    state =
        state.copyWith(items: state.items.where((i) => i.id != id).toList());
    _refreshSummary();
  }

  Future<void> featureItem(String id) async {
    state = state.copyWith(busyIds: {...state.busyIds, id});
    try {
      final updated =
          await ref.read(galleryRepositoryProvider).featureItem(id);
      state = state.copyWith(
        items: state.items.map((i) => i.id == id ? updated : i).toList(),
        busyIds: state.busyIds.difference({id}),
      );
      _refreshSummary();
    } catch (_) {
      state = state.copyWith(busyIds: state.busyIds.difference({id}));
    }
  }

  void _refreshSummary() {
    final inspiration = state.items.where((i) => i.type == 'inspiration');
    final memories = state.items.where((i) => i.type == 'memory');
    final categories = inspiration
        .map((i) => i.category)
        .whereType<String>()
        .toSet()
        .toList();

    state = state.copyWith(
      summary: GallerySummary(
        total: state.items.length,
        inspiration: inspiration.length,
        memories: memories.length,
        featured: state.items.where((i) => i.isFeatured).length,
        categories: categories,
      ),
    );
  }
}
