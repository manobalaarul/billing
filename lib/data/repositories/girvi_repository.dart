import 'package:billing/data/services/api_client.dart';

import '../models/girvi_model.dart';

class GirviRepository {
  final ApiClient _apiService = ApiClient();

  // Future<Map<String, dynamic>> getGirvis({
  //   String? search,
  //   String? metalType,
  //   String? status,
  // }) async {
  //   try {
  //     final queryParams = <String, String>{};
  //     if (search != null && search.isNotEmpty) queryParams['search'] = search;
  //     if (metalType != null && metalType.isNotEmpty)
  //       queryParams['metal_type'] = metalType;
  //     if (status != null && status.isNotEmpty) queryParams['status'] = status;

  //     final response = await _apiService.get(
  //       '/girvi',
  //       queryParameters: queryParams,
  //     );

  //     if (response.statusCode == 200) {
  //       final List<GirviModel> girvis = (response.data as List)
  //           .map((json) => GirviModel.fromJson(json))
  //           .toList();
  //       return {'success': true, 'data': girvis};
  //     } else {
  //       return {'success': false, 'message': 'Failed to load girvi list'};
  //     }
  //   } catch (e) {
  //     return {
  //       'success': false,
  //       'message': e.toString().replaceAll('Exception: ', ''),
  //     };
  //   }
  // }

  // Future<Map<String, dynamic>> getGirviStats() async {
  //   try {
  //     final response = await _apiService.get('/girvi/stats');
  //     if (response.statusCode == 200) {
  //       return {'success': true, 'data': response.data};
  //     } else {
  //       return {'success': false, 'message': 'Failed to load girvi stats'};
  //     }
  //   } catch (e) {
  //     return {
  //       'success': false,
  //       'message': e.toString().replaceAll('Exception: ', ''),
  //     };
  //   }
  // }

  /// Fetches live metal prices.
  /// API: GET /girvi/metals
  /// Response: { "success": true, "metals": [{ "metal_name": "Gold", "price_per_gram": 14620 }] }
  Future<Map<String, dynamic>> getMetalPrices() async {
    try {
      final response = await _apiService.get('/girvi/metals');
      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': true,
          'data':
              data['metals'] ?? data, // handle both array and {metals:[...]}
        };
      } else {
        return {'success': false, 'message': 'Failed to load metal prices'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  /// Search customers by name, mobile, or code.
  /// API: GET /customers/search?query=...
  /// Response: { "success": true, "customers": [{id, name, mobile, city, customer_code}] }
  Future<Map<String, dynamic>> searchCustomers(String query) async {
    try {
      final response = await _apiService.get(
        '/customers/search',
        queryParameters: {'query': query},
      );
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['customers'] ?? response.data,
        };
      } else {
        return {'success': false, 'message': 'Failed to search customers'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  // Future<Map<String, dynamic>> createGirvi(GirviModel girvi) async {
  //   try {
  //     final response = await _apiService.post('/girvi', data: girvi.toJson());
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return {'success': true, 'data': response.data};
  //     } else {
  //       return {'success': false, 'message': 'Failed to create girvi'};
  //     }
  //   } catch (e) {
  //     return {
  //       'success': false,
  //       'message': e.toString().replaceAll('Exception: ', ''),
  //     };
  //   }
  // }

  Future<Map<String, dynamic>> updateGirvi(GirviModel girvi) async {
    try {
      final response = await _apiService.put(
        '/girvi/${girvi.id}',
        data: girvi.toJson(),
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else {
        return {'success': false, 'message': 'Failed to update girvi'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  Future<Map<String, dynamic>> closeGirvi(String id) async {
    try {
      final response = await _apiService.post(
        '/girvi/$id/close',
        data: {'status': 'CLOSED'},
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else {
        return {'success': false, 'message': 'Failed to close girvi'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  Future<Map<String, dynamic>> deleteGirvi(String id) async {
    try {
      final response = await _apiService.delete('/girvi/$id');
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else {
        return {'success': false, 'message': 'Failed to delete girvi'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  // Future<Map<String, dynamic>> getNextGirviNo() async {
  //   try {
  //     final response = await _apiService.get('/girvi/next-no');
  //     if (response.statusCode == 200) {
  //       return {'success': true, 'data': response.data};
  //     } else {
  //       return {
  //         'success': false,
  //         'message': 'Failed to fetch next girvi number',
  //       };
  //     }
  //   } catch (e) {
  //     return {
  //       'success': false,
  //       'message': e.toString().replaceAll('Exception: ', ''),
  //     };
  //   }
  // }
}
