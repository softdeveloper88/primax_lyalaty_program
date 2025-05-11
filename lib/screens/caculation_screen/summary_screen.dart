import 'package:flutter/material.dart';

import '../../widgets/comman_back_button.dart';

class SummaryScreen extends StatelessWidget {
  final Map<String, dynamic> selectedData;

  const SummaryScreen({super.key, required this.selectedData});

  @override
  Widget build(BuildContext context) {
    double totalWatts = _calculateTotalWatts();
    double totalKW = totalWatts / 1000;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CommonBackButton(onPressed: (){Navigator.pop(context);}),
        title: const Text(
          "Summary",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Table Header
            _buildHeaderRow(),

            // Display Summary Data
            ...selectedData.entries.map((entry) => _buildSummaryRow(entry.key, entry.value)),

            const SizedBox(height: 20),

            // Total Watts & KW
            _buildTotalRow("Total Watts", totalWatts.toStringAsFixed(2)),
            _buildTotalRow("Total KW", totalKW.toStringAsFixed(2)),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(5)),
      child: Row(
        children: const [
          Expanded(child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
          Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
            Text("${data['power']}W", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
        Text(
          data['type'],
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(child: Text("Total Quantity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
            Text("${data['quantity']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildTotalRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  double _calculateTotalWatts() {
    double total = 0;
    for (var data in selectedData.values) {
      total += data['power'] * data['quantity'];
    }
    return total;
  }
}
