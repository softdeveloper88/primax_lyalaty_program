import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/main.dart';
import 'package:primax_lyalaty_program/screens/checkout.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';

import '../widgets/comman_back_button.dart';

class MyCartScreen extends StatefulWidget {
  const MyCartScreen({Key? key,}) : super(key: key);

  @override
  State<MyCartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<MyCartScreen> {
  late CollectionReference userCartCollection;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  double shipping=0.0;
  @override
  void initState() {
    userCartCollection = firestore
        .collection('users')
        .doc(sharedPref.getString('user_id'))
        .collection('cart');
    getCartTotal();
    super.initState();
  }
  Future<void> getCartTotal() async {
    QuerySnapshot cartSnapshot = await firestore
        .collection('users')
        .doc(sharedPref.getString('user_id'))
        .collection('cart')
        .get();

    double total = 0.0;
    for (var doc in cartSnapshot.docs) {
      total += (doc['price'] * doc['quantity']);
    }
    setState(() {
      totals=total.toString();

    });
  }
String totals='0.00';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Cart',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading:CommonBackButton(onPressed: (){
          Navigator.pop(context);
        }),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: userCartCollection.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                    var cartItems = snapshot.data!.docs;
                    if (cartItems.isEmpty) return Center(child: Text("No product found",style: TextStyle(fontSize: 16,)));

                    return ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: Row(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(item['imageUrl']),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Text("PKR${item['price']}",
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                                onPressed: () =>
                                                    _updateQuantity(
                                                      item.id,
                                                      item['quantity'] - 1,
                                                    ),
                                                icon: SvgPicture.asset(
                                                  'assets/icons/ic_decrement.svg',
                                                )),
                                            Text(
                                              item['quantity'].toString(),
                                              // item['quantity'].toString(),
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                            IconButton(
                                              // color:Colors.green,
                                              onPressed: () => _updateQuantity(
                                                item.id,
                                                item['quantity'] + 1,
                                              ),
                                              icon: SvgPicture.asset(
                                                'assets/icons/ic_increment.svg',
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          onPressed: () => _deleteItem(item.id),
                                          icon: SvgPicture.asset(
                                            'assets/icons/ic_remove.svg',
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
                      },
                    );
                  })),
         Visibility(
             visible: double.parse(totals)>0,
             child: _buildSummarySection()),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    getCartTotal();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(fontSize: 16)),
              Text("PKR$totals",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shipping', style: TextStyle(fontSize: 16)),
              Text("PKR$shipping",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Cost', style: TextStyle(fontSize: 18)),
              Text(
                "PKR$totals",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            onPressed: () {
              CheckoutScreen(totals,shipping).launch(context,
                  pageRouteAnimation: PageRouteAnimation.Slide);
              Fluttertoast.showToast(
                msg: "Proceeding to Checkout!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            text: 'Checkout',
          ),
        ],
      ),
    );

  }

  void _updateQuantity(String itemId, int quantity) {
    if (quantity < 1) return;

    userCartCollection.doc(itemId).update({'quantity': quantity});
    getCartTotal();
  }

  void _deleteItem(String itemId) {
    getCartTotal();

    userCartCollection.doc(itemId).delete();
  }
}
