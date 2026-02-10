import 'package:get/get.dart';

import '../../../../data/models/dashboard_stats_model.dart';
import '../../../../data/repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository = DashboardRepository();

  final RxBool isLoading = false.obs;
  final Rx<DashboardStatsModel?> dashboardStats = Rx<DashboardStatsModel?>(
    null,
  );
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _repository.getDashboardStats();

    isLoading.value = false;

    if (result['success']) {
      dashboardStats.value = result['data'];
    } else {
      errorMessage.value = result['message'];
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }
}
