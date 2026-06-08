import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../models/seating_models.dart';

part 'seating_repository.g.dart';

@Riverpod(keepAlive: true)
SeatingRepository seatingRepository(Ref ref) =>
    ApiSeatingRepository(ref.watch(apiClientProvider));

abstract class SeatingRepository {
  Future<SeatingData> getSeatingData();
  Future<SeatingTable> createTable({
    required String name,
    required int capacity,
    String shape,
    String? section,
  });
  Future<SeatingTable> updateTable(SeatingTable table);
  Future<void> deleteTable(String tableId);
  Future<SeatingTable> assignGuest({
    required String tableId,
    required String guestId,
  });
  Future<void> unassignGuest({
    required String tableId,
    required String guestId,
  });
}

class ApiSeatingRepository implements SeatingRepository {
  const ApiSeatingRepository(this._dio);

  final Dio _dio;

  @override
  Future<SeatingData> getSeatingData() async {
    final response = await _dio.get('/plan/seating');
    return SeatingData.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SeatingTable> createTable({
    required String name,
    required int capacity,
    String shape = 'round',
    String? section,
  }) async {
    final response = await _dio.post('/plan/seating/tables', data: {
      'name': name,
      'capacity': capacity,
      'shape': shape,
      if (section != null) 'section': section,
    });
    return SeatingTable.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SeatingTable> updateTable(SeatingTable table) async {
    final response = await _dio.put(
      '/plan/seating/tables/${table.id}',
      data: {
        'name': table.name,
        'capacity': table.capacity,
        'shape': table.shape,
        'section': table.section,
        'color': table.color,
        'sort_order': table.sortOrder,
      },
    );
    return SeatingTable.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteTable(String tableId) async {
    await _dio.delete('/plan/seating/tables/$tableId');
  }

  @override
  Future<SeatingTable> assignGuest({
    required String tableId,
    required String guestId,
  }) async {
    final response = await _dio.post(
      '/plan/seating/tables/$tableId/assign',
      data: {'guest_id': guestId},
    );
    return SeatingTable.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> unassignGuest({
    required String tableId,
    required String guestId,
  }) async {
    await _dio.delete('/plan/seating/tables/$tableId/guests/$guestId');
  }
}
