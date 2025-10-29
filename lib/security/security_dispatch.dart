// lib/security/security_dispatch.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manuscan/security/securityscreen.dart';
import '../controllers/security_dispatch_controller.dart';
import 'security_dispatch2.dart';

class SecurityDispatchEntry extends StatelessWidget {
  const SecurityDispatchEntry({super.key});

  @override
  Widget build(BuildContext context) {
    // Directly navigate to SecurityDispatchScreen1 without showing dialog
    Future.microtask(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SecurityDispatchScreen1(),
        ),
      );
    });
    return const SizedBox.shrink();
  }
}

class SecurityDispatchScreen1 extends StatefulWidget {
  const SecurityDispatchScreen1({super.key});

  @override
  State<SecurityDispatchScreen1> createState() =>
      _SecurityDispatchScreen1State();
}

class _SecurityDispatchScreen1State extends State<SecurityDispatchScreen1> {
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  final SecurityDispatchController controller =
      Get.find(tag: 'securityDispatch');

  @override
  void initState() {
    super.initState();
    // Defer fetch until after the first build to prevent "setState during build" error.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.fetchActiveChallans();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pallet Dispatch",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SecurityScreen()),
            );
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Active Challans",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Obx(() => controller.isLoadingChallans.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => controller.fetchActiveChallans(),
                      )),
              ],
            ),
            const SizedBox(height: 25),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingChallans.value &&
                    controller.activeChallans.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final totalPages =
                    (controller.activeChallans.length / _itemsPerPage).ceil();
                // Safe sublist to prevent out-of-bounds errors.
                final startIndex = _currentPage * _itemsPerPage;
                final endIndex = (startIndex + _itemsPerPage)
                    .clamp(0, controller.activeChallans.length);
                final paginatedData =
                    controller.activeChallans.sublist(startIndex, endIndex);

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Expanded(
                              flex: 1,
                              child: Text('Sr. No.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text('Client',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text('Challan No',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('Pallets',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: paginatedData.isEmpty
                            ? const Center(
                                child: Text('No active challans found'))
                            : ListView.builder(
                                itemCount: paginatedData.length,
                                itemBuilder: (context, index) {
                                  final item = paginatedData[index];
                                  return GestureDetector(
                                    onTap: () => handleChallanFetch(
                                        item["challan_no"]!, context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey.shade300)),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                                '${index + 1 + (_currentPage * _itemsPerPage)}',
                                                textAlign: TextAlign.center),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                                item["vendor_name"] ?? '',
                                                textAlign: TextAlign.center,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                                item["challan_no"] ?? '',
                                                textAlign: TextAlign.center,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                                item["pallet_count"] ?? '',
                                                textAlign: TextAlign.center),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      if (totalPages > 1)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(10)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: _currentPage > 0
                                    ? () => setState(() => _currentPage--)
                                    : null,
                              ),
                              Text("Page ${_currentPage + 1} of $totalPages"),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: _currentPage < totalPages - 1
                                    ? () => setState(() => _currentPage++)
                                    : null,
                              ),
                              Text(
                                "Showing ${paginatedData.length} of ${controller.activeChallans.length}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 25),
            const Center(
              child: Text("OR",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit_document),
                onPressed: () {
                  showChallanIdPopup(context);
                },
                label: const Text("ENTER CHALLAN No",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> handleChallanFetch(
      String challanId, BuildContext context) async {
    try {
      // FIXED: Now awaits a Future<bool> from the controller
      bool success = await controller.fetchChallanDetails(challanId);
      if (!mounted) return;

      if (success) {
        if (controller.challanDetails.value == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Challan details not available'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SecurityDispatchScreen2(
              challanId: challanId,
              challanDetails: controller.challanDetails.value!,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage.value),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void showChallanIdPopup(BuildContext context) {
    TextEditingController challanIdController = TextEditingController();
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
                const Text("Enter Challan No",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                TextField(
                  controller: challanIdController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[300],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () async {
                    final challanId = challanIdController.text.trim();
                    if (challanId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a Challan No'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(dialogContext); // Close dialog first
                    await handleChallanFetch(challanId, context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
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
}
