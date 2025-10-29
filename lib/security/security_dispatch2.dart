// lib/security/security_dispatch2.dart

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manuscan/security/security_dispatch.dart';
import 'package:manuscan/security/securityscreen.dart';
import '../controllers/security_dispatch_controller.dart';

class SecurityDispatchScreen2 extends StatefulWidget {
  final String challanId;
  final Map<String, dynamic> challanDetails;

  const SecurityDispatchScreen2({
    Key? key,
    required this.challanId,
    required this.challanDetails,
  }) : super(key: key);

  @override
  _SecurityDispatchScreen2State createState() =>
      _SecurityDispatchScreen2State();
}

class _SecurityDispatchScreen2State extends State<SecurityDispatchScreen2> {
  final SecurityDispatchController controller =
      Get.find(tag: 'securityDispatch');

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const SecurityDispatchScreen1()),
              );
            },
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          color: Colors.white,
          child: Column(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              // FIXED: Direct property access instead of casting.
                              _buildDetailRow("Vendor Code",
                                  widget.challanDetails['vendor_code']),
                              _buildDetailRow("Vendor Name",
                                  widget.challanDetails['vendor_name']),
                              _buildDetailRow(
                                  "GSTIN", widget.challanDetails['gstin_no']),
                              _buildDetailRow(
                                  "PAN", widget.challanDetails['pan_no']),
                              const Divider(height: 24),
                              _buildDetailRow("Challan No",
                                  widget.challanDetails['challan_no']),
                              _buildDetailRow("Date",
                                  widget.challanDetails['challan_date']),
                              _buildDetailRow("Vehicle",
                                  widget.challanDetails['vehicle_no']),
                              _buildDetailRow("Transporter",
                                  widget.challanDetails['transporter']),
                              const Divider(height: 24),
                              _buildDetailRow("Employee Code",
                                  widget.challanDetails['emp_code']),
                              _buildDetailRow("Employee Name",
                                  widget.challanDetails['emp_name']),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              _buildDetailRow("Material Code",
                                  widget.challanDetails['material_code']),
                              _buildDetailRow(
                                  "Description",
                                  widget
                                      .challanDetails['material_description']),
                              _buildDetailRow("HSN Code",
                                  widget.challanDetails['hsn_code']),
                              _buildDetailRow(
                                  "Pallet Quantity",
                                  widget.challanDetails['pallet_count']
                                      .toString()),
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
                      child: ElevatedButton(
                        onPressed: () => _showConfirmDialog(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 25, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "APPROVE",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showConfirmDialog(context, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 25, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "REJECT",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
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

  void _showConfirmDialog(BuildContext context, bool isApprove) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Padding(
            padding: const EdgeInsets.all(20),
            child: Obx(() {
              if (controller.isSubmitting.value) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text("Dispatching...", style: TextStyle(fontSize: 16)),
                  ],
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isApprove ? "Approve Dispatch?" : "Reject Challan?",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  const Text("Are you sure?", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (isApprove) {
                            // Updated API call - no vehicle number required
                            bool success = await controller
                                .dispatchChallan(widget.challanId);
                            Navigator.of(dialogContext).pop();
                            if (success) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SecurityScreen()),
                              );
                              Flushbar(
                                message: 'Challan dispatched successfully!',
                                backgroundColor: Colors.green,
                                margin: const EdgeInsets.all(10),
                                borderRadius: BorderRadius.circular(8),
                                duration: const Duration(seconds: 3),
                                flushbarPosition: FlushbarPosition.TOP,
                              ).show(context);
                            } else {
                              Flushbar(
                                message: controller.errorMessage.value,
                                backgroundColor: Colors.red,
                                margin: const EdgeInsets.all(10),
                                borderRadius: BorderRadius.circular(8),
                                duration: const Duration(seconds: 3),
                                flushbarPosition: FlushbarPosition.TOP,
                              ).show(context);
                            }
                          } else {
                            Navigator.of(dialogContext).pop();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SecurityScreen()),
                            );
                            Flushbar(
                              message: 'Challan rejected successfully!',
                              backgroundColor: Colors.red,
                              margin: const EdgeInsets.all(10),
                              borderRadius: BorderRadius.circular(8),
                              duration: const Duration(seconds: 3),
                              flushbarPosition: FlushbarPosition.TOP,
                            ).show(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("YES"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("NO"),
                      ),
                    ],
                  ),
                ],
              );
            }),
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
