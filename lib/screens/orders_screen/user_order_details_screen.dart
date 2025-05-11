import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:primax_lyalaty_program/core/utils/comman_data.dart';
import 'package:primax_lyalaty_program/widgets/comman_back_button.dart';

class UserOrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const UserOrderDetailsScreen({super.key, required this.orderId});

  @override
  _UserOrderDetailsScreenState createState() => _UserOrderDetailsScreenState();
}

class _UserOrderDetailsScreenState extends State<UserOrderDetailsScreen> {
  Map<String, dynamic>? orderData;
  bool isLoading = true;
  double ratings = 0.0;
  Map<String, double> orderItemId = {};

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

  Future<void> _submitRatings(String id) async {
    if (orderData?['orderStatus'] == "Completed") {
      var docRef = FirebaseFirestore.instance.collection('products').doc(id);
      DocumentSnapshot doc = await docRef.get();
      List<dynamic> ratingsList =
          doc.exists ? (doc.data() as Map<String, dynamic>)['rate'] ?? [] : [];

      ratingsList.add(ratings);

      List<dynamic> updatedItems = List.from(orderData?['orderedItems'] ?? []);

      for (var i = 0; i < updatedItems.length; i++) {
        var items = updatedItems[i];
        if (orderItemId.containsKey(items['id'])) {
          updatedItems[i] = {
            ...items,
            'rating': ratings,
          };
          break;
        }
      }
      await FirebaseFirestore.instance.collection('products').doc(id).update({
        'rate': ratingsList,
      });
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
        'orderedItems': updatedItems,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thank you for your feedback!")),
      );
    }
  }

  Widget _buildOrderStatusChip(String status) {
    Color statusColor = Colors.grey;
    switch (status) {
      case "Pending":
        statusColor = Colors.orange;
        break;
      case "Shipped":
        statusColor = Colors.blue;
        break;
      case "Completed":
        statusColor = Colors.green;
        break;
      case "Cancellation Requested":
        statusColor = Colors.red;
        break;
      case "Cancel Approved":
        statusColor = Colors.greenAccent;
        break;
    }
    return Chip(
      label: Text(
        status=='Cancellation Requested'?'Order Canceled Pending':status,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: statusColor,
    );
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .update({'orderStatus': newStatus});
    setState(() {
      orderData?['orderStatus'] = newStatus;
      sendNotificationToAllUsers(
        userId: orderData?['userId'],
        title: 'Your order  changed to $newStatus',
        type: 'order_status',
        id: widget.orderId,
        newPrice: 0.0,
        oldPrice: 0.0,
      );
      sendNotificationToAllUsers(
        userId: '1',
        title: 'User send Request to cancelled order',
        type: 'order_status',
        id: widget.orderId,
        newPrice: 0.0,
        oldPrice: 0.0,
      );
    });
  }

  void _showStatusChangeDialog(String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cancel Order"),
        content: Text("Are you sure want to cancel the order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: CommonBackButton(onPressed: () => Navigator.pop(context)),
        title: Text("Order #${orderData?['orderCode']}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Info
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Customer: ${orderData?['customerName']}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("📧 Email: ${orderData?['customerEmail']}"),
                      Text("📞 Phone: ${orderData?['customerPhone']}"),
                      Text("📍 Address: ${orderData?['address']}"),
                      const Divider(height: 20),
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
                      ),Row(
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
                       Divider(),
                       Text("💰 Total: PKR${orderData?['totalAmount']}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text("Order Status: ",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          _buildOrderStatusChip(orderData?['orderStatus']),
                        ],
                      ),

                    ]),
              ),
            ),
            const SizedBox(height: 20),

            // Ordered Items
            Text("Ordered Items", style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (orderData?['orderedItems'] as List).length,
              itemBuilder: (context, index) {
                var item = orderData?['orderedItems'][index];
                bool isRated = item.containsKey('rating');

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['imageUrl'],
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  "Quantity: ${item['quantity']}, Price: PKR${item['price']}"),
                              const SizedBox(height: 8),
                              if (orderData?['orderStatus'] == "Completed")
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RatingBar.builder(
                                      initialRating: isRated
                                          ? double.parse(
                                              item['rating'].toString())
                                          : 0.0,
                                      minRating: 1,
                                      itemSize: 24,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemPadding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) {
                                        setState(() {
                                          ratings = rating;
                                          orderItemId[item['id']] = rating;
                                        });
                                      },
                                    ),
                                    SubmitRate(
                                        isRated: isRated,
                                        submitRatings: () {
                                          _submitRatings(item['id']);
                                        })
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (orderData?['orderStatus'] == "Pending") ...[
              Center(
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                  ),
                  color: Colors.red,
                  onPressed: () => _showStatusChangeDialog("Cancellation Requested"),
                  child: Text("Cancel Order",style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SubmitRate extends StatefulWidget {
  SubmitRate({required this.isRated, required this.submitRatings, super.key});

  bool isRated;
  Function submitRatings;
  @override
  State<SubmitRate> createState() => _SubmitRateState();
}

class _SubmitRateState extends State<SubmitRate> {
  @override
  Widget build(BuildContext context) {
    return !widget.isRated
        ? ElevatedButton(
            onPressed: () {
              setState(() {
                widget.isRated = true;
              });
              widget.submitRatings();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text("Submit Rating"),
          )
        : SizedBox();
  }
}
