import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../models/experience_config_model.dart';

part 'experience_repository.g.dart';

@riverpod
ExperienceRepository experienceRepository(Ref ref) =>
    ApiExperienceRepository(ref.watch(apiClientProvider));

abstract class ExperienceRepository {
  Future<ExperienceConfig> getConfig();
  Future<ExperienceConfig> updateConfig(Map<String, dynamic> data);
}

class ApiExperienceRepository implements ExperienceRepository {
  const ApiExperienceRepository(this._dio);
  final Dio _dio;

  @override
  Future<ExperienceConfig> getConfig() async {
    final resp = await _dio.get('/experience/');
    return ExperienceConfig.fromJson(
        (resp.data as Map<String, dynamic>)['config'] as Map<String, dynamic>);
  }

  @override
  Future<ExperienceConfig> updateConfig(Map<String, dynamic> data) async {
    final resp = await _dio.put('/experience/', data: data);
    return ExperienceConfig.fromJson(
        (resp.data as Map<String, dynamic>)['config'] as Map<String, dynamic>);
  }
}
