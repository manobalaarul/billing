import '../../config/app_config.dart';
import '../models/customer_model.dart';
import '../services/api_client.dart';

class CustomerRepository {
  final ApiClient _apiClient = ApiClient();

  // ── Get All Customers ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getCustomers({
    int page = 1,
    int limit = 20,
    String? search,
    String? status, // '1' = active, '0' = inactive, '' = all
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
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

  // ── Get Single Customer ───────────────────────────────────────────────────

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

  // ── Create Customer ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createCustomer(
    CustomerModel customer, {
    String? photoPath,
    String? aadharPhotoPath,
    String? otherProofPhotoPath,
  }) async {
    try {
      Map<String, dynamic> data = customer.toJson();

      // Upload customer photo
      if (photoPath != null) {
        final uploadResponse = await _apiClient.uploadFile(
          '${AppConfig.customerEndpoint}/upload-photo',
          photoPath,
          fieldName: 'photo',
        );
        if (uploadResponse.statusCode == 200) {
          data['photo'] = uploadResponse.data['url'];
        }
      }

      // Upload aadhar photo / PDF
      if (aadharPhotoPath != null) {
        final uploadResponse = await _apiClient.uploadFile(
          '${AppConfig.customerEndpoint}/upload-proof',
          aadharPhotoPath,
          fieldName: 'aadhar_photo',
        );
        if (uploadResponse.statusCode == 200) {
          data['aadhar_photo'] = uploadResponse.data['url'];
        }
      }

      // Upload other proof photo
      if (otherProofPhotoPath != null) {
        final uploadResponse = await _apiClient.uploadFile(
          '${AppConfig.customerEndpoint}/upload-proof',
          otherProofPhotoPath,
          fieldName: 'other_proof_photo',
        );
        if (uploadResponse.statusCode == 200) {
          data['other_proof_photo'] = uploadResponse.data['url'];
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

  // ── Update Customer ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> updateCustomer(
    CustomerModel customer, {
    String? photoPath,
    String? aadharPhotoPath,
    String? otherProofPhotoPath,
  }) async {
    try {
      Map<String, dynamic> data = customer.toJson();

      // Upload customer photo
      if (photoPath != null) {
        final uploadResponse = await _apiClient.uploadFile(
          '${AppConfig.customerEndpoint}/upload-photo',
          photoPath,
          fieldName: 'photo',
        );
        if (uploadResponse.statusCode == 200) {
          data['photo'] = uploadResponse.data['url'];
        }
      }

      // Upload aadhar photo / PDF
      if (aadharPhotoPath != null) {
        final uploadResponse = await _apiClient.uploadFile(
          '${AppConfig.customerEndpoint}/upload-proof',
          aadharPhotoPath,
          fieldName: 'aadhar_photo',
        );
        if (uploadResponse.statusCode == 200) {
          data['aadhar_photo'] = uploadResponse.data['url'];
        }
      }

      // Upload other proof photo
      if (otherProofPhotoPath != null) {
        final uploadResponse = await _apiClient.uploadFile(
          '${AppConfig.customerEndpoint}/upload-proof',
          otherProofPhotoPath,
          fieldName: 'other_proof_photo',
        );
        if (uploadResponse.statusCode == 200) {
          data['other_proof_photo'] = uploadResponse.data['url'];
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

  // ── Delete Customer ───────────────────────────────────────────────────────

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

  // ── Get Next Customer Code ────────────────────────────────────────────────

  Future<Map<String, dynamic>> getNextCustomerCode() async {
    try {
      final response = await _apiClient.get(
        '${AppConfig.customerEndpoint}/next-code',
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data['code'] ?? 'C-001'};
      } else {
        return {'success': false, 'message': 'Failed to get customer code'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }
}
