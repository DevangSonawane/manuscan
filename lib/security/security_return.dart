import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/security_return_controller.dart';
import 'security_return2.dart';

class SecurityReturnEntry extends StatelessWidget {
  const SecurityReturnEntry({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SecurityReturnScreen1();
  }
}

class SecurityReturnScreen1 extends StatefulWidget {
  const SecurityReturnScreen1({Key? key}) : super(key: key);

  @override
  _SecurityReturnScreen1State createState() => _SecurityReturnScreen1State();
}

class _SecurityReturnScreen1State extends State<SecurityReturnScreen1> {
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  late SecurityReturnController controller;

  @override
  void initState() {
    super.initState();
    SecurityReturnController.registerIfNeeded();
    controller = Get.find(tag: 'securityReturn');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.fetchReceipts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pallet Return',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() {
                  final isSearch = controller.isSearching.value &&
                      controller.searchResults.isNotEmpty;
                  return Text(
                    isSearch ? 'Search Results' : 'Open Receipts',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  );
                }),
                Row(
                  children: [
                    Obx(() {
                      if (controller.isSearching.value) {
                        return IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          tooltip: 'Clear search',
                          onPressed: () {
                            controller.clearSearch();
                            setState(() => _currentPage = 0);
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    Obx(() {
                      if (controller.isLoadingReceipts.value ||
                          controller.isSearching.value) {
                        return const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }
                      return IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          controller.clearSearch();
                          controller.fetchReceipts();
                          setState(() => _currentPage = 0);
                        },
                      );
                    }),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 25),
            Expanded(
              child: Obx(() {
                final isSearch = controller.isSearching.value;
                final dataToShow =
                    isSearch ? controller.searchResults : controller.receipts;
                final isLoading = controller.isLoadingReceipts.value;

                if (isLoading && dataToShow.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!isSearch && dataToShow.isEmpty) {
                  return const Center(child: Text('No open receipts found'));
                }

                if (isSearch && dataToShow.isEmpty && !isLoading) {
                  return const Center(
                      child: Text('No open receipts found for this vehicle'));
                }

                final totalPages = (dataToShow.length / _itemsPerPage).ceil();
                final paginatedData = dataToShow
                    .skip(_currentPage * _itemsPerPage)
                    .take(_itemsPerPage)
                    .toList();

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10)),
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
                            child: Text('Vehicle No',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('Total Pallets',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: paginatedData.length,
                        itemBuilder: (context, index) {
                          final item = paginatedData[index];
                          final srNo =
                              index + 1 + (_currentPage * _itemsPerPage);
                          return InkWell(
                            onTap: () {
                              controller.setSelectedReceipt(item);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SecurityReturnScreen2(receipt: item),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      srNo.toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      item['vehicle_no'] ?? 'N/A',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      item['total_pallets'].toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
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
                            Text('Page ${_currentPage + 1} of $totalPages'),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: _currentPage < totalPages - 1
                                  ? () => setState(() => _currentPage++)
                                  : null,
                            ),
                            Text(
                              'Showing ${paginatedData.length} of ${dataToShow.length}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 25),
            const Center(
                child: Text('OR',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('SEARCH BY Vehicle No',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () => showVehicleSearchPopup(context),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void showVehicleSearchPopup(BuildContext context) {
    final vehicleCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Search Vehicle No',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: vehicleCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Enter vehicle number',
                filled: true,
                fillColor: Colors.grey[300],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final entered = vehicleCtrl.text.trim();
                if (entered.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a vehicle number'),
                        backgroundColor: Colors.red),
                  );
                  return;
                }
                Navigator.pop(context);
                setState(() => _currentPage = 0);
                await controller.searchReceiptsByVehicle(entered);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('SEARCH'),
            ),
          ]),
        ),
      ),
    );
  }
}