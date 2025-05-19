import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Map<String, dynamic>? orderData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .get();
    if (doc.exists) {
      setState(() {
        orderData = doc.data() as Map<String, dynamic>;
        isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .update({'orderStatus': newStatus});
    setState(() {
      orderData?['orderStatus'] = newStatus;
      // Implement notification logic here
    });
  }

  void _showStatusChangeDialog(String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Change Order Status"),
        content: Text(
            "Are you sure you want to change the status to $newStatus?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(newStatus);
            },
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Order Details")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Order #${orderData?['orderCode']}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text("Customer Information",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name: ${orderData?['customerName']}"),
                    Text("Email: ${orderData?['customerEmail']}"),
                    Text("Phone: ${orderData?['customerPhone']}"),
                    Text("Address: ${orderData?['address']}"),
                  ],
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text("Order Details",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Payment Method: ${orderData?['paymentMethod']}"),
                    Text("Total Amount: PKR${orderData?['totalAmount']}"),
                    Text("Order Status: ${orderData?['orderStatus']}"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text("💳 Payment Method Id: ",
                              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12)),
                        ),
                        Expanded(
                          child: Text(" ${orderData?['paymentMethodId']}",
                              style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 14,color: Colors.blue)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: orderData?['paymentMethodId']));
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   const SnackBar(content: Text("Copied to clipboard")),
                            // );
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text("💳 customer ID: ",
                              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12)),
                        ),
                        Expanded(
                          child: Text(" ${orderData?['customer']}",
                              style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 14,color: Colors.blue)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: orderData?['customer']));
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   const SnackBar(content: Text("Copied to clipboard")),
                            // );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Payment Receipt (if available)
            if (orderData?['payment_receipt_url'] != null && orderData!['payment_receipt_url'].toString().isNotEmpty)
              Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Payment Receipt", 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          // Show full-screen image
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              insetPadding: EdgeInsets.zero,
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 0.5,
                                    maxScale: 4,
                                    child: Image.network(
                                      "${orderData?['payment_receipt_url']}?t=${DateTime.now().millisecondsSinceEpoch}",
                                      fit: BoxFit.contain,
                                      height: double.infinity,
                                      width: double.infinity,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.white, size: 30),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              "${orderData?['payment_receipt_url']}?t=${DateTime.now().millisecondsSinceEpoch}",
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text('Error loading image'),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (orderData?['orderStatus'] == "Pending") ...[
              MaterialButton(
                color: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
                ),
                onPressed: () => _showStatusChangeDialog("Accepted"),
                child: Text("Accept Order",style: TextStyle(color: Colors.white),),
              ),
              MaterialButton(
                color: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                ),
                onPressed: () => _showStatusChangeDialog("Rejected"),
                child: Text("Reject Order",style: TextStyle(color: Colors.white),),
              ),
            ],
            if (orderData?['orderStatus'] == "Accepted") ...[
              MaterialButton(
                color: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                ),
                onPressed: () => _showStatusChangeDialog("Completed"),
                child: Text("Complete Order",style: TextStyle(color: Colors.white)),
              ),
            ],
            if (orderData?['orderStatus'] == "Cancellation Requested") ...[
              MaterialButton(
                color: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                ),
                onPressed: () => _showStatusChangeDialog("Cancelled"),
                child: Text("Approve Cancellation",style: TextStyle(color: Colors.white)),
              ),
            ],
            SizedBox(height: 20),
            Text("Ordered Items:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...((orderData?['orderedItems'] as List).map((item) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Image.network(item['imageUrl'],
                      width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(item['name']),
                  subtitle: Text(
                      "Quantity: ${item['quantity']}, Price: PKR${item['price']}"),
                ),
              );
            }).toList()),
          ],
        ),
      ),
    );
  }
}
