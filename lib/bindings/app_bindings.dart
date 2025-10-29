import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/pallet_dispatch_controller.dart';
import '../controllers/security_dispatch_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(PalletDispatchController(),
        tag: 'palletDispatch', permanent: true); // Register globally
    Get.put(SecurityDispatchController(),
        tag: 'securityDispatch',
        permanent: true); // Register security dispatch controller
  }
}
