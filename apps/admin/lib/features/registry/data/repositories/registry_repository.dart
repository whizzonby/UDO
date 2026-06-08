import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../models/registry_models.dart';

part 'registry_repository.g.dart';

@riverpod
RegistryRepository registryRepository(Ref ref) =>
    ApiRegistryRepository(ref.watch(apiClientProvider));

typedef RegistryData = ({
  List<RegistryItem> items,
  RegistryCashFund? fund,
  RegistrySummary summary,
});

abstract class RegistryRepository {
  Future<RegistryData> getAll();
  Future<RegistryItem> createItem(Map<String, dynamic> data);
  Future<RegistryItem> updateItem(String id, Map<String, dynamic> data);
  Future<void> deleteItem(String id);
  Future<RegistryItem> claimItem(String id, {String? claimedByName});
  Future<RegistryItem> unclaimItem(String id);
  Future<RegistryItem> markThanked(String id);
  Future<RegistryCashFund> updateFund(Map<String, dynamic> data);
}

class ApiRegistryRepository implements RegistryRepository {
  const ApiRegistryRepository(this._dio);
  final Dio _dio;

  @override
  Future<RegistryData> getAll() async {
    final resp = await _dio.get('/registry/');
    final d = resp.data as Map<String, dynamic>;
    final rawItems = d['items'] as List<dynamic>;
    return (
      items: rawItems
          .map((i) => RegistryItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      fund: d['fund'] != null
          ? RegistryCashFund.fromJson(d['fund'] as Map<String, dynamic>)
          : null,
      summary: RegistrySummary.fromJson(
          d['summary'] as Map<String, dynamic>),
    );
  }

  @override
  Future<RegistryItem> createItem(Map<String, dynamic> data) async {
    final resp = await _dio.post('/registry/items', data: data);
    return RegistryItem.fromJson(
        (resp.data as Map<String, dynamic>)['item'] as Map<String, dynamic>);
  }

  @override
  Future<RegistryItem> updateItem(String id, Map<String, dynamic> data) async {
    final resp = await _dio.put('/registry/items/$id', data: data);
    return RegistryItem.fromJson(
        (resp.data as Map<String, dynamic>)['item'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteItem(String id) => _dio.delete('/registry/items/$id');

  @override
  Future<RegistryItem> claimItem(String id, {String? claimedByName}) async {
    final resp = await _dio.patch('/registry/items/$id/claim',
        data: claimedByName != null ? {'claimed_by_name': claimedByName} : {});
    return RegistryItem.fromJson(
        (resp.data as Map<String, dynamic>)['item'] as Map<String, dynamic>);
  }

  @override
  Future<RegistryItem> unclaimItem(String id) async {
    final resp = await _dio.patch('/registry/items/$id/unclaim');
    return RegistryItem.fromJson(
        (resp.data as Map<String, dynamic>)['item'] as Map<String, dynamic>);
  }

  @override
  Future<RegistryItem> markThanked(String id) async {
    final resp = await _dio.patch('/registry/items/$id/thank');
    return RegistryItem.fromJson(
        (resp.data as Map<String, dynamic>)['item'] as Map<String, dynamic>);
  }

  @override
  Future<RegistryCashFund> updateFund(Map<String, dynamic> data) async {
    final resp = await _dio.put('/registry/fund', data: data);
    return RegistryCashFund.fromJson(
        (resp.data as Map<String, dynamic>)['fund'] as Map<String, dynamic>);
  }
}
