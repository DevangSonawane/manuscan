// lib/services/pallet_return_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manuscan/services/api_urls.dart';

class PalletReturnService {
  // 🔧 UPDATED: Enhanced API integration with new challan consistency error handling
  static Future<Map<String, dynamic>> processReturn({
    required String vehicleNo,
    required int returnedPallets,
    required int notReturnedPallets,
    required int totalPallets,
    required List<Map<String, dynamic>> pallets,
  }) async {
    try {
      print('🚀 Processing return with challan consistency check...');
      print('Vehicle: $vehicleNo');
      print(
          'Returned: $returnedPallets, Not Returned: $notReturnedPallets, Total: $totalPallets');
      print('Pallets data: ${json.encode(pallets)}');

      // Client-side validation before API call
      if (pallets.isEmpty) {
        return {
          'success': false,
          'message': 'No pallets provided for processing',
          'error': 'VALIDATION_ERROR',
          'errorType': 'VALIDATION_ERROR',
        };
      }

      if (returnedPallets + notReturnedPallets != totalPallets) {
        return {
          'success': false,
          'message':
              'Pallet count mismatch: Returned ($returnedPallets) + Not Returned ($notReturnedPallets) ≠ Total ($totalPallets)',
          'error': 'COUNT_MISMATCH',
          'errorType': 'COUNT_MISMATCH',
        };
      }

      final response = await http
          .post(
            Uri.parse(
                '${ApiUrls.palletDispatchBase}/api/pallets/process-return'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'vehicle_no': vehicleNo,
              'pallets': pallets,
              'returned_pallets': returnedPallets,
              'not_returned_pallets': notReturnedPallets,
              'total_pallets': totalPallets,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 API Response Status: ${response.statusCode}');
      print('📡 API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Return processed successfully',
          'data': responseData,
        };
      } else {
        final errorData = json.decode(response.body);
        String errorMessage =
            errorData['message'] ?? 'Failed to process return';
        String detailedError = errorData['error'] ?? '';
        String errorType = 'API_ERROR';

        // 🔧 UPDATED: Better handling for challan consistency errors
        if (detailedError.contains('belongs to a different challan')) {
          errorType = 'CHALLAN_MISMATCH';

          // Extract pallet ID and challan information from the detailed error
          final palletRegex = RegExp(
              r"Pallet '([^']+)' belongs to a different challan \(([^)]+)\).*challan '([^']+)'");
          final match = palletRegex.firstMatch(detailedError);

          if (match != null) {
            final palletId = match.group(1) ?? 'Unknown';
            final wrongChallan = match.group(2) ?? 'null';
            final correctChallan = match.group(3) ?? 'Unknown';

            String wrongChallanText =
                wrongChallan == 'null' ? 'unknown/no challan' : wrongChallan;

            errorMessage = 'Pallet Challan Mismatch:\n\n'
                '• Pallet ID: $palletId\n'
                '• Expected Challan: $correctChallan\n'
                '• Found Challan: $wrongChallanText\n\n'
                'All pallets must belong to the same challan.';
          } else {
            // Fallback: show the original detailed error
            errorMessage = 'Challan Consistency Error:\n\n$detailedError';
          }
        } else if (errorMessage
            .contains('exceeds the challan\'s original pallet count')) {
          errorType = 'EXCEEDS_ORIGINAL_COUNT';
          errorMessage =
              'The total pallets entered exceeds the original challan count. Please verify your entries.';
        } else if (errorMessage.contains('does not exist')) {
          errorType = 'PALLET_NOT_FOUND';
          errorMessage =
              'One or more pallet IDs do not exist in the system. Please verify the pallet codes.';
        } else if (errorMessage.contains('required')) {
          errorType = 'MISSING_REQUIRED_FIELDS';
        }

        return {
          'success': false,
          'message': errorMessage,
          'error': detailedError,
          'errorType': errorType,
          'rawError': errorData, // Include raw error for debugging
        };
      }
    } catch (e) {
      print('❌ Error processing return: $e');
      return {
        'success': false,
        'message':
            'Network error occurred. Please check your connection and try again.',
        'error': e.toString(),
        'errorType': 'NETWORK_ERROR',
      };
    }
  }

  // Enhanced validation method
  static bool validatePalletData(List<Map<String, dynamic>> pallets) {
    for (final pallet in pallets) {
      if (!pallet.containsKey('pallet_id') ||
          !pallet.containsKey('current_status') ||
          !pallet.containsKey('return_status')) {
        print('❌ Invalid pallet data: $pallet');
        return false;
      }

      // Additional validation for empty values
      if (pallet['pallet_id']?.toString().trim().isEmpty == true) {
        print('❌ Empty pallet_id found');
        return false;
      }
    }
    return true;
  }

  // 🔧 NEW: Method to validate total pallets don't exceed expected count
  static Map<String, dynamic> validatePalletCounts({
    required int returnedCount,
    required int notReturnedCount,
    required int totalPallets,
    required int expectedPallets,
  }) {
    if (totalPallets > expectedPallets) {
      return {
        'valid': false,
        'message':
            'Total pallets ($totalPallets) cannot exceed expected pallets ($expectedPallets)',
      };
    }

    if (returnedCount + notReturnedCount != totalPallets) {
      return {
        'valid': false,
        'message': 'Returned + Not Returned pallets must equal total pallets',
      };
    }

    return {'valid': true};
  }
}
