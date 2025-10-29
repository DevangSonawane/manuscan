// lib/controllers/security_dispatch_controller.dart

import 'package:manuscan/services/api_urls.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SecurityDispatchController extends GetxController {
  final RxList<Map<String, dynamic>> returnChallans =
      <Map<String, dynamic>>[].obs;

  Future<void> fetchReturnChallans() async {
    isLoadingChallans.value = true;
    try {
      print('🔍 Fetching return challans');
      final response = await http.get(
        Uri.parse('${ApiUrls.palletDispatchBase}/api/challans/return'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📡 Return Challans Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        returnChallans.value = data
            .map((item) => {
                  'vendor_name': item['vendor_name'] ?? 'N/A',
                  'challan_no': item['challan_no'] ?? 'N/A',
                  'pallet_count': item['pallet_count']?.toString() ?? '0',
                })
            .toList();
        print('✅ Fetched ${returnChallans.length} return challans');
      } else {
        print('❌ Failed to fetch return challans');
        errorMessage.value = 'Failed to load return challans';
      }
    } catch (e) {
      print('❌ Error fetching return challans: $e');
      errorMessage.value = 'Network error occurred';
    } finally {
      isLoadingChallans.value = false;
    }
  }

  final RxList<Map<String, dynamic>> activeChallans =
      <Map<String, dynamic>>[].obs;

  Future<void> fetchActiveChallans() async {
    if (isLoadingChallans.value) return; // Prevent multiple simultaneous calls

    isLoadingChallans.value = true;
    try {
      print('🔍 Fetching active challans');
      final response = await http.get(
        Uri.parse('${ApiUrls.palletDispatchBase}/api/challans-dispatch'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📡 Active Challans Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        activeChallans.value = data
            .map((item) => {
                  'vendor_name': item['vendor_name'] ?? 'N/A',
                  'challan_no': item['challan_no'] ?? 'N/A',
                  'pallet_count': item['pallet_count']?.toString() ?? '0',
                  'customer_id': item['customer_id'] ?? '',
                })
            .toList();
        print('✅ Fetched ${activeChallans.length} active challans');
      } else {
        print('❌ Failed to fetch active challans');
        errorMessage.value = 'Failed to load active challans';
      }
    } catch (e) {
      print('❌ Error fetching active challans: $e');
      errorMessage.value = 'Network error occurred';
    } finally {
      isLoadingChallans.value = false;
    }
  }

  Future<bool> fetchChallanDetails(String challanNo) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiUrls.palletDispatchBase}/api/getopenChallanDetails/$challanNo'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        challanDetails.value = data;
        print('✅ Challan details fetched: ${json.encode(data)}');
        print('✅ Challan details fetched for $challanNo');
        return true; // Success
      } else {
        errorMessage.value = 'Challan not found';
        challanDetails.value = null;
        print('❌ Failed to fetch challan details: ${response.body}');
        return false; // Failure
      }
    } catch (e) {
      errorMessage.value = 'Network error occurred';
      challanDetails.value = null;
      print('❌ Error fetching challan details: $e');
      return false; // Failure
    } finally {
      isLoading.value = false;
    }
  }

  SecurityDispatchController() {
    print(
        "SecurityDispatchController constructor called, hashCode: ${hashCode}");
  }

  final scannedPallets = [].obs;
  final challanId = ''.obs;
  final zoom = 0.5.obs;
  final MobileScannerController scannerController = MobileScannerController();
  final Rx<bool> isLoading = false.obs;
  final Rx<String> errorMessage = ''.obs;
  final Rx<Map<String, dynamic>?> challanDetails =
      Rx<Map<String, dynamic>?>(null);
  final RxList<Map<String, dynamic>> returnchallans =
      <Map<String, dynamic>>[].obs;
  final Rx<bool> isLoadingChallans = false.obs;
  final Rx<bool> isSubmitting = false.obs;

  void addPallet(String code) {
    if (!scannedPallets.contains(code)) {
      scannedPallets.add(code);
      print("Added pallet: $code, Total: ${scannedPallets.length}");
    }
  }

  void removePallet(int index) {
    scannedPallets.removeAt(index);
    print("Removed pallet at index $index, Total: ${scannedPallets.length}");
  }

  void setChallanId(String id) {
    challanId.value = id;
    print("Challan ID set to: $id");
  }

  void setZoom(double value) {
    zoom.value = value;
    scannerController.setZoomScale(value);
  }

  void onScanned(String? scannedCode) {
    if (scannedCode != null && !scannedPallets.contains(scannedCode)) {
      scannedPallets.add(scannedCode);
      print("Scanned pallet: $scannedCode, Total: ${scannedPallets.length}");
    }
  }

  void resetPallets() {
    scannedPallets.clear();
    print("Scanned pallets reset to 0, Total: ${scannedPallets.length}");
  }

  // ✅ UPDATED: Removed vehicle number parameter
  Future<bool> dispatchChallan(String challanNo) async {
    isSubmitting.value = true;
    errorMessage.value = '';
    try {
      final response = await http
          .post(
            Uri.parse(
                '${ApiUrls.palletDispatchBase}/api/challans/$challanNo/dispatch'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            // ✅ UPDATED: Empty body since no vehicle number is required
            body: json.encode({}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        print('✅ Challan $challanNo dispatched successfully.');
        return true;
      } else {
        final data = json.decode(response.body);
        errorMessage.value = data['message'] ?? 'Failed to dispatch challan';
        print('❌ Failed to dispatch challan: ${response.body}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Network error occurred while dispatching.';
      print('❌ Error dispatching challan: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }
}
