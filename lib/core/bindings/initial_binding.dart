import 'package:get/get.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/repositories/gold_rate_repository.dart';
import '../../data/services/api_client.dart';
import '../../data/services/storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services (Singleton)
    Get.put<ApiClient>(ApiClient(), permanent: true);
    Get.put<StorageService>(StorageService(), permanent: true);

    // Repositories (Lazy Load)
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<DashboardRepository>(() => DashboardRepository());
    Get.lazyPut<GoldRateRepository>(() => GoldRateRepository());
    Get.lazyPut<CustomerRepository>(() => CustomerRepository());
  }
}
