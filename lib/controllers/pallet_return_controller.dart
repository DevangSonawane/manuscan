import 'package:get/get.dart';
import 'package:manuscan/controllers/auth_controller.dart';

class PalletReturnController extends GetxController {
  // Core data structures
  final RxList<Map<String, dynamic>> scannedPallets =
      <Map<String, dynamic>>[].obs;
  final RxInt totalPallets = 0.obs;
  final RxString _vehicleNumber = ''.obs;
  final RxBool isNavigating = false.obs;

  // Required getters for UI and API
  int get returnedCount =>
      scannedPallets.where((p) => p['returnStatus'] == 'Returned').length;

  int get notReturnedCount => totalPallets.value - returnedCount;

  String getVehicleNumber() => _vehicleNumber.value;
  
  // Getter for vehicle number (for Obx widgets)
  RxString get vehicleNumber => _vehicleNumber;

  // Initialize with existing pallets
  void initialize(List<Map<String, dynamic>> initialPallets) {
    scannedPallets.clear();
    scannedPallets.addAll(initialPallets);
  }

  // Add pallet if not already exists
  void addScannedPallet(Map<String, dynamic> pallet) {
    if (!scannedPallets.any((p) => p['code'] == pallet['code'])) {
      scannedPallets.add(pallet);
    }
  }

  // Add pallet (general method for manual entry)
  void addPallet(Map<String, dynamic> pallet) {
    // Check for duplicates based on palletSr
    final palletSr = pallet['palletSr']?.toString() ?? '';
    if (palletSr.isNotEmpty && 
        !scannedPallets.any((p) => p['palletSr']?.toString() == palletSr)) {
      scannedPallets.add(pallet);
    } else if (palletSr.isEmpty) {
      // If no serial number, just add it
      scannedPallets.add(pallet);
    } else {
      throw Exception('Pallet with serial number $palletSr already exists');
    }
  }
  // Add this method to pallet_return_controller.dart

// Validate that all pallets have required data
  bool validatePalletData() {
    for (final pallet in scannedPallets) {
      if (pallet['code'] == null ||
          pallet['code'].toString().trim().isEmpty ||
          pallet['returnStatus'] == null ||
          pallet['conditionStatus'] == null) {
        return false;
      }
    }
    return true;
  }

  // Remove pallet by index
  void removePallet(int index) {
    if (index >= 0 && index < scannedPallets.length) {
      scannedPallets.removeAt(index);
    }
  }

  // Set expected total count
  void setTotalPallets(int count) {
    totalPallets.value = count;
  }

  // Set vehicle number (uppercase)
  void setVehicleNumber(String number) {
    _vehicleNumber.value = number.toUpperCase();
  }

  // Generate receipt data for printing
  String generateReceiptData() {
    final now = DateTime.now();
    final timestamp =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    try {
      final authController = Get.find<AuthController>();
      return """
PALLET RETURN RECEIPT
Date & Time: $timestamp
Vehicle Number: ${_vehicleNumber.value}
Security Guard: ${authController.userFirstName}

PALLET SUMMARY
Total Pallets : ${totalPallets.value}
Returned      : $returnedCount
Not Returned  : $notReturnedCount

Signature: _______________
""";
    } catch (e) {
      return """
PALLET RETURN RECEIPT
Date & Time: $timestamp
Vehicle Number: ${_vehicleNumber.value}
Security Guard: [Not Available]

PALLET SUMMARY
Total Pallets : ${totalPallets.value}
Returned      : $returnedCount
Not Returned  : $notReturnedCount

Signature: _______________
""";
    }
  }
}
