import 'package:get/get.dart';

import '../controllers/girvi_redemption_controller.dart';

class GirviRedemptionBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GirviRedemptionController>(() => GirviRedemptionController());
  }
}
