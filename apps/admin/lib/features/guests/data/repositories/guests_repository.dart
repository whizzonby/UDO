import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../models/guest_model.dart';

part 'guests_repository.g.dart';

@riverpod
GuestsRepository guestsRepository(Ref ref) =>
    ApiGuestsRepository(ref.watch(apiClientProvider));

abstract class GuestsRepository {
  Future<({List<GuestModel> guests, int total})> getGuests({
    String? search,
    String? rsvpStatus,
    String? group,
  });
  Future<GuestsOverview> getOverview();
  Future<GuestModel> getGuest(String id);
  Future<GuestModel> createGuest(Map<String, dynamic> data);
  Future<GuestModel> updateGuest(String id, Map<String, dynamic> data);
  Future<void> deleteGuest(String id);
  Future<GuestModel> markInvited(String id);
  Future<String> regenerateToken(String id);
}

class ApiGuestsRepository implements GuestsRepository {
  const ApiGuestsRepository(this._dio);
  final Dio _dio;

  @override
  Future<({List<GuestModel> guests, int total})> getGuests({
    String? search,
    String? rsvpStatus,
    String? group,
  }) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (rsvpStatus != null && rsvpStatus != 'all') {
      params['rsvp_status'] = rsvpStatus;
    }
    if (group != null) params['group'] = group;

    final resp = await _dio.get('/guests/', queryParameters: params);
    final data = resp.data as Map<String, dynamic>;
    final raw = data['guests'] as List<dynamic>;
    return (
      guests: raw
          .map((g) => GuestModel.fromJson(g as Map<String, dynamic>))
          .toList(),
      total: (data['total'] as int?) ?? raw.length,
    );
  }

  @override
  Future<GuestsOverview> getOverview() async {
    final resp = await _dio.get('/guests/overview');
    final data = resp.data as Map<String, dynamic>;
    return GuestsOverview(
      totalGuests: (data['total_guests'] as int?) ?? 0,
      attending: (data['attending'] as int?) ?? 0,
      declined: (data['declined'] as int?) ?? 0,
      pending: (data['pending'] as int?) ?? 0,
      responseRate: (data['response_rate'] as int?) ?? 0,
      vipCount: (data['vip_count'] as int?) ?? 0,
      invitedCount: (data['invited_count'] as int?) ?? 0,
      notInvitedYet: (data['not_invited_yet'] as int?) ?? 0,
      quickStats: data['quick_stats'] != null
          ? GuestQuickStats.fromJson(
              data['quick_stats'] as Map<String, dynamic>)
          : const GuestQuickStats(),
    );
  }

  @override
  Future<GuestModel> getGuest(String id) async {
    final resp = await _dio.get('/guests/$id');
    return GuestModel.fromJson(
        (resp.data as Map<String, dynamic>)['guest'] as Map<String, dynamic>);
  }

  @override
  Future<GuestModel> createGuest(Map<String, dynamic> data) async {
    final resp = await _dio.post('/guests/', data: data);
    return GuestModel.fromJson(
        (resp.data as Map<String, dynamic>)['guest'] as Map<String, dynamic>);
  }

  @override
  Future<GuestModel> updateGuest(String id, Map<String, dynamic> data) async {
    final resp = await _dio.put('/guests/$id', data: data);
    return GuestModel.fromJson(
        (resp.data as Map<String, dynamic>)['guest'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteGuest(String id) async {
    await _dio.delete('/guests/$id');
  }

  @override
  Future<GuestModel> markInvited(String id) async {
    final resp = await _dio.post('/guests/$id/mark-invited');
    return GuestModel.fromJson(
        (resp.data as Map<String, dynamic>)['guest'] as Map<String, dynamic>);
  }

  @override
  Future<String> regenerateToken(String id) async {
    final resp = await _dio.post('/guests/$id/regenerate-token');
    return (resp.data as Map<String, dynamic>)['token'] as String;
  }
}
