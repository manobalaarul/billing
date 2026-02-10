import '../../config/app_config.dart';
import '../models/gold_rate_model.dart';
import '../services/api_client.dart';

class GoldRateRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getGoldRates({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        AppConfig.goldRateEndpoint,
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<GoldRateModel> rates = (response.data['data'] as List)
            .map((json) => GoldRateModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'data': rates,
          'total': response.data['total'] ?? 0,
        };
      } else {
        return {'success': false, 'message': 'Failed to load gold rates'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  Future<Map<String, dynamic>> createGoldRate(GoldRateModel goldRate) async {
    try {
      final response = await _apiClient.post(
        AppConfig.goldRateCreateEndpoint,
        data: goldRate.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final createdRate = GoldRateModel.fromJson(response.data);

        return {
          'success': true,
          'data': createdRate,
          'message': 'Gold rate created successfully',
        };
      } else {
        return {'success': false, 'message': 'Failed to create gold rate'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  Future<Map<String, dynamic>> updateGoldRate(GoldRateModel goldRate) async {
    try {
      final response = await _apiClient.put(
        '${AppConfig.goldRateUpdateEndpoint}/${goldRate.id}',
        data: goldRate.toJson(),
      );

      if (response.statusCode == 200) {
        final updatedRate = GoldRateModel.fromJson(response.data);

        return {
          'success': true,
          'data': updatedRate,
          'message': 'Gold rate updated successfully',
        };
      } else {
        return {'success': false, 'message': 'Failed to update gold rate'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  Future<Map<String, dynamic>> deleteGoldRate(String id) async {
    try {
      final response = await _apiClient.delete(
        '${AppConfig.goldRateEndpoint}/$id',
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Gold rate deleted successfully'};
      } else {
        return {'success': false, 'message': 'Failed to delete gold rate'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }
}
