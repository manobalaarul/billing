import '../../config/app_config.dart';
import '../models/customer_model.dart';
import '../services/api_client.dart';

class CustomerRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getCustomers({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _apiClient.get(
        AppConfig.customerEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<CustomerModel> customers = (response.data['data'] as List)
            .map((json) => CustomerModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'data': customers,
          'total': response.data['total'] ?? 0,
        };
      } else {
        return {'success': false, 'message': 'Failed to load customers'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  Future<Map<String, dynamic>> createCustomer(
    CustomerModel customer, {
    String? photoPath,
  }) async {
    try {
      Map<String, dynamic> data = customer.toJson();

      // If photo is provided, upload it first
      if (photoPath != null) {
        final uploadResponse = await _apiClient.uploadFile(
          '${AppConfig.customerEndpoint}/upload-photo',
          photoPath,
          fieldName: 'photo',
        );

        if (uploadResponse.statusCode == 200) {
          data['photo_url'] = uploadResponse.data['url'];
        }
      }

      final response = await _apiClient.post(
        AppConfig.customerCreateEndpoint,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final createdCustomer = CustomerModel.fromJson(response.data);

        return {
          'success': true,
          'data': createdCustomer,
          'message': 'Customer created successfully',
        };
      } else {
        return {'success': false, 'message': 'Failed to create customer'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  Future<Map<String, dynamic>> updateCustomer(
    CustomerModel customer, {
    String? photoPath,
  }) async {
    try {
      Map<String, dynamic> data = customer.toJson();

      // If photo is provided, upload it first
      if (photoPath != null) {
        final uploadResponse = await _apiClient.uploadFile(
          '${AppConfig.customerEndpoint}/upload-photo',
          photoPath,
          fieldName: 'photo',
        );

        if (uploadResponse.statusCode == 200) {
          data['photo_url'] = uploadResponse.data['url'];
        }
      }

      final response = await _apiClient.put(
        '${AppConfig.customerUpdateEndpoint}/${customer.id}',
        data: data,
      );

      if (response.statusCode == 200) {
        final updatedCustomer = CustomerModel.fromJson(response.data);

        return {
          'success': true,
          'data': updatedCustomer,
          'message': 'Customer updated successfully',
        };
      } else {
        return {'success': false, 'message': 'Failed to update customer'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  Future<Map<String, dynamic>> deleteCustomer(String id) async {
    try {
      final response = await _apiClient.delete(
        '${AppConfig.customerDeleteEndpoint}/$id',
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Customer deleted successfully'};
      } else {
        return {'success': false, 'message': 'Failed to delete customer'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  Future<Map<String, dynamic>> getCustomerById(String id) async {
    try {
      final response = await _apiClient.get(
        '${AppConfig.customerEndpoint}/$id',
      );

      if (response.statusCode == 200) {
        final customer = CustomerModel.fromJson(response.data);

        return {'success': true, 'data': customer};
      } else {
        return {'success': false, 'message': 'Failed to load customer'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }
}
