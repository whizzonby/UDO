import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/network/api_client.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

final contentPageProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, slug) async {
  final api = ref.read(apiClientProvider);
  final data = await api.get('/content-pages/$slug');
  final raw = data is Map && data['data'] is Map ? data['data'] as Map : data as Map;
  return Map<String, dynamic>.from(raw);
});

final releaseNotesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.get('/release-notes');
  final list = (data is Map ? data['data'] : data) as List? ?? [];
  return list
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
});
