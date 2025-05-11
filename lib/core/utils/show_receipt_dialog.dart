import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/core/order_model.dart';
import 'package:primax_lyalaty_program/screens/dashboard_screen/dashboard_screen.dart';
import 'package:primax_lyalaty_program/widgets/images.dart';

void showReceiptDialog(BuildContext context, OrderModel order) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Animated Success Icon (Lottie)
              Image.asset(
                Images.dialogFrame,  // Place a Lottie animation in assets
                width: 100,
                height: 100,
                // repeat: false,
              ),
              const SizedBox(height: 10),

              // ✅ Title
              const Text(
                "Payment Successful!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
              ),

              const SizedBox(height: 15),
              const Divider(thickness: 1),

              // ✅ Order Summary
              _buildDetailRow("🆔 Order ID:", order.id??"", isCopyable: true),
              _buildDetailRow("💲Amount Paid:", "PKR${order.amountReceived??0 / 100} ${order.currency?.toUpperCase()}"),
              _buildDetailRow("💳 Payment Method:", order.paymentMethod??''),
              _buildDetailRow("📌 Payment Status:", order.paymentStatus??'', color: statusColor(order.paymentStatus??'')),
              _buildDetailRow("👤 Customer ID:", order.customerId??"", isCopyable: true),
              _buildDetailRow("🔗 Latest Charge:", order.latestCharge??''),

              const Divider(thickness: 1, height: 25),
              // ✅ Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _customButton("Back To Home", Icons.check, Colors.green, () {
                    DashboardScreen().launch(context,
                        isNewTask: true,
                        pageRouteAnimation: PageRouteAnimation.Slide);
                  }),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ✅ Helper function to build detailed rows with copy option
Widget _buildDetailRow( String label, String value, {Color? color, bool isCopyable = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 5,
          child: Row(
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(fontSize: 16, color: color ?? Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isCopyable)
                IconButton(
                  icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text("Copied to clipboard")),
                    // );
                  },
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ✅ Helper function for additional details
Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

// ✅ Dynamic color for payment status
Color statusColor(String status) {
  switch (status.toLowerCase()) {
    case "succeeded":
      return Colors.green;
    case "pending":
      return Colors.orange;
    case "failed":
      return Colors.red;
    default:
      return Colors.black;
  }
}

// ✅ Custom Button Widget
Widget _customButton(String text, IconData icon, Color color, VoidCallback onTap) {
  return ElevatedButton.icon(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    icon: Icon(icon, color: Colors.white, size: 20),
    label: Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)),
  );
}
