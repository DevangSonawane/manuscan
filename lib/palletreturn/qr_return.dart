import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:manuscan/controllers/pallet_return_controller.dart';
import 'package:manuscan/services/pallet_return_service.dart';
import 'package:manuscan/services/defect_detection_service.dart';
import 'package:manuscan/home_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Step 1: Initial popup for vehicle number and pallet count
void showChallanIdPopup(BuildContext context) {
  final challanController = TextEditingController();
  final vehicleController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: vehicleController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'Vehicle Number',
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: challanController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Number of Pallets',
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                if (challanController.text.trim().isEmpty ||
                    vehicleController.text.trim().isEmpty) {
                  Flushbar(
                    message: 'Please fill in all fields',
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ).show(context);
                } else {
                  final returnId =
                      DateTime.now().millisecondsSinceEpoch.toString();
                  // Use permanent:false to ensure the controller is disposed of when the flow ends
                  final controller = Get.put(PalletReturnController(),
                      tag: returnId, permanent: false);

                  controller.initialize([]);
                  controller.setTotalPallets(
                      int.parse(challanController.text.trim()));
                  controller.setVehicleNumber(vehicleController.text.trim());

                  Navigator.pop(context); // Close the dialog
                  // Navigate to the next screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPalletsSection(
                        returnId: returnId,
                        challanId: challanController.text.trim(),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "CONFIRM",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Step 2: Add pallets screen
class AddPalletsSection extends StatefulWidget {
  final String returnId;
  final String challanId;

  const AddPalletsSection({
    Key? key,
    required this.returnId,
    required this.challanId,
  }) : super(key: key);

  @override
  _AddPalletsSectionState createState() => _AddPalletsSectionState();
}

class _AddPalletsSectionState extends State<AddPalletsSection> {
  late final PalletReturnController palletReturnController;
  final TextEditingController modelPalletController = TextEditingController();
  final TextEditingController palletSrController = TextEditingController();
  String selectedReturnStatus = 'Returned';
  String selectedConditionStatus = 'NO-DEFECT';
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _capturedImage;
  String? _analysisText;
  String? _finalDecision;
  String? _defectRemark;
  bool _showDefectResults = false;
  String? _nodeJsImagePath; // <-- ADD THIS VARIABLE

  @override
  void initState() {
    super.initState();
    palletReturnController =
        Get.find<PalletReturnController>(tag: widget.returnId);
  }

  void _resetState() {
    setState(() {
      modelPalletController.clear();
      palletSrController.clear();
      selectedReturnStatus = 'Returned';
      selectedConditionStatus = 'NO-DEFECT';
      _capturedImage = null;
      _analysisText = null;
      _finalDecision = null;
      _defectRemark = null;
      _showDefectResults = false;
      _nodeJsImagePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Pallet Entry'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: modelPalletController,
              decoration: InputDecoration(
                labelText: 'MODEL PALLET',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: palletSrController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'PALLET SR',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Note: Please ensure all pallets belong to the same challan",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                  child: Text("OR",
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final scannedData =
                          await Navigator.push<Map<String, String>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const CustomReturnScannerScreen(),
                        ),
                      );

                      if (scannedData != null) {
                        setState(() {
                          modelPalletController.text =
                              scannedData['modelPallet'] ?? '';
                          palletSrController.text =
                              scannedData['palletSr'] ?? '';
                        });
                      }
                    },
                    icon: const Icon(Icons.qr_code_scanner,
                        color: Colors.black87),
                    label: const Text("SCAN PALLET"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showPhotoOptions,
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text("DEFECT DETECTION"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
            if (_showDefectResults) ...[
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Defect Detection Results',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      if (_capturedImage != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(_capturedImage!.path),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover),
                        ),
                      ],
                      if (_analysisText != null) ...[
                        const SizedBox(height: 12),
                        // Display the combined text directly from the parsing function
                        Text(_analysisText!),
                      ],
                      if (_finalDecision != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('Final Decision: ',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            Chip(
                                label: Text(_finalDecision!),
                                backgroundColor: _finalDecision == 'DEFECT'
                                    ? Colors.red.shade100
                                    : Colors.green.shade100),
                          ],
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedReturnStatus,
                      decoration:
                          const InputDecoration(labelText: 'Return Status'),
                      items: ['Returned', 'Not Returned']
                          .map((item) =>
                              DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null)
                          setState(() => selectedReturnStatus = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedConditionStatus,
                      decoration:
                          const InputDecoration(labelText: 'Condition Status'),
                      items: ['DEFECT', 'NO-DEFECT']
                          .map((item) =>
                              DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null)
                          setState(() => selectedConditionStatus = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (modelPalletController.text.trim().isEmpty ||
                    palletSrController.text.trim().isEmpty) {
                  Flushbar(
                          message:
                              'Please enter both MODEL PALLET and PALLET SR',
                          backgroundColor: Colors.red)
                      .show(context);
                  return;
                }
                String combinedCode =
                    '${modelPalletController.text.trim()}-${palletSrController.text.trim()}';

                // Add the Node.js image path to the pallet data map
                final palletData = {
                  'code': combinedCode,
                  'returnStatus': selectedReturnStatus,
                  'conditionStatus': selectedConditionStatus,
                  if (_defectRemark != null && _defectRemark!.isNotEmpty)
                    'defect_remark': _defectRemark,
                  if (_nodeJsImagePath != null)
                    'defect_image_path': _nodeJsImagePath, // <-- ADD THIS LINE
                };
                palletReturnController.addScannedPallet(palletData);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PalletReturnScreen(
                      returnId: widget.returnId,
                      challanId: widget.challanId,
                    ),
                  ),
                );

                // When returning from the list screen, reset the state for a new entry.
                if (result == 'add_new_pallet') {
                  _resetState();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("CONFIRM ENTRY & VIEW LIST",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

// In qr_return.dart -> _AddPalletsSectionState class

  void _showPhotoOptions() {
    if (modelPalletController.text.trim().isEmpty ||
        palletSrController.text.trim().isEmpty) {
      Flushbar(
        message:
            'Please enter both MODEL PALLET and PALLET SR before detecting a defect.',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
      ).show(context);
      return; // Stop the function here if fields are empty
    }

    // If validation passes, show the dialog to choose an image source
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Defect Detection'),
        content: const Text('Choose an image source:'),
        actions: [
          TextButton(
            child: const Text('Take Photo'),
            onPressed: () {
              Navigator.pop(context);
              _captureImage(ImageSource.camera);
            },
          ),
          TextButton(
            child: const Text('Upload Photo'),
            onPressed: () {
              Navigator.pop(context);
              _captureImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

// In qr_return.dart, inside _AddPalletsSectionState

  Future<void> _captureImage(ImageSource source) async {
    try {
      final image =
          await _imagePicker.pickImage(source: source, imageQuality: 50);
      if (image == null) return;
      print('Picked file MIME Type: ${image.mimeType}');
      setState(() {
        _capturedImage = image;
        _showDefectResults = true;
        _analysisText = "Analyzing & Uploading..."; // Update text
        _finalDecision = null;
        _nodeJsImagePath = null; // Reset path on new capture
      });

      // This is the only function you need to call now
      await _runUnifiedDefectDetection();
    } catch (e) {
      Flushbar(
              message: 'Error capturing image: $e', backgroundColor: Colors.red)
          .show(context);
    }
  }

// In qr_return.dart, inside _AddPalletsSectionState

  Future<void> _runUnifiedDefectDetection() async {
    if (_capturedImage == null) return;

    // Combine the text fields to create the pallet ID
    String palletId =
        '${modelPalletController.text.trim()}-${palletSrController.text.trim()}';
    // Show loading dialog
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Pass the palletId to the service method
      final ScriptAndUploadResult result =
          await DefectDetectionService.runScriptAndUploadImage(
              _capturedImage!, palletId);

      Get.back(); // Close loading dialog

      setState(() {
        _analysisText = _parseDefectAnalysis(result.scriptResult.output);
        _finalDecision = _parseDefectDecision(result.scriptResult.output);
        _nodeJsImagePath = result.imagePath;
        selectedConditionStatus =
            _finalDecision == 'DEFECT' ? 'DEFECT' : 'NO-DEFECT';
      });
    } catch (e) {
      Get.back(); // Close loading dialog
      setState(() {
        _analysisText = "Operation failed.";
        _finalDecision = "ERROR";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during defect detection: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // In qr_return.dart -> _AddPalletsSectionState class

  // In qr_return.dart -> _AddPalletsSectionState class

  String _parseDefectAnalysis(String output) {
    // Regex to find the Analysis part
    final analysisRegExp = RegExp(r'\*\*Analysis:\*\*(.*?)\*\*', dotAll: true);
    final analysisMatch = analysisRegExp.firstMatch(output);
    // Extract analysis text or use a fallback
    final analysisText =
        analysisMatch?.group(1)?.trim() ?? "No analysis found.";

    // Regex to find the Comments part
    final commentsRegExp = RegExp(r'\*\*Comments:\*\*(.*?)\*\*', dotAll: true);
    final commentsMatch = commentsRegExp.firstMatch(output);
    // Extract comments text (it will be null if not found)
    final commentsText = commentsMatch?.group(1)?.trim();

    // Combine the results into a single string
    if (commentsText != null && commentsText.isNotEmpty) {
      // If comments exist, combine both for display
      return 'Analysis: $analysisText\n\nComments: $commentsText';
    } else {
      // If no comments are found, just return the analysis
      return 'Analysis: $analysisText';
    }
  }

  String _parseDefectDecision(String output) {
    print('Parsing defect decision from output: $output');

    // First try to parse JSON format from the defect detection script
    try {
      // Look for JSON structure in the output
      final jsonRegExp = RegExp(r'\{.*?"final_decision".*?\}', dotAll: true);
      final jsonMatch = jsonRegExp.firstMatch(output);

      if (jsonMatch != null) {
        final jsonString = jsonMatch.group(0);
        if (jsonString != null) {
          print('Found JSON structure: $jsonString');
          // Try to extract final_decision from JSON-like structure
          final decisionRegExp = RegExp(r'"final_decision":\s*"([^"]+)"');
          final decisionMatch = decisionRegExp.firstMatch(jsonString);
          if (decisionMatch != null) {
            final decision = decisionMatch.group(1)!.trim().toUpperCase();
            print('Extracted decision from JSON: $decision');
            return decision;
          }
        }
      }
    } catch (e) {
      print('Error parsing JSON decision: $e');
    }

    // Fallback to original parsing methods
    final decisionRegExp =
        RegExp(r'\*\*Final Decision:\*\*\s*\*\*\[(.*?)\]\*\*', dotAll: true);
    final match = decisionRegExp.firstMatch(output);
    if (match != null && match.group(1) != null) {
      final decision = match.group(1)!.trim().toUpperCase();
      print('Extracted decision from markdown: $decision');
      return decision;
    }

    // Look for decision in different formats based on analysis content
    final lowerOutput = output.toLowerCase();
    if (lowerOutput.contains("crack") ||
        lowerOutput.contains("damage") ||
        lowerOutput.contains("defect detected") ||
        lowerOutput.contains("defect found") ||
        lowerOutput.contains("broken") ||
        lowerOutput.contains("compromised") ||
        lowerOutput.contains("structural integrity")) {
      print('Found defect indicators in analysis');
      return "DEFECT";
    }

    if (lowerOutput.contains("no defect") ||
        lowerOutput.contains("good condition") ||
        lowerOutput.contains("intact") ||
        lowerOutput.contains("no major breakage") ||
        lowerOutput.contains("no issues")) {
      print('Found no-defect indicators in analysis');
      return "NO-DEFECT";
    }

    print('No clear decision found, defaulting to NO-DEFECT');
    return 'NO-DEFECT';
  }
}

/// Step 3: Main pallet return screen
class PalletReturnScreen extends StatefulWidget {
  final String returnId;
  final String challanId;

  const PalletReturnScreen({
    Key? key,
    required this.returnId,
    required this.challanId,
  }) : super(key: key);

  @override
  _PalletReturnScreenState createState() => _PalletReturnScreenState();
}

class _PalletReturnScreenState extends State<PalletReturnScreen> {
  late final PalletReturnController palletReturnController;

  @override
  void initState() {
    super.initState();
    palletReturnController =
        Get.find<PalletReturnController>(tag: widget.returnId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Pallet List'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          // Pops the current screen to go back to the "Add Pallets" screen
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final pallets = palletReturnController.scannedPallets;
                if (pallets.isEmpty) {
                  return const Center(
                      child: Text('No pallets added yet. Go back to add one.'));
                }
                return ListView.builder(
                  itemCount: pallets.length,
                  itemBuilder: (context, index) {
                    final pallet = pallets[index];
                    final code = pallet['code'] ?? '—';
                    final returnStatus =
                        pallet['returnStatus'] ?? 'Not Returned';
                    final conditionStatus =
                        pallet['conditionStatus'] ?? 'NO-DEFECT';
                    return ListTile(
                      title: Text(code),
                      subtitle: Text(
                          'Return: $returnStatus, Condition: $conditionStatus'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            palletReturnController.removePallet(index),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            'Total Expected: ${palletReturnController.totalPallets.value}'),
                        Text(
                            'Returned: ${palletReturnController.returnedCount}',
                            style: const TextStyle(color: Colors.blue)),
                        Text(
                            'Not Returned: ${palletReturnController.notReturnedCount}',
                            style: const TextStyle(color: Colors.red)),
                      ],
                    )),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final canAddMore =
                        palletReturnController.scannedPallets.length <
                            palletReturnController.totalPallets.value;
                    return ElevatedButton.icon(
                      onPressed: canAddMore
                          ? () => Navigator.of(context).pop('add_new_pallet')
                          : null,
                      icon: Icon(Icons.add_circle,
                          color: canAddMore ? Colors.white : Colors.grey),
                      label: Text("ADD PALLET",
                          style: TextStyle(
                              color: canAddMore ? Colors.white : Colors.grey)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              canAddMore ? Colors.teal : Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 15)),
                    );
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showConfirmationDialog,
                    child: const Text("CONFIRM"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    // Validate that there are pallets to process
    if (palletReturnController.scannedPallets.isEmpty) {
      Flushbar(
        message: 'No pallets to process. Please add at least one pallet.',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ).show(context);
      return;
    }

    // Validate pallet data
    if (!palletReturnController.validatePalletData()) {
      Flushbar(
        message: 'Invalid pallet data. Please check all entries.',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ).show(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Confirm Pallet Return',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Vehicle Number: ${palletReturnController.getVehicleNumber()}'),
            const SizedBox(height: 8),
            Text(
                'Total Pallets: ${palletReturnController.scannedPallets.length}'),
            Text('Returned: ${palletReturnController.returnedCount}'),
            Text('Not Returned: ${palletReturnController.notReturnedCount}'),
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to submit this pallet return?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processApiCall();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _processApiCall() async {
    Get.dialog(
      const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing pallet return...'),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      List<Map<String, dynamic>> apiPallets =
          palletReturnController.scannedPallets.map((pallet) {
        String palletId = pallet['code'] ?? '';
        String returnStatus = pallet['returnStatus'] ?? 'Not Returned';
        String conditionStatus = pallet['conditionStatus'] ?? 'NO-DEFECT';
        String? defectRemark = pallet['defect_remark'];

        Map<String, dynamic> apiPallet = {
          'pallet_id': palletId,
          'current_status': conditionStatus,
          'return_status': returnStatus,
        };

        if (conditionStatus == 'DEFECT' &&
            defectRemark != null &&
            defectRemark.isNotEmpty) {
          apiPallet['defect_remark'] = defectRemark;
        }

        return apiPallet;
      }).toList();

      if (!PalletReturnService.validatePalletData(apiPallets)) {
        throw Exception('Invalid pallet data format');
      }

      final result = await PalletReturnService.processReturn(
        vehicleNo: palletReturnController.getVehicleNumber(),
        returnedPallets: palletReturnController.returnedCount,
        notReturnedPallets: palletReturnController.notReturnedCount,
        // ✅ FIXED: Pass the correct total pallets value from the initial user input
        totalPallets: palletReturnController.totalPallets.value,
        pallets: apiPallets,
      );

      Get.back(); // Close loading dialog

      if (result['success'] == true) {
        _showSuccessDialog(
            result['message'] ?? 'Return processed successfully!');
      } else {
        _showErrorDialog(result);
      }
    } catch (e) {
      Get.back();
      Flushbar(
        message: 'An unexpected error occurred: ${e.toString()}',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ).show(context);
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            const Text('Success', style: TextStyle(color: Colors.green)),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Navigate to home screen
              Get.offAll(() => HomeScreen());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(Map<String, dynamic> result) {
    String errorType = result['errorType'] ?? 'UNKNOWN_ERROR';
    String message = result['message'] ?? 'An error occurred';
    String? detailedError = result['error'];

    // Enhanced error message for challan mismatch
    if (detailedError != null &&
        detailedError
            .contains('Could not find a challan associated with pallet ID')) {
      errorType = 'CHALLAN_MISMATCH';
      // Extract pallet ID from error message
      final palletIdMatch =
          RegExp(r"pallet ID '([^']+)'").firstMatch(detailedError);
      final palletId = palletIdMatch?.group(1) ?? 'Unknown';

      message = 'Challan Mismatch Error\n\n'
          'Pallet ID: $palletId\n'
          'This pallet does not belong to any challan or belongs to a different challan.\n\n'
          'Please ensure all pallets belong to the same challan and try again.';
    }

    Color iconColor = Colors.red;
    IconData iconData = Icons.error;

    // Customize icon based on error type
    switch (errorType) {
      case 'CHALLAN_MISMATCH':
        iconColor = Colors.orange;
        iconData = Icons.warning;
        break;
      case 'NETWORK_ERROR':
        iconColor = Colors.blue;
        iconData = Icons.wifi_off;
        break;
      case 'VALIDATION_ERROR':
        iconColor = Colors.amber;
        iconData = Icons.info;
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(iconData, color: iconColor, size: 28),
            const SizedBox(width: 12),
            const Text('Error'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              if (detailedError != null && detailedError.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Technical Details:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  detailedError,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class CustomReturnScannerScreen extends StatelessWidget {
  const CustomReturnScannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MobileScannerController controller = MobileScannerController();

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Pallet QR')),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                controller.stop();
                final parsedData = _parseQRString(barcodes.first.rawValue!);
                Navigator.of(context).pop(parsedData);
              }
            },
          ),
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.teal, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _parseQRString(String qrString) {
    String modelPallet = '';
    String palletSr = '';
    List<String> lines = qrString.split('\n');

    for (String line in lines) {
      line = line.trim();
      if (line.startsWith('MODEL PALLET -')) {
        modelPallet = line.replaceFirst('MODEL PALLET -', '').trim();
      }
      if (line.startsWith('PALLET SR NO.-')) {
        palletSr = line.replaceFirst('PALLET SR NO.-', '').trim();
      }
    }
    return {
      'modelPallet': modelPallet,
      'palletSr': palletSr,
    };
  }
}
