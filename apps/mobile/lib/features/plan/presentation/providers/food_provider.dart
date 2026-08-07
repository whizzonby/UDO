import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class FoodState {
  final bool isLoading;
  final List<Map<String, dynamic>> courses;
  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> serviceItems;
  final String? error;

  const FoodState(
      {this.isLoading = false,
      this.courses = const [],
      this.summary = const {},
      this.serviceItems = const [],
      this.error});

  FoodState copyWith(
          {bool? isLoading,
          List<Map<String, dynamic>>? courses,
          Map<String, dynamic>? summary,
          List<Map<String, dynamic>>? serviceItems,
          String? error}) =>
      FoodState(
        isLoading: isLoading ?? this.isLoading,
        courses: courses ?? this.courses,
        summary: summary ?? this.summary,
        serviceItems: serviceItems ?? this.serviceItems,
        error: error,
      );
}

class FoodNotifier extends StateNotifier<FoodState> {
  final ApiClient _api;
  FoodNotifier(this._api) : super(const FoodState(isLoading: true)) {
    refresh();
  }

  /// Service items failing to load shouldn't blank the whole Food & Dining
  /// screen — the menu/dietary data still renders even if this comes back empty.
  Future<List<Map<String, dynamic>>> _fetchServiceItems() async {
    try {
      final res = await _api.get('/plan/food-service-items') as Map<String, dynamic>;
      return (res['data'] as List? ?? [])
          .whereType<Map>()
          .map((s) => Map<String, dynamic>.from(s))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _api.get('/plan/food'),
        _fetchServiceItems(),
      ]);
      final res = results[0] as Map<String, dynamic>;
      final serviceItems = results[1] as List<Map<String, dynamic>>;
      final data = Map<String, dynamic>.from(res['data'] as Map);
      state = state.copyWith(
        isLoading: false,
        courses: (data['courses'] as List? ?? [])
            .whereType<Map>()
            .map((c) => Map<String, dynamic>.from(c))
            .toList(),
        summary: Map<String, dynamic>.from(data['summary'] as Map? ?? {}),
        serviceItems: serviceItems,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Returns the created course's id on success, or null on failure.
  Future<int?> createCourse(
      {required String name, String type = 'other'}) async {
    try {
      final res = await _api.post('/plan/food/courses',
          data: {'name': name, 'type': type}) as Map<String, dynamic>;
      await refresh();
      final created = res['data'];
      return created is Map ? created['id'] as int? : null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateCourse({
    required int courseId,
    required String name,
    required String type,
  }) async {
    try {
      await _api.patch('/plan/food/courses/$courseId', data: {
        'name': name,
        'type': type,
      });
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteCourse(int courseId) async {
    try {
      await _api.delete('/plan/food/courses/$courseId');
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createOption(
      {required int courseId,
      required String name,
      String? description,
      Map<String, dynamic>? metadata,
      List<String>? dietaryTags}) async {
    try {
      await _api.post('/plan/food/courses/$courseId/options', data: {
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (metadata != null && metadata.isNotEmpty) 'metadata': metadata,
        if (dietaryTags != null && dietaryTags.isNotEmpty)
          'dietary_tags': dietaryTags,
      });
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateOption({
    required int optionId,
    required String name,
    String? description,
    bool? confirmed,
  }) async {
    try {
      await _api.patch('/plan/food/options/$optionId', data: {
        'name': name,
        'description': description,
        if (confirmed != null) 'confirmed': confirmed,
      });
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> confirmOption(int optionId) async {
    try {
      await _api
          .patch('/plan/food/options/$optionId', data: {'confirmed': true});
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteOption(int optionId) async {
    try {
      await _api.delete('/plan/food/options/$optionId');
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> selectForGuest(
      {required int optionId, required int guestId}) async {
    try {
      await _api.post('/plan/food/options/$optionId/select',
          data: {'guest_id': guestId});
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeSelection(
      {required int guestId, required int courseId}) async {
    try {
      await _api.delete('/plan/food/guests/$guestId/courses/$courseId');
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createServiceItem({
    required String eventCategory,
    String? serviceCategory,
    String? serviceType,
    String? eventDate,
    String? startTime,
    String? endTime,
    String? location,
    String? description,
    String? assignedTo,
    String? notes,
  }) async {
    try {
      await _api.post('/plan/food-service-items', data: {
        'event_category': eventCategory,
        if (serviceCategory != null && serviceCategory.isNotEmpty)
          'service_category': serviceCategory,
        if (serviceType != null && serviceType.isNotEmpty)
          'service_type': serviceType,
        if (eventDate != null && eventDate.isNotEmpty) 'event_date': eventDate,
        if (startTime != null && startTime.isNotEmpty) 'start_time': startTime,
        if (endTime != null && endTime.isNotEmpty) 'end_time': endTime,
        if (location != null && location.isNotEmpty) 'location': location,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (assignedTo != null && assignedTo.isNotEmpty)
          'assigned_to': assignedTo,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Returns an empty list on any failure (missing API key, network error) —
  /// the recipe search field is a nice-to-have and should silently fall back
  /// to plain typing rather than surface an error.
  Future<List<Map<String, dynamic>>> searchRecipes(String query) async {
    try {
      final res = await _api.get('/plan/food/recipe-search',
          query: {'query': query}) as Map<String, dynamic>;
      return (res['data'] as List? ?? [])
          .whereType<Map>()
          .map((r) => Map<String, dynamic>.from(r))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<Map<String, dynamic>?> fetchRecipeDetails(int recipeId) async {
    try {
      final res = await _api.get('/plan/food/recipes/$recipeId')
          as Map<String, dynamic>;
      final data = res['data'];
      return data is Map ? Map<String, dynamic>.from(data) : null;
    } catch (_) {
      return null;
    }
  }
}

final foodProvider = StateNotifierProvider<FoodNotifier, FoodState>((ref) {
  return FoodNotifier(ref.read(apiClientProvider));
});
