// lib/controllers/security_return_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../services/api_urls.dart';

class SecurityReturnController extends GetxController {
  /* ------------------------ 1. SINGLETON / REGISTRATION ------------------- */
  static SecurityReturnController registerIfNeeded() {
    if (!Get.isRegistered(tag: 'securityReturn')) {
      return Get.put(SecurityReturnController(), tag: 'securityReturn');
    }
    return Get.find(tag: 'securityReturn');
  }

  SecurityReturnController() {
    // Debug helper
    print('SecurityReturnController instantiated → hashCode=$hashCode');
  }

  /* ------------------------------ 2. STATE -------------------------------- */
  final RxList<Map<String, dynamic>> receipts = <Map<String, dynamic>>[].obs;
  final Rx<bool> isLoadingReceipts = false.obs;

  final RxList<Map<String, dynamic>> searchResults =
      <Map<String, dynamic>>[].obs;
  final Rx<bool> isSearching = false.obs;

  final Rx<bool> isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  // Tapped row is stored here for downstream screens
  final RxMap<String, dynamic> selectedReceipt = <String, dynamic>{}.obs;
  void setSelectedReceipt(Map<String, dynamic> r) => selectedReceipt.value = r;

  /* ------------------------------ 3. API CALLS ---------------------------- */

  // 🧾 3.1 Fetch ALL open receipts
  Future<void> fetchReceipts() async {
    isLoadingReceipts.value = true;
    errorMessage.value = '';
    try {
      final response = await http
          .get(Uri.parse('${ApiUrls.palletDispatchBase}/api/receipts'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        receipts.value = _mapReceiptList(data);
        print('Fetched ${receipts.length} open receipts');
      } else {
        errorMessage.value = 'Failed to load receipts';
      }
    } catch (e) {
      errorMessage.value = 'Network error while loading receipts';
    } finally {
      isLoadingReceipts.value = false;
    }
  }

  // 🔍 3.2 Search open receipts by vehicle number
  Future<void> searchReceiptsByVehicle(String vehicleNo) async {
    isSearching.value = true;
    errorMessage.value = '';
    try {
      final response = await http
          .get(Uri.parse(
              '${ApiUrls.palletDispatchBase}/api/receipts/search/$vehicleNo'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        searchResults.value = _mapReceiptList(data);
        if (searchResults.isEmpty) {
          errorMessage.value = 'No open receipts found for this vehicle';
        }
      } else {
        errorMessage.value = 'Vehicle not found or no open receipts';
        searchResults.clear();
      }
    } catch (e) {
      errorMessage.value = 'Network error while searching receipts';
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  // 📪 3.3 Close ALL open receipts for a vehicle
  Future<bool> closeReceiptsByVehicle(String vehicleNo) async {
    isSubmitting.value = true;
    errorMessage.value = '';
    try {
      final response = await http
          .put(Uri.parse(
              '${ApiUrls.palletDispatchBase}/api/receipts/close/$vehicleNo'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        print(json.decode(response.body)['message']);
        // Refresh lists so UI updates automatically
        await fetchReceipts();
        clearSearch();
        return true;
      } else {
        final data = json.decode(response.body);
        errorMessage.value =
            data['message'] ?? 'Failed to close receipts for this vehicle';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Network error occurred while closing receipts';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /* ------------------------------ 4. HELPERS ------------------------------ */
  void clearSearch() {
    searchResults.clear();
    isSearching.value = false;
    errorMessage.value = '';
  }

  List<Map<String, dynamic>> _mapReceiptList(List<dynamic> data) => data
      .map((e) => {
            'vehicle_no': e['vehicle_no'] ?? 'N/A',
            'returned_pallets': (e['returned_pallets'] ?? 0).toString(),
            'not_returned_pallets': (e['not_returned_pallets'] ?? 0).toString(),
            'total_pallets': (e['total_pallets'] ?? 0).toString(),
            'date': e['date'] ?? '',
            'timestamp': e['timestamp'] ?? '',
            'status': e['status'] ?? 'N/A',
          })
      .toList();
}
