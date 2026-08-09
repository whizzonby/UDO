import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

List<Map<String, dynamic>> _extractList(dynamic res) {
  if (res is Map && res['data'] is List)
    return (res['data'] as List).cast<Map<String, dynamic>>();
  return [];
}

Map<String, dynamic>? _extractItem(dynamic res) {
  if (res is Map && res['data'] is Map)
    return Map<String, dynamic>.from(res['data'] as Map);
  return null;
}

// ── REMINDERS ────────────────────────────────────────────────────────────────────

class RemindersState {
  final bool isLoading;
  final bool isSaving;
  final List<Map<String, dynamic>> reminders;
  final String? error;

  const RemindersState(
      {this.isLoading = false,
      this.isSaving = false,
      this.reminders = const [],
      this.error});

  RemindersState copyWith(
          {bool? isLoading,
          bool? isSaving,
          List<Map<String, dynamic>>? reminders,
          String? error}) =>
      RemindersState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        reminders: reminders ?? this.reminders,
        error: error,
      );
}

class RemindersNotifier extends StateNotifier<RemindersState> {
  final ApiClient _api;
  RemindersNotifier(this._api) : super(const RemindersState(isLoading: true)) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.get('/plan/reminders');
      state = state.copyWith(isLoading: false, reminders: _extractList(res));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshAutoReminders() async {
    try {
      final res = await _api.post('/plan/reminders/refresh');
      state = state.copyWith(reminders: _extractList(res));
    } catch (_) {
      // Auto-refresh is best-effort — manual reminders already loaded stay visible.
    }
  }

  Future<bool> create(
      {required String title,
      String? description,
      DateTime? dueDate,
      String priority = 'medium'}) async {
    state = state.copyWith(isSaving: true);
    try {
      final res = await _api.post('/plan/reminders', data: {
        'title': title,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (dueDate != null)
          'due_date': dueDate.toIso8601String().split('T').first,
        'priority': priority,
      });
      final created = _extractItem(res);
      if (created != null)
        state = state.copyWith(reminders: [...state.reminders, created]);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> setStatus(int id, String status) async {
    final idx = state.reminders.indexWhere((r) => r['id'] == id);
    if (idx == -1) return false;
    final original = state.reminders[idx];
    final optimistic = [...state.reminders];
    optimistic[idx] = {...original, 'status': status};
    state = state.copyWith(reminders: optimistic);
    try {
      await _api.patch('/plan/reminders/$id', data: {'status': status});
      return true;
    } catch (_) {
      final reverted = [...state.reminders];
      reverted[idx] = original;
      state = state.copyWith(reminders: reverted);
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _api.delete('/plan/reminders/$id');
      state = state.copyWith(
          reminders: state.reminders.where((r) => r['id'] != id).toList());
      return true;
    } catch (_) {
      return false;
    }
  }
}

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, RemindersState>((ref) {
  return RemindersNotifier(ref.read(apiClientProvider));
});

// ── INSURANCE ────────────────────────────────────────────────────────────────────

class InsuranceState {
  final bool isLoading;
  final bool isSaving;
  final List<Map<String, dynamic>> policies;
  final List<Map<String, dynamic>> documents;
  final String? error;

  const InsuranceState(
      {this.isLoading = false,
      this.isSaving = false,
      this.policies = const [],
      this.documents = const [],
      this.error});

  InsuranceState copyWith(
          {bool? isLoading,
          bool? isSaving,
          List<Map<String, dynamic>>? policies,
          List<Map<String, dynamic>>? documents,
          String? error}) =>
      InsuranceState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        policies: policies ?? this.policies,
        documents: documents ?? this.documents,
        error: error,
      );
}

class InsuranceNotifier extends StateNotifier<InsuranceState> {
  final ApiClient _api;
  InsuranceNotifier(this._api) : super(const InsuranceState(isLoading: true)) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _api.get('/plan/insurance'),
        _api.get('/plan/insurance/documents'),
      ]);
      state = state.copyWith(
          isLoading: false,
          policies: _extractList(results[0]),
          documents: _extractList(results[1]));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> uploadDocument(List<int> bytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });
      final res = await _api.post('/plan/insurance/documents', data: formData);
      final created = _extractItem(res);
      if (created != null)
        state = state.copyWith(documents: [created, ...state.documents]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteDocument(int id) async {
    try {
      await _api.delete('/plan/insurance/documents/$id');
      state = state.copyWith(
          documents: state.documents.where((d) => d['id'] != id).toList());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    state = state.copyWith(isSaving: true);
    try {
      final res = await _api.post('/plan/insurance', data: data);
      final created = _extractItem(res);
      if (created != null)
        state = state.copyWith(policies: [...state.policies, created]);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> update(int id, Map<String, dynamic> data) async {
    try {
      final res = await _api.patch('/plan/insurance/$id', data: data);
      final updated = _extractItem(res);
      if (updated != null) {
        state = state.copyWith(
            policies: state.policies
                .map((p) => p['id'] == id ? updated : p)
                .toList());
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _api.delete('/plan/insurance/$id');
      state = state.copyWith(
          policies: state.policies.where((p) => p['id'] != id).toList());
      return true;
    } catch (_) {
      return false;
    }
  }
}

final insuranceProvider =
    StateNotifierProvider<InsuranceNotifier, InsuranceState>((ref) {
  return InsuranceNotifier(ref.read(apiClientProvider));
});

// ── WEDDING WEEKEND ────────────────────────────────────────────────────────────────

class WeddingWeekendState {
  final bool isLoading;
  final bool isSaving;
  final List<Map<String, dynamic>> events;
  final String? error;

  const WeddingWeekendState(
      {this.isLoading = false,
      this.isSaving = false,
      this.events = const [],
      this.error});

  WeddingWeekendState copyWith(
          {bool? isLoading,
          bool? isSaving,
          List<Map<String, dynamic>>? events,
          String? error}) =>
      WeddingWeekendState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        events: events ?? this.events,
        error: error,
      );
}

class WeddingWeekendNotifier extends StateNotifier<WeddingWeekendState> {
  final ApiClient _api;
  WeddingWeekendNotifier(this._api)
      : super(const WeddingWeekendState(isLoading: true)) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.get('/plan/wedding-weekend');
      state = state.copyWith(isLoading: false, events: _extractList(res));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    state = state.copyWith(isSaving: true);
    try {
      final res = await _api.post('/plan/wedding-weekend', data: data);
      final created = _extractItem(res);
      if (created != null)
        state = state.copyWith(events: [...state.events, created]);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> update(int id, Map<String, dynamic> data) async {
    try {
      final res = await _api.patch('/plan/wedding-weekend/$id', data: data);
      final updated = _extractItem(res);
      if (updated != null) {
        state = state.copyWith(
            events:
                state.events.map((e) => e['id'] == id ? updated : e).toList());
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _api.delete('/plan/wedding-weekend/$id');
      state = state.copyWith(
          events: state.events.where((e) => e['id'] != id).toList());
      return true;
    } catch (_) {
      return false;
    }
  }
}

final weddingWeekendProvider =
    StateNotifierProvider<WeddingWeekendNotifier, WeddingWeekendState>((ref) {
  return WeddingWeekendNotifier(ref.read(apiClientProvider));
});

// ── HONEYMOON ────────────────────────────────────────────────────────────────────

class HoneymoonState {
  final bool isLoading;
  final bool isSaving;
  final Map<String, dynamic>? trip;
  final List<Map<String, dynamic>> checklistTasks;
  final List<Map<String, dynamic>> budgetItems;
  final String? error;

  const HoneymoonState({
    this.isLoading = false,
    this.isSaving = false,
    this.trip,
    this.checklistTasks = const [],
    this.budgetItems = const [],
    this.error,
  });

  List<Map<String, dynamic>> get items {
    final raw = trip?['items'];
    return raw is List ? raw.cast<Map<String, dynamic>>() : const [];
  }

  List<Map<String, dynamic>> get travelers {
    final raw = trip?['travelers'];
    return raw is List ? raw.cast<Map<String, dynamic>>() : const [];
  }

  HoneymoonState copyWith({
    bool? isLoading,
    bool? isSaving,
    Map<String, dynamic>? trip,
    List<Map<String, dynamic>>? checklistTasks,
    List<Map<String, dynamic>>? budgetItems,
    String? error,
  }) =>
      HoneymoonState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        trip: trip ?? this.trip,
        checklistTasks: checklistTasks ?? this.checklistTasks,
        budgetItems: budgetItems ?? this.budgetItems,
        error: error,
      );
}

class HoneymoonNotifier extends StateNotifier<HoneymoonState> {
  final ApiClient _api;
  HoneymoonNotifier(this._api) : super(const HoneymoonState(isLoading: true)) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _api.get('/plan/honeymoon'),
        _api.get('/plan/tasks'),
        _api.get('/plan/budget'),
      ]);
      final budgetItems = _extractList(results[2])
          .where((b) => b['category'] == 'Honeymoon')
          .toList();
      final checklistTasks = _extractList(results[1])
          .where((task) =>
              (task['category'] as String? ?? '').toLowerCase() == 'honeymoon')
          .toList();
      state = state.copyWith(
        isLoading: false,
        trip: _extractItem(results[0]),
        checklistTasks: checklistTasks,
        budgetItems: budgetItems,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateTrip(Map<String, dynamic> data) async {
    state = state.copyWith(isSaving: true);
    try {
      final res = await _api.patch('/plan/honeymoon', data: data);
      state = state.copyWith(isSaving: false, trip: _extractItem(res));
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> uploadCoverPhoto(List<int> bytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'photo': MultipartFile.fromBytes(bytes, filename: filename),
      });
      final res =
          await _api.post('/plan/honeymoon/cover-photo', data: formData);
      state = state.copyWith(trip: _extractItem(res));
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Items ──────────────────────────────────────────────────────────────────

  /// Any item with a `cost` is mirrored server-side onto a real BudgetItem
  /// (category "Honeymoon"), so a full refresh() is needed after mutations
  /// rather than splicing local state, to pick up the linked budget change.
  Future<bool> addItem(Map<String, dynamic> data) async {
    try {
      await _api.post('/plan/honeymoon/items', data: data);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateItem(int id, Map<String, dynamic> data) async {
    try {
      await _api.patch('/plan/honeymoon/items/$id', data: data);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteItem(int id) async {
    try {
      await _api.delete('/plan/honeymoon/items/$id');
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Travelers ──────────────────────────────────────────────────────────────

  Future<bool> addTraveler({required String name, String? role}) async {
    try {
      final res = await _api.post('/plan/honeymoon/travelers', data: {
        'name': name,
        if (role != null && role.isNotEmpty) 'role': role,
      });
      final created = _extractItem(res);
      if (created != null && state.trip != null) {
        state = state.copyWith(trip: {
          ...state.trip!,
          'travelers': [...state.travelers, created]
        });
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeTraveler(int id) async {
    try {
      await _api.delete('/plan/honeymoon/travelers/$id');
      if (state.trip != null) {
        state = state.copyWith(trip: {
          ...state.trip!,
          'travelers': state.travelers.where((t) => t['id'] != id).toList()
        });
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Checklist (backed by Tasks, category "honeymoon") ────────────────────

  Future<bool> addChecklistTask(String title, {DateTime? dueDate}) async {
    try {
      await _api.post('/plan/tasks', data: {
        'title': title,
        'category': 'Honeymoon',
        'priority': 'medium',
        if (dueDate != null)
          'due_date': dueDate.toIso8601String().split('T').first,
      });
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> toggleChecklistTask(int id, bool completed) async {
    try {
      final res =
          await _api.patch('/plan/tasks/$id', data: {'completed': completed});
      final updated = _extractItem(res);
      if (updated != null) {
        state = state.copyWith(
            checklistTasks: state.checklistTasks
                .map((t) => t['id'] == id ? updated : t)
                .toList());
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteChecklistTask(int id) async {
    try {
      await _api.delete('/plan/tasks/$id');
      state = state.copyWith(
          checklistTasks:
              state.checklistTasks.where((t) => t['id'] != id).toList());
      return true;
    } catch (_) {
      return false;
    }
  }
}

final honeymoonProvider =
    StateNotifierProvider<HoneymoonNotifier, HoneymoonState>((ref) {
  return HoneymoonNotifier(ref.read(apiClientProvider));
});

// ── DOCUMENTS VAULT ────────────────────────────────────────────────────────────────

class DocumentsVaultState {
  final bool isLoading;
  final List<Map<String, dynamic>> documents;
  final String? error;

  const DocumentsVaultState(
      {this.isLoading = false, this.documents = const [], this.error});

  DocumentsVaultState copyWith(
          {bool? isLoading,
          List<Map<String, dynamic>>? documents,
          String? error}) =>
      DocumentsVaultState(
        isLoading: isLoading ?? this.isLoading,
        documents: documents ?? this.documents,
        error: error,
      );
}

class DocumentsVaultNotifier extends StateNotifier<DocumentsVaultState> {
  final ApiClient _api;
  DocumentsVaultNotifier(this._api)
      : super(const DocumentsVaultState(isLoading: true)) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.get('/plan/documents');
      state = state.copyWith(isLoading: false, documents: _extractList(res));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> upload(List<int> bytes, String filename,
      {String folder = 'Uploads'}) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
        'folder': folder,
      });
      final res = await _api.post('/plan/documents', data: formData);
      final created = _extractItem(res);
      if (created != null)
        state = state.copyWith(documents: [created, ...state.documents]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _api.delete('/plan/documents/$id');
      state = state.copyWith(
          documents: state.documents.where((d) => d['id'] != id).toList());
      return true;
    } catch (_) {
      return false;
    }
  }
}

final documentsVaultProvider =
    StateNotifierProvider<DocumentsVaultNotifier, DocumentsVaultState>((ref) {
  return DocumentsVaultNotifier(ref.read(apiClientProvider));
});
