import 'package:get/get.dart';

import '../controllers/gold_rate_controller.dart';

class GoldRateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GoldRateController>(() => GoldRateController());
  }
}
