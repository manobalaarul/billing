import '../../config/app_config.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConfig.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Save token
        final token = data['token'];
        await _storageService.saveToken(token);

        // Save user
        final user = UserModel.fromJson(data['user']);
        await _storageService.saveUser(user);

        // Set logged in status
        await _storageService.setLoggedIn(true);

        return {'success': true, 'user': user, 'message': 'Login successful'};
      } else {
        return {'success': false, 'message': 'Login failed'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      await _apiClient.post(AppConfig.logoutEndpoint);

      // Clear local storage
      await _storageService.clearAll();

      return {'success': true, 'message': 'Logout successful'};
    } catch (e) {
      // Clear local storage even if API call fails
      await _storageService.clearAll();

      return {'success': true, 'message': 'Logout successful'};
    }
  }

  bool isLoggedIn() {
    return _storageService.isLoggedIn();
  }

  UserModel? getCurrentUser() {
    return _storageService.getUser();
  }
}
