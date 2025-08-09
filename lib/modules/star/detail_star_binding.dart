import 'package:get/get.dart';
import 'detail_star_controller.dart';

class DetailStarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailStarsController>(() => DetailStarsController());
  }
}
