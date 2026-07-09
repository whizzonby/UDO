import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class WeddingPartyState {
  final bool isLoading;
  final List<Map<String, dynamic>> members;
  final List<Map<String, dynamic>> responsibilities;
  final List<Map<String, dynamic>> buzzes;
  final List<Map<String, dynamic>> timelineItems;
  final List<Map<String, dynamic>> accommodations;
  final List<Map<String, dynamic>> transportGroups;
  final List<Map<String, dynamic>> emergencyContacts;
  final List<Map<String, dynamic>> files;
  final String? membersError;
  final String? responsibilitiesError;
  final String? buzzesError;
  final String? timelineError;
  final String? travelError;
  final String? emergencyError;
  final String? filesError;

  const WeddingPartyState({
    this.isLoading = false,
    this.members = const [],
    this.responsibilities = const [],
    this.buzzes = const [],
    this.timelineItems = const [],
    this.accommodations = const [],
    this.transportGroups = const [],
    this.emergencyContacts = const [],
    this.files = const [],
    this.membersError,
    this.responsibilitiesError,
    this.buzzesError,
    this.timelineError,
    this.travelError,
    this.emergencyError,
    this.filesError,
  });

  WeddingPartyState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? members,
    List<Map<String, dynamic>>? responsibilities,
    List<Map<String, dynamic>>? buzzes,
    List<Map<String, dynamic>>? timelineItems,
    List<Map<String, dynamic>>? accommodations,
    List<Map<String, dynamic>>? transportGroups,
    List<Map<String, dynamic>>? emergencyContacts,
    List<Map<String, dynamic>>? files,
    String? membersError,
    String? responsibilitiesError,
    String? buzzesError,
    String? timelineError,
    String? travelError,
    String? emergencyError,
    String? filesError,
  }) =>
      WeddingPartyState(
        isLoading: isLoading ?? this.isLoading,
        members: members ?? this.members,
        responsibilities: responsibilities ?? this.responsibilities,
        buzzes: buzzes ?? this.buzzes,
        timelineItems: timelineItems ?? this.timelineItems,
        accommodations: accommodations ?? this.accommodations,
        transportGroups: transportGroups ?? this.transportGroups,
        emergencyContacts: emergencyContacts ?? this.emergencyContacts,
        files: files ?? this.files,
        membersError: membersError,
        responsibilitiesError: responsibilitiesError,
        buzzesError: buzzesError,
        timelineError: timelineError,
        travelError: travelError,
        emergencyError: emergencyError,
        filesError: filesError,
      );
}

class WeddingPartyNotifier extends StateNotifier<WeddingPartyState> {
  final ApiClient _api;

  WeddingPartyNotifier(this._api) : super(const WeddingPartyState(isLoading: true)) {
    load();
  }

  List<Map<String, dynamic>> _extract(dynamic res) {
    if (res is Map && res['data'] != null) return (res['data'] as List).cast<Map<String, dynamic>>();
    if (res is List) return res.cast<Map<String, dynamic>>();
    return [];
  }

  Future<({List<Map<String, dynamic>> data, String? error})> _fetch(String path, {Map<String, dynamic>? query}) async {
    try {
      return (data: _extract(await _api.get(path, query: query)), error: null);
    } catch (e) {
      return (data: <Map<String, dynamic>>[], error: e.toString());
    }
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);

    final membersFuture = _fetch('/guests', query: {'group': 'wedding_party'});
    final responsibilitiesFuture = _fetch('/wedding-party/responsibilities');
    final buzzesFuture = _fetch('/messages');
    final timelineFuture = _fetch('/plan/timeline');
    final accommodationsFuture = _fetch('/logistics/accommodation');
    final transportFuture = _fetch('/logistics/transport');
    final emergencyFuture = _fetch('/wedding-party/emergency-contacts');
    final filesFuture = _fetch('/wedding-party/files');

    final members = await membersFuture;
    final responsibilities = await responsibilitiesFuture;
    final buzzes = await buzzesFuture;
    final timeline = await timelineFuture;
    final accommodations = await accommodationsFuture;
    final transport = await transportFuture;
    final emergency = await emergencyFuture;
    final files = await filesFuture;

    state = state.copyWith(
      isLoading: false,
      members: members.data,
      membersError: members.error,
      responsibilities: responsibilities.data,
      responsibilitiesError: responsibilities.error,
      buzzes: buzzes.data.where((m) {
        final filter = m['audience_filter'];
        return filter is Map && filter['guest_group'] == 'wedding_party';
      }).toList(),
      buzzesError: buzzes.error,
      timelineItems: timeline.data,
      timelineError: timeline.error,
      accommodations: accommodations.data,
      transportGroups: transport.data,
      travelError: accommodations.error ?? transport.error,
      emergencyContacts: emergency.data,
      emergencyError: emergency.error,
      files: files.data,
      filesError: files.error,
    );
  }

  Future<void> refresh() => load();

  // ── Members ────────────────────────────────────────────────────────────────

  Future<bool> addMember({
    required String firstName,
    required String lastName,
    required String role,
    String? email,
    String? phone,
  }) async {
    try {
      final res = await _api.post('/guests', data: {
        'first_name': firstName,
        'last_name': lastName,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'guest_group': 'wedding_party',
        'wedding_party_role': role,
      });
      final newMember = res as Map<String, dynamic>;
      state = state.copyWith(members: [...state.members, newMember]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateMember(int id, Map<String, dynamic> data) async {
    try {
      final res = await _api.patch('/guests/$id', data: data);
      final updated = res as Map<String, dynamic>;
      state = state.copyWith(
        members: state.members.map((m) => m['id'] == id ? updated : m).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> removeMember(int id) async {
    try {
      await _api.delete('/guests/$id');
      state = state.copyWith(members: state.members.where((m) => m['id'] != id).toList());
    } catch (_) {}
  }

  // ── Responsibilities ──────────────────────────────────────────────────────

  Future<bool> createResponsibility({
    required String title,
    String? description,
    int? guestId,
    String status = 'pending',
    DateTime? dueDate,
  }) async {
    try {
      final res = await _api.post('/wedding-party/responsibilities', data: {
        'title': title,
        if (description != null && description.isNotEmpty) 'description': description,
        if (guestId != null) 'guest_id': guestId,
        'status': status,
        if (dueDate != null) 'due_date': dueDate.toIso8601String().split('T').first,
      });
      final created = (res as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      state = state.copyWith(responsibilities: [...state.responsibilities, created]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateResponsibility(int id, Map<String, dynamic> data) async {
    try {
      final res = await _api.patch('/wedding-party/responsibilities/$id', data: data);
      final updated = (res as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      state = state.copyWith(
        responsibilities: state.responsibilities.map((r) => r['id'] == id ? updated : r).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteResponsibility(int id) async {
    try {
      await _api.delete('/wedding-party/responsibilities/$id');
      state = state.copyWith(responsibilities: state.responsibilities.where((r) => r['id'] != id).toList());
    } catch (_) {}
  }

  // ── Buzzes ─────────────────────────────────────────────────────────────────

  Future<bool> sendBuzz({required String body, required String channel}) async {
    try {
      final createRes = await _api.post('/messages', data: {
        'subject': body.length > 60 ? '${body.substring(0, 57)}...' : body,
        'body': body,
        'channel': channel,
        'message_type': 'general',
        'audience_filter': {'guest_group': 'wedding_party'},
      });
      final created = (createRes as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final sendRes = await _api.post('/messages/${created['id']}/send');
      final sent = (sendRes as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      state = state.copyWith(buzzes: [sent, ...state.buzzes]);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Emergency contacts ────────────────────────────────────────────────────

  Future<bool> addEmergencyContact({required String name, String? relationship, required String phone}) async {
    try {
      final res = await _api.post('/wedding-party/emergency-contacts', data: {
        'name': name,
        if (relationship != null && relationship.isNotEmpty) 'relationship': relationship,
        'phone': phone,
      });
      final created = (res as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      state = state.copyWith(emergencyContacts: [...state.emergencyContacts, created]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> removeEmergencyContact(int id) async {
    try {
      await _api.delete('/wedding-party/emergency-contacts/$id');
      state = state.copyWith(emergencyContacts: state.emergencyContacts.where((c) => c['id'] != id).toList());
    } catch (_) {}
  }

  Future<({bool ok, int recipients})> broadcastEmergency(String message) async {
    try {
      final res = await _api.post('/wedding-party/emergency-contacts/broadcast', data: {'message': message});
      final recipients = (res as Map<String, dynamic>)['recipients'] as int? ?? 0;
      return (ok: true, recipients: recipients);
    } catch (_) {
      return (ok: false, recipients: 0);
    }
  }

  // ── Files ──────────────────────────────────────────────────────────────────

  Future<bool> uploadFile(List<int> bytes, String filename, {String category = 'file', int? guestId}) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
        'category': category,
        if (guestId != null) 'guest_id': guestId,
      });
      final res = await _api.post('/wedding-party/files', data: formData);
      final created = (res as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      state = state.copyWith(files: [created, ...state.files]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteFile(int id) async {
    try {
      await _api.delete('/wedding-party/files/$id');
      state = state.copyWith(files: state.files.where((f) => f['id'] != id).toList());
    } catch (_) {}
  }
}

final weddingPartyProvider = StateNotifierProvider<WeddingPartyNotifier, WeddingPartyState>((ref) {
  return WeddingPartyNotifier(ref.read(apiClientProvider));
});
