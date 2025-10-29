import 'package:get/get.dart';
import '../controllers/pallet_return_controller.dart';

class PalletReturnBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PalletReturnController(), tag: 'palletReturn', permanent: true);
  }
}
