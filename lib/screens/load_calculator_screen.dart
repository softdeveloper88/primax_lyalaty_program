import 'package:flutter/material.dart';
import 'caculation_screen/summary_screen.dart';

class LoadCalculatorScreen extends StatefulWidget {
  const LoadCalculatorScreen({super.key});

  @override
  State<LoadCalculatorScreen> createState() => _LoadCalculatorScreenState();
}

class _LoadCalculatorScreenState extends State<LoadCalculatorScreen> {
  final Map<String, TextEditingController> quantityControllers = {};
  final Map<String, String?> selectedAppliances = {};

  final Map<String, List<String>> applianceOptions = {
    "Fan": ["A/C Fan", "Ceiling Fan", "Exhaust Fan"],
    "Tubelight": ["36W", "40W"],
    "LED Bulb": ["7W", "10W", "15W"],
    "Refrigerator": ["Inverter Refrigerator", "Double Door"],
    "Washing Machine": ["Inverter Washing Machine", "Top Load"],
    "Iron": ["Dry Iron", "Steam Iron"],
    "Split AC": ["1.0 Ton", "1.5 Ton", "2 Ton"],
    "Inverter AC": ["1.0 Ton", "1.5 Ton"],
    "Water Pump": ["0.5 HP", "1 HP"],
    "Microwave": ["Microwave"],
    "Computer": ["Computer"],
    "Laptop": ["Laptop"]
  };

  final Map<String, int> powerRatings = {
    "Fan": 110,
    "36W": 36,
    "7W": 7,
    "Inverter Refrigerator": 350,
    "Inverter Washing Machine": 500,
    "Dry Iron": 800,
    "1.0 Ton": 1250,
    "1.5 Ton": 1500,
    "1 HP": 750,
    "Microwave": 1500,
    "Computer": 250,
    "Laptop": 100,
  };

  @override
  void initState() {
    super.initState();
    for (var key in applianceOptions.keys) {
      quantityControllers[key] = TextEditingController(text: "0");
    }
  }

  void _goToSummary() {
    Map<String, dynamic> selectedData = {};

    for (var key in applianceOptions.keys) {
      if (selectedAppliances[key] != null && selectedAppliances[key]!.isNotEmpty) {
        int quantity = int.tryParse(quantityControllers[key]!.text) ?? 0;
        if (quantity > 0) {
          selectedData[key] = {
            "type": selectedAppliances[key]!,
            "power": (powerRatings[selectedAppliances[key]!] ?? 1)*quantity,
            "quantity": quantity,
          };
        }
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryScreen(selectedData: selectedData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text("Load Calculator",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        actions: [
          TextButton(
            onPressed: _goToSummary,
            child: const Text(
              "Next",
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: applianceOptions.keys.map((key) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  "Select $key Type",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  value: selectedAppliances[key],
                  hint: const Text("Select value"),
                  decoration: _inputDecoration(),
                  items: applianceOptions[key]!
                      .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAppliances[key] = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  "$key Total Quantity",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                _quantityInputField(quantityControllers[key]!),
                const SizedBox(height: 10),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _quantityInputField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration().copyWith(
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 20),
              onPressed: () {
                int currentValue = int.tryParse(controller.text) ?? 0;
                if (currentValue > 0) {
                  setState(() {
                    controller.text = (currentValue - 1).toString();
                  });
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: () {
                int currentValue = int.tryParse(controller.text) ?? 0;
                setState(() {
                  controller.text = (currentValue + 1).toString();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }
}
