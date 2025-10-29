// FILE: qr_dispatch.dart

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:manuscan/home_screen.dart'; // Assuming this import is correct for your project
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/pallet_dispatch_controller.dart';
import 'package:get/get.dart';

// --- Screen 2: Challan Details and Scan/Entry Buttons ---
class PalletDispatchScreen2 extends StatefulWidget {
  final String challanId;
  final List scannedPallets;
  final Map<String, dynamic> challanDetails;

  const PalletDispatchScreen2({
    Key? key,
    required this.challanId,
    required this.scannedPallets,
    required this.challanDetails,
  }) : super(key: key);

  @override
  _PalletDispatchScreen2State createState() => _PalletDispatchScreen2State();
}

class _PalletDispatchScreen2State extends State<PalletDispatchScreen2> {
  final PalletDispatchController controller = Get.find(tag: 'palletDispatch');
  bool isLoading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    controller.setChallanId(widget.challanId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.scannedPallets.isEmpty ||
          controller.scannedPallets.length < widget.scannedPallets.length) {
        controller.scannedPallets
            .assignAll(widget.scannedPallets as Iterable<String>);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // FIXED: Defer navigation to avoid build conflicts
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pop(context);
          }
        });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Pallet Dispatch",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(27, 27, 30, 1),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: const Color.fromRGBO(27, 27, 30, 1),
            onPressed: () {
              // FIXED: Defer navigation to avoid build conflicts
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.pop(context);
                }
              });
            },
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          color: Colors.white,
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.teal),
                  ),
                )
              : error.isNotEmpty
                  ? Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          error,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              error = '';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Retry"),
                        ),
                      ],
                    ))
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Challan Details",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal,
                                          ),
                                        ),
                                        const Divider(height: 24),
                                        _buildDetailRow(
                                            "Vendor Code",
                                            widget.challanDetails['vendor']
                                                ['code']),
                                        _buildDetailRow(
                                            "Vendor Name",
                                            widget.challanDetails['vendor']
                                                ['name']),
                                        _buildDetailRow(
                                            "GSTIN",
                                            widget.challanDetails['vendor']
                                                ['gstin']),
                                        _buildDetailRow(
                                            "PAN",
                                            widget.challanDetails['vendor']
                                                ['pan']),
                                        const Divider(height: 24),
                                        _buildDetailRow(
                                            "Challan No",
                                            widget
                                                .challanDetails['challan_no']),
                                        _buildDetailRow(
                                            "Date",
                                            widget.challanDetails[
                                                'challan_info']['date']),
                                        _buildDetailRow(
                                            "Vehicle",
                                            widget.challanDetails[
                                                'challan_info']['vehicle_no']),
                                        _buildDetailRow(
                                            "Transporter",
                                            widget.challanDetails[
                                                'challan_info']['transporter']),
                                        const Divider(height: 24),
                                        _buildDetailRow(
                                            "Employee Code",
                                            widget.challanDetails['employee']
                                                ['code']),
                                        _buildDetailRow(
                                            "Employee Name",
                                            widget.challanDetails['employee']
                                                ['name']),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Material Details",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal,
                                          ),
                                        ),
                                        const Divider(height: 24),
                                        _buildDetailRow(
                                            "Material Code",
                                            widget.challanDetails['material']
                                                ['code']),
                                        _buildDetailRow(
                                            "Description",
                                            widget.challanDetails['material']
                                                ['description']),
                                        _buildDetailRow(
                                            "HSN Code",
                                            widget.challanDetails['material']
                                                ['hsn_code']),
                                        _buildDetailRow(
                                            "Unit",
                                            widget.challanDetails['material']
                                                ['unit']),
                                        _buildDetailRow(
                                            "Pallet Quantity",
                                            widget.challanDetails['material']
                                                ['pallet_count']),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    // Navigate to the scanner screen. It will handle adding pallets.
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CustomScannerScreen(
                                          challanId: widget.challanId,
                                          scannedPallets:
                                              controller.scannedPallets,
                                        ),
                                      ),
                                    );
                                    // The state will be managed by the controller, no need for returned value here.
                                  },
                                  icon: const Icon(Icons.qr_code_scanner,
                                      color: Colors.white),
                                  label: const Text(
                                    "SCAN PALLET",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 25, horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      showManualPalletIdPopup(context),
                                  icon: const Icon(Icons.edit,
                                      color: Colors.white),
                                  label: const Text(
                                    "MANUAL ENTRY\nOF PALLETS",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  void showManualPalletIdPopup(BuildContext context) {
    TextEditingController modelPalletController = TextEditingController();
    TextEditingController palletSrController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Enter Pallet Details",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: modelPalletController,
                  decoration: InputDecoration(
                      labelText: 'MODEL PALLET',
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: palletSrController,
                  decoration: InputDecoration(
                      labelText: 'PALLET SR',
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (modelPalletController.text.trim().isEmpty ||
                        palletSrController.text.trim().isEmpty) {
                      Flushbar(
                        message: 'Please enter both MODEL PALLET and PALLET SR',
                        backgroundColor: Colors.red,
                        margin: const EdgeInsets.all(10),
                        borderRadius: BorderRadius.circular(8),
                        duration: const Duration(seconds: 3),
                        flushbarPosition: FlushbarPosition.TOP,
                      ).show(context);
                      return;
                    }
                    String combinedCode =
                        '${modelPalletController.text.trim()} - ${palletSrController.text.trim()}';
                    print("Manual entry: $combinedCode");
                    controller.addPallet(combinedCode);
                    Navigator.pop(dialogContext); // Close the dialog
                    // Navigate to the list screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PalletDispatchScreen(
                              challanId: widget.challanId,
                              scannedPallets: controller.scannedPallets)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12)),
                  child: const Text("CONFIRM",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- QR Scanner Screen ---
class CustomScannerScreen extends StatefulWidget {
  final String challanId;
  final List scannedPallets;
  const CustomScannerScreen(
      {super.key, required this.challanId, required this.scannedPallets});

  @override
  _CustomScannerScreenState createState() => _CustomScannerScreenState();
}

class _CustomScannerScreenState extends State<CustomScannerScreen> {
  final PalletDispatchController controller = Get.find(tag: 'palletDispatch');

  @override
  void initState() {
    super.initState();
    controller.setChallanId(widget.challanId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.scannedPallets.isEmpty ||
          controller.scannedPallets.length < widget.scannedPallets.length) {
        controller.scannedPallets
            .assignAll(widget.scannedPallets as Iterable<String>);
      }
    });
  }

  void _navigateBackToList() {
    // FIXED: Defer navigation to avoid build conflicts
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PalletDispatchScreen(
              challanId: widget.challanId,
              scannedPallets: controller.scannedPallets,
            ),
          ),
        );
      }
    });
  }

  void _navigateBackToDetails() {
    // FIXED: Defer navigation to avoid build conflicts
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PalletDispatchScreen2(
              challanId: widget.challanId,
              scannedPallets: controller.scannedPallets,
              // Use live data from the controller, not hardcoded data.
              challanDetails: controller.challanDetails.value!,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateBackToDetails();
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scan Pallet QR'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateBackToDetails,
          ),
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: controller.scannerController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && barcodes[0].rawValue != null) {
                  final code = barcodes[0].rawValue!;
                  controller.scannerController.stop();
                  if (!controller.scannedPallets.contains(code)) {
                    _showScannedCodeDialog(context, code);
                  } else {
                    _showDuplicateCodeDialog(context);
                  }
                }
              },
            ),
            Positioned(
              top: 30,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.image, color: Colors.white),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image == null) return;
                      try {
                        final BarcodeCapture? capture = await controller
                            .scannerController
                            .analyzeImage(image.path);
                        if (capture != null &&
                            capture.barcodes.isNotEmpty &&
                            capture.barcodes[0].rawValue != null) {
                          final code = capture.barcodes[0].rawValue!;
                          if (!controller.scannedPallets.contains(code)) {
                            _showScannedCodeDialog(context, code);
                          } else {
                            _showDuplicateCodeDialog(context);
                          }
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'No QR code found in the selected image'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Error analyzing image: ${e.toString()}'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                  ),
                  IconButton(
                      icon: const Icon(Icons.flash_on, color: Colors.white),
                      onPressed: () =>
                          controller.scannerController.toggleTorch()),
                  IconButton(
                      icon: const Icon(Icons.flip_camera_android,
                          color: Colors.white),
                      onPressed: () =>
                          controller.scannerController.switchCamera()),
                ],
              ),
            ),
            Center(
                child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.cyan, width: 4),
                        borderRadius: BorderRadius.circular(10)))),
            Positioned(
                bottom: 140,
                left: 30,
                right: 30,
                child: Row(children: [
                  Expanded(
                      child: Obx(() => Slider(
                          value: controller.zoom.value,
                          min: 0.1,
                          max: 1.0,
                          onChanged: controller.setZoom)))
                ])),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white),
                      onPressed: _navigateBackToDetails,
                      child: const Text('BACK')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white),
                    onPressed: _navigateBackToList,
                    child: const Text('VIEW'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> parseQRString(String qrString) {
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
      'originalCode': qrString,
    };
  }

  void _showScannedCodeDialog(BuildContext context, String code) {
    Map<String, String> parsedData = parseQRString(code);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Pallet scanned successfully!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MODEL PALLET: ${parsedData['modelPallet']}'),
              const SizedBox(height: 8),
              Text('PALLET SR: ${parsedData['palletSr']}'),
              const SizedBox(height: 12),
              const Text('Original QR Code:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(parsedData['originalCode']!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                String displayCode =
                    '${parsedData['modelPallet']} - ${parsedData['palletSr']}';
                controller.addPallet(displayCode);
                Navigator.of(dialogContext).pop(); // Close dialog
                _navigateBackToList(); // Navigate to list view
              },
            ),
          ],
        );
      },
    );
  }

  void _showDuplicateCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Duplicate Pallet'),
          content: const Text('This pallet has already been scanned.'),
          actions: [
            TextButton(
              child: const Text('Back'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                _navigateBackToList(); // Navigate to list view
              },
            )
          ],
        );
      },
    );
  }
}

// --- Screen with List of Scanned Pallets ---
class PalletDispatchScreen extends StatefulWidget {
  final String challanId;
  final List scannedPallets;
  const PalletDispatchScreen(
      {super.key, required this.challanId, required this.scannedPallets});
  @override
  _PalletDispatchScreenState createState() => _PalletDispatchScreenState();
}

class _PalletDispatchScreenState extends State<PalletDispatchScreen> {
  final PalletDispatchController controller = Get.find(tag: 'palletDispatch');

  @override
  void initState() {
    super.initState();
    controller.setChallanId(widget.challanId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.scannedPallets.isEmpty ||
          controller.scannedPallets.length < widget.scannedPallets.length) {
        controller.scannedPallets
            .assignAll(widget.scannedPallets as Iterable<String>);
      }
    });
  }

  void _navigateBackToDetails() {
    // FIXED: Defer navigation to avoid build conflicts
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PalletDispatchScreen2(
              challanId: widget.challanId,
              scannedPallets: controller.scannedPallets,
              // Use live data from the controller.
              challanDetails: controller.challanDetails.value!,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateBackToDetails();
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pallet Dispatch"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateBackToDetails,
          ),
        ),
        // The body now correctly calls the simplified PalletDispatch3 widget.
        body: const PalletDispatch3(),
      ),
    );
  }
}

// --- Widget to Display the Pallet List ---
class PalletDispatch3 extends StatelessWidget {
  // Simplified the widget by removing the unnecessary context parameter.
  const PalletDispatch3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PalletDispatchController controller = Get.find(tag: 'palletDispatch');
    print(
        "PalletDispatch3 build, scannedPallets length: ${controller.scannedPallets.length}");

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text("Challan No : ${controller.challanId.value}",
                  style: const TextStyle(
                      fontFamily: "DMSans",
                      fontSize: 16,
                      fontWeight: FontWeight.w600))),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 2,
                            offset: const Offset(0, 2))
                      ]),
                  child: Obx(() => ListView.builder(
                        itemCount: controller.scannedPallets.length,
                        itemBuilder: (context, index) {
                          final palletData =
                              controller.scannedPallets[index].split(' - ');
                          final modelPallet = palletData[0];
                          final palletSr =
                              palletData.length > 1 ? palletData[1] : 'N/A';

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "MODEL PALLET:",
                                        style: TextStyle(
                                            fontFamily: "DMSans",
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black54),
                                      ),
                                      Text(
                                        modelPallet,
                                        style: const TextStyle(
                                            fontFamily: "DMSans",
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "PALLET SR:",
                                        style: TextStyle(
                                            fontFamily: "DMSans",
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black54),
                                      ),
                                      Text(
                                        palletSr,
                                        style: const TextStyle(
                                            fontFamily: "DMSans",
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Colors.blue, size: 15),
                                    const SizedBox(width: 5),
                                    const Text(
                                      "Scanned & Assigned",
                                      style: TextStyle(
                                          fontFamily: "DMSans",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.blue),
                                    ),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () => showDeletePalletPopup(
                                          context,
                                          () => _removePalletSafely(controller, index)),
                                      child: const Icon(Icons.delete,
                                          color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      )),
                ),
              ),
              const SizedBox(height: 15),
              Obx(() => Center(
                  child: Text("Total : ${controller.scannedPallets.length}",
                      style: const TextStyle(
                          fontFamily: "DMSans",
                          fontSize: 18,
                          fontWeight: FontWeight.bold)))),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CustomScannerScreen(
                                    challanId: controller.challanId.value,
                                    scannedPallets:
                                        controller.scannedPallets)));
                      },
                      icon: const Icon(Icons.qr_code_scanner,
                          color: Colors.white),
                      label: const Text("SCAN PALLET",
                          style: TextStyle(fontFamily: "DMSans", fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => showPalletsAssignedPopup(
                          context, controller.scannedPallets.length),
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(216, 219, 226, 1),
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const Text("CONFIRM",
                          style: TextStyle(
                              fontFamily: "DMSans",
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(27, 27, 30, 1))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // FIXED: Safe pallet removal to prevent setState during build
  void _removePalletSafely(PalletDispatchController controller, int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.removePallet(index);
    });
  }

  void showPalletsAssignedPopup(BuildContext context, int palletCount) {
    final controller =
        Get.find<PalletDispatchController>(tag: 'palletDispatch');
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              contentPadding: const EdgeInsets.all(20),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("PALLETS ASSIGNED",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7FA2AB),
                          letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 14,
                          fontFamily: "DMSans",
                          color: Colors.black),
                      children: [
                        TextSpan(
                            text: "$palletCount pallet(s) ",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(
                            text: "have been assigned to the selected Challan")
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isSubmitting)
                    Column(
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text("Submitting pallets...",
                            style: TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    )
                  else if (controller.errorMessage.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (!isSubmitting)
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isSubmitting = true;
                        });
                        final success =
                            await controller.assignPalletsToChallan();
                        if (!context.mounted) return;

                        if (success) {
                          Flushbar(
                            message: "Pallets successfully assigned to challan",
                            duration: const Duration(seconds: 3),
                            backgroundColor: Colors.green,
                          ).show(context);
                          controller.resetPallets();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) =>
                                    HomeScreen()), // Ensure HomeScreen exists
                            (Route<dynamic> route) => false,
                          );
                        } else {
                          setState(() {
                            isSubmitting = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10)),
                      child: const Text("CONFIRM",
                          style: TextStyle(color: Colors.white)),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showDeletePalletPopup(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("DELETE PALLET ?",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: 1.2)),
              const SizedBox(height: 10),
              const Text("Are you sure you want to delete this pallet ?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: "DMSans",
                      color: Colors.black54)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3D4252),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const Text("YES"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black54,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const Text("NO"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}