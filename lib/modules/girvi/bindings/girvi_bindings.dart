import 'package:get/get.dart';

import '../controllers/girvi_controller.dart';

class GirviBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GirviController>(() => GirviController());
  }
}
