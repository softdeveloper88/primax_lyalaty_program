import 'package:flutter/material.dart';
import 'package:primax_lyalaty_program/widgets/comman_back_button.dart';
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
    "Fan": ["A/C Fan", "DC Fan", "Inverter Fan"],
    "Tubelight": ["36W", "40W",'60W'],
    "LED Bulb": ["7W", "10W","12W", "15W","18W"],
    "Refrigerator": ["Inverter Refrigerator", "AC Refrigerator"],
    "Washing Machine": ["Inverter Washing Machine", "AC Washing Machine"],
    "Iron": ["Iron(Plastic Body)", "Iron(Metal Body)"],
    "Split AC": ["1.0 Ton", "1.5 Ton", "2.0 Ton","4.0 Ton"],
    "Inverter AC": ["1.0 Ton", "1.5 Ton","2.0 Ton","4.0 Ton"],

    "Water Pump Total Quality": ["0.5 HP", "1.0 HP","1.5 HP","2.0 HP"],
    "Microwave": ["Microwave"],
    "Computer": ["Computer"],
    "Laptop": ["Laptop"]
  };

  final Map<String, int> powerRatings = {
    // Fan options
    "A/C Fan": 110,
    "DC Fan": 55,
    "Inverter Fan": 30,
    
    // Tubelight options
    "36W": 36,
    "40W": 40,
    "60W": 60,
    
    // LED Bulb options
    "5W": 5,
    "7W": 7,
    "12W": 12,
    "15W": 15,
    "18W": 18,
    
    // Refrigerator options
    "Inverter Refrigerator": 350,
    "AC Refrigerator": 780,
    
    // Washing Machine options
    "Inverter Washing Machine": 500,
    "AC Washing Machine": 1200,
    
    // Iron options
    "Iron(Plastic Body)": 800,
    "Iron(Metal Body)": 1200,
    
    // Split AC options
    "1.0 Ton": 1250,
    "1.5 Ton": 2000,
    "2.0 Ton": 2500,
    "4.0 Ton": 5000,
    
    // Inverter AC options (more efficient)
    // Using same keys but different values handled in calculation
    
    // Water Pump options
    "0.5 HP": 375,
    "1.0 HP": 750,
    "1.5 HP": 1125,
    "2.0 HP": 1500,
    
    // Other appliances
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

  int _getPowerRating(String applianceType, String selectedOption) {
    // Handle Inverter AC with different power ratings than Split AC
    if (applianceType == "Inverter AC") {
      switch (selectedOption) {
        case "1.0 Ton":
          return 900;
        case "1.5 Ton":
          return 1200;
        case "2.0 Ton":
          return 1800;
        case "4.0 Ton":
          return 3600;
        default:
          return 1200;
      }
    }
    
    // For all other appliances, use the powerRatings map
    return powerRatings[selectedOption] ?? 100;
  }

  void _goToSummary() {
    Map<String, dynamic> selectedData = {};

    for (var key in applianceOptions.keys) {
      if (selectedAppliances[key] != null && selectedAppliances[key]!.isNotEmpty) {
        int quantity = int.tryParse(quantityControllers[key]!.text) ?? 0;
        if (quantity > 0) {
          int powerPerUnit = _getPowerRating(key, selectedAppliances[key]!);
          selectedData[key] = {
            "type": selectedAppliances[key]!,
            "power": powerPerUnit * quantity,
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
        leading: CommonBackButton(onPressed: (){Navigator.pop(context);}),
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
