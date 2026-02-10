import '../../config/app_config.dart';
import '../models/dashboard_stats_model.dart';
import '../services/api_client.dart';

class DashboardRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiClient.get(AppConfig.dashboardEndpoint);

      if (response.statusCode == 200) {
        final stats = DashboardStatsModel.fromJson(response.data);

        return {'success': true, 'data': stats};
      } else {
        return {'success': false, 'message': 'Failed to load dashboard data'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }
}
