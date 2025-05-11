import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/screens/dashboard_screen/admin/orders_screen/order_details_screen.dart';
import 'package:primax_lyalaty_program/widgets/comman_back_button.dart';
class OrderByStatusScreen extends StatelessWidget {
  String? status;
  OrderByStatusScreen({this.status, super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "$status Orders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading:CommonBackButton(onPressed: (){
          Navigator.of(context).pop();
        }),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:status=='All' ?FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .snapshots():FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: true).where('orderStatus',isEqualTo: status)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var orders = snapshot.data!.docs;
          print('orders $orders');
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              var orderData = order.data() as Map<String, dynamic>;
              return OrderCard(orderData: orderData,orderId:order.id);
            },
          );
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String orderId;

  OrderCard({required this.orderData,required this.orderId});

  @override
  Widget build(BuildContext context) {
    List<dynamic> products = orderData['orderedItems']; // List of products

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display all products in this order
          Column(
            children: products.map((product) {
              return ProductItem(product: product,orderData: orderData,orderId: orderId,);
            }).toList(),
          ),
          SizedBox(height: 8),
          // Order Date
        ],
      ),
    );
  }
}

// Widget to display each product
class ProductItem extends StatelessWidget {
  final Map<String, dynamic> product;
  final Map<String, dynamic> orderData;
  String orderId;

  ProductItem({required this.product,required this.orderData,required this.orderId});
  String formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate(); // Convert Firestore Timestamp to DateTime
      return DateFormat('MMMM dd, yyyy').format(dateTime); // Format Date
    } else {
      return "Invalid Date"; // Fallback for incorrect data type
    }
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product['imageUrl'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 10),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Order #$orderId",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 10,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          formatDate(orderData['timestamp']),
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          OrderDetailsScreen(orderId: orderId,).launch(context);
                          // Navigate to review screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.green),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Review",
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }


}
