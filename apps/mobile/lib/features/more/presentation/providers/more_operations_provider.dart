import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class MoreOperationsState {
  final bool isLoading;
  final Map<String, dynamic>? entitlements;
  final Map<String, dynamic>? activeWedding;
  final List<Map<String, dynamic>> weddings;
  final List<Map<String, dynamic>> team;
  final List<Map<String, dynamic>> roles;
  final List<Map<String, dynamic>> auditLogs;
  final List<String> approvalCategories;
  final List<Map<String, dynamic>> approvals;
  final String? error;

  const MoreOperationsState({
    this.isLoading = false,
    this.entitlements,
    this.activeWedding,
    this.weddings = const [],
    this.team = const [],
    this.roles = const [],
    this.auditLogs = const [],
    this.approvalCategories = const [],
    this.approvals = const [],
    this.error,
  });

  MoreOperationsState copyWith({
    bool? isLoading,
    Map<String, dynamic>? entitlements,
    Map<String, dynamic>? activeWedding,
    List<Map<String, dynamic>>? weddings,
    List<Map<String, dynamic>>? team,
    List<Map<String, dynamic>>? roles,
    List<Map<String, dynamic>>? auditLogs,
    List<String>? approvalCategories,
    List<Map<String, dynamic>>? approvals,
    String? error,
  }) =>
      MoreOperationsState(
        isLoading: isLoading ?? this.isLoading,
        entitlements: entitlements ?? this.entitlements,
        activeWedding: activeWedding ?? this.activeWedding,
        weddings: weddings ?? this.weddings,
        team: team ?? this.team,
        roles: roles ?? this.roles,
        auditLogs: auditLogs ?? this.auditLogs,
        approvalCategories: approvalCategories ?? this.approvalCategories,
        approvals: approvals ?? this.approvals,
        error: error,
      );
}

class MoreOperationsNotifier extends StateNotifier<MoreOperationsState> {
  final ApiClient _api;

  MoreOperationsNotifier(this._api) : super(const MoreOperationsState(isLoading: true)) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final entitlementsRes = _map(await _api.get('/billing/entitlements'));
      final weddingsRes = _map(await _api.get('/weddings'));
      Map<String, dynamic>? weddingRes;
      Map<String, dynamic>? teamRes;
      Map<String, dynamic>? auditRes;

      try {
        weddingRes = _map(await _api.get('/wedding'));
      } catch (_) {
        weddingRes = null;
      }

      try {
        teamRes = _map(await _api.get('/wedding/team'));
      } catch (_) {
        teamRes = null;
      }

      try {
        auditRes = _map(await _api.get('/audit-logs', query: {'limit': 8}));
      } catch (_) {
        auditRes = null;
      }

      Map<String, dynamic>? approvalsRes;
      try {
        approvalsRes = _map(await _api.get('/approvals'));
      } catch (_) {
        approvalsRes = null;
      }

      state = state.copyWith(
        isLoading: false,
        entitlements: _mapOrNull(entitlementsRes['data']),
        activeWedding: weddingRes,
        weddings: _mapList(weddingsRes['data']),
        team: _mapList(teamRes?['data']),
        roles: _mapList(teamRes?['roles']),
        auditLogs: _mapList(auditRes?['data']),
        approvalCategories: (teamRes?['approval_categories'] as List? ?? []).map((c) => c.toString()).toList(),
        approvals: _mapList(approvalsRes?['data']),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> voteOnApproval(int approvalRequestId, String decision, {String? note}) async {
    try {
      final res = _map(await _api.post('/approvals/$approvalRequestId/vote', data: {
        'decision': decision,
        if (note != null) 'note': note,
      }));
      final updated = Map<String, dynamic>.from(res['data'] as Map);
      state = state.copyWith(
        approvals: state.approvals.map((a) => a['id'] == updated['id'] ? updated : a).toList(),
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> addCollaborator({
    required String email,
    required String role,
    bool? isDecisionMaker,
    List<String>? approvalCategories,
  }) async {
    try {
      final res = _map(await _api.post('/wedding/team', data: {
        'email': email,
        'role': role,
        if (isDecisionMaker != null) 'is_decision_maker': isDecisionMaker,
        if (approvalCategories != null) 'approval_categories': approvalCategories,
      }));
      final member = Map<String, dynamic>.from(res['data'] as Map);
      state = state.copyWith(
        team: [...state.team.where((item) => item['user_id'] != member['user_id']), member],
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateCollaborator(int id, {bool? isDecisionMaker, List<String>? approvalCategories}) async {
    try {
      final res = _map(await _api.patch('/wedding/team/$id', data: {
        if (isDecisionMaker != null) 'is_decision_maker': isDecisionMaker,
        if (approvalCategories != null) 'approval_categories': approvalCategories,
      }));
      final member = Map<String, dynamic>.from(res['data'] as Map);
      state = state.copyWith(
        team: state.team.map((item) => item['id'] == id ? member : item).toList(),
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> switchWedding(int weddingId) async {
    try {
      await _api.post('/weddings/switch', data: {'wedding_id': weddingId});
      state = state.copyWith(
        weddings: state.weddings.map((wedding) => {
          ...wedding,
          'is_active': wedding['id'] == weddingId,
        }).toList(),
        team: const [],
        auditLogs: const [],
        error: null,
      );
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> createWedding({
    String? title,
    required String primaryName,
    String? secondaryName,
    String? eventDate,
    String? city,
    String? country,
  }) async {
    try {
      final wedding = _map(await _api.post('/weddings', data: {
        if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
        'couple_name_primary': primaryName.trim(),
        if (secondaryName != null && secondaryName.trim().isNotEmpty) 'couple_name_secondary': secondaryName.trim(),
        if (eventDate != null && eventDate.trim().isNotEmpty) 'event_date': eventDate.trim(),
        if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
        if (country != null && country.trim().isNotEmpty) 'country': country.trim(),
      }));
      state = state.copyWith(
        weddings: [...state.weddings.map((item) => {...item, 'is_active': false}), wedding],
        team: const [],
        auditLogs: const [],
        error: null,
      );
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateWedding(Map<String, dynamic> data) async {
    try {
      final wedding = _map(await _api.patch('/wedding', data: data));
      state = state.copyWith(
        activeWedding: wedding,
        weddings: state.weddings.map((item) {
          if (item['id'] != wedding['id']) return item;
          return {...item, ...wedding, 'is_active': true};
        }).toList(),
        error: null,
      );
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

List<Map<String, dynamic>> _mapList(dynamic value) {
  return (value as List? ?? [])
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

Map<String, dynamic>? _mapOrNull(dynamic value) {
  return value is Map ? Map<String, dynamic>.from(value) : null;
}

Map<String, dynamic> _map(dynamic value) {
  return Map<String, dynamic>.from(value as Map);
}

final moreOperationsProvider = StateNotifierProvider<MoreOperationsNotifier, MoreOperationsState>((ref) {
  return MoreOperationsNotifier(ref.read(apiClientProvider));
});
