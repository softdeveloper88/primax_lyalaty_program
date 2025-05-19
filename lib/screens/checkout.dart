
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/core/order_model.dart';
import 'package:primax_lyalaty_program/core/utils/comman_data.dart';
import 'package:primax_lyalaty_program/core/utils/payment_receipt_dialog.dart';
import 'package:primax_lyalaty_program/core/utils/progress_dialog_utils.dart';
import 'package:primax_lyalaty_program/core/utils/show_receipt_dialog.dart';
import 'package:primax_lyalaty_program/main.dart';
import 'package:primax_lyalaty_program/screens/dashboard_screen/dashboard_screen.dart';
import 'package:primax_lyalaty_program/widgets/comman_back_button.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';

import '../core/utils/constants.dart';
import '../widgets/contact_info_widget.dart';
import '../widgets/images.dart';
import 'my_address.dart';
import 'my_cards_screen.dart';


class CheckoutScreen extends StatefulWidget {
  final String? totals;
  final double? shipping;

  CheckoutScreen(this.totals, this.shipping);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late GoogleMapController mapController;
  LatLng _selectedLocation = LatLng(51.5074, -0.1278); // Default to London
  String _selectedAddress = 'Fetching address...';
  Map<String, dynamic> userData = {};
  Map<String, dynamic> cardData = {};
  List<Map<String, dynamic>> cartItems = []; // Store ordered items
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Map<String, dynamic>? paymentIntent;
  void _onMarkerDragEnd(LatLng newPosition) {
    setState(() {
      _selectedLocation = newPosition;
      _selectedAddress = 'Fetching address...'; // Reset while loading
    });
    _getAddressFromLatLng(newPosition);
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _getAddressFromLatLng(_selectedLocation);
    getFirstCard();
    getCartItems();
  }

  /// **Fetch user details from Firestore**
  void _fetchUserData() async {
    String userId =sharedPref.getString('user_id')??'';
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      setState(() {
        userData = userSnapshot.data() as Map<String, dynamic>;
      });
    }
  }

  /// **Fetch selected address from map**
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedAddress =
              "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
      } else {
        setState(() {
          _selectedAddress = "Address not found";
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = "Failed to get address";
      });
    }
  }

  /// **Fetch user's first saved card**
  getFirstCard() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(sharedPref.getString('user_id')??'')
        .collection('cards')
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      setState(() {
        cardData = snapshot.docs.first.data() as Map<String, dynamic>;
      });
    }
  }

  /// **Fetch user's cart items**
  void getCartItems() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(sharedPref.getString('user_id'))
        .collection('cart')
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        cartItems = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    }
  }

  /// **Generate a unique order ID**
  String _generateOrderCode() {
    return "ORD${DateTime.now().millisecondsSinceEpoch}";
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }

  createPaymentIntent(bool isSave, String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body;
      if (isSave) {
        body = {
          'amount': calculateAmount(amount),
          'currency': currency,
          'payment_method': cardData['paymentMethodId'],
          'customer': cardData['customerId'],
          'off_session': 'true',
          'confirm': 'true',
        };
      } else {
        body = {
          'amount': calculateAmount(amount),
          'currency': currency,
        };
      }
      print(body);
      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      print(response.body);
      return json.decode(response.body);
    } catch (err) {
      print('err $err');
      throw Exception(err.toString());
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        // Show payment receipt dialog to upload image
        double calculatedAmount = double.parse(widget.totals ?? '0.00') + (widget.shipping ?? 0.0);
        PaymentResult? result = await showPaymentReceiptDialog(context, calculatedAmount);
        if (result == null || result.receiptUrl == null) {
          // User cancelled the upload
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment receipt upload was cancelled")),
          );
          return;
        }
        
        String receiptUrl = result.receiptUrl!;
        
        OrderModel order =
            OrderModel.fromJson(paymentIntent!); // Convert JSON to Order model
        String orderCode = _generateOrderCode();
        String userId = sharedPref.getString('user_id')??'';

        Map<String, dynamic> orderData = {
          "orderCode": orderCode,
          "orderId": order.id,
          "paymentMethodId": order.paymentMethod,
          "customer": order.customerId,
          "latest_charge": order.latestCharge,
          "userId": userId,
          "customerName": userData['fullName'] ?? "N/A",
          "customerEmail": userData['email'] ?? "N/A",
          "customerPhone": userData['phone'] ?? "N/A",
          "address": _selectedAddress,
          "latitude": _selectedLocation.latitude,
          "longitude": _selectedLocation.longitude,
          "paymentMethod": cardData['paymentMethod'] ?? "Unknown",
          "cardNumber": cardData['cardNumber'] ?? "**** **** **** ****",
          "orderStatus": "Pending",
          "totalAmount": double.parse(widget.totals ?? '0.00') + (widget.shipping ?? 0.0),
          "shippingCost": widget.shipping ?? 0.0,
          "orderedItems": cartItems,
          "payment_receipt_url": receiptUrl, // Add receipt URL to order data
          "timestamp": Timestamp.now(),
        };

        // Store order in Firestore
        await FirebaseFirestore.instance
            .collection("orders")
            .doc(orderCode)
            .set(orderData);

        // Clear cart after order placement
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('cart')
            .get()
            .then((snapshot) {
          for (DocumentSnapshot doc in snapshot.docs) {
            doc.reference.delete();
          }
        });
        sendNotificationToAllUsers(
          userId: sharedPref.getString('user_id'),
          title: 'You have place new order successfully',
          type: 'order_placed',
          id: '',
          newPrice: 0.0,
          oldPrice: 0.0,
        );

        showReceiptDialog(context, order); // Show receipt dialog

        //Clear paymentIntent variable after successful payment
        paymentIntent = null;
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
    } catch (e) {
      print('$e');
    }
  }

  /// **Create an order in Firestore**
  void _placeOrder(context) async {
    if (userData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete user details.")),
      );
      return;
    }
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete cart data")),
      );
      return;
    }

    try {
      // Validate required information
      if (userData.isEmpty || cartItems.isEmpty) {
        throw Exception('Please complete all required information');
      }

      // Show payment receipt dialog to upload image
      ProgressDialogUtils.showProgressDialog();
      
      // Get total amount
      double totalAmount = double.parse(widget.totals ?? '0.00') + (widget.shipping ?? 0.0);
      
      // Skip Stripe and directly show payment receipt dialog
      PaymentResult? result = await showPaymentReceiptDialog(context, totalAmount);
      ProgressDialogUtils.hideProgressDialog();
      
      if (result == null || result.receiptUrl == null) {
        // User cancelled the upload
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment receipt upload was cancelled")),
        );
        return;
      }
      
      // Get payment amount from result
      double paidAmount = double.tryParse(result.amount ?? totalAmount.toString()) ?? totalAmount;
      
      // Create an order without Stripe
      directCreateOrder(context, paidAmount, result.receiptUrl!);
      
      // Comment out Stripe code
      /*
      // Get total amount in cents
      int totalAmount = ((double.parse(widget.totals ?? '0') +
              double.parse(widget.shipping.toString())))
          .toInt();
      print('Stripe Amount: $totalAmount');
      print('object $totalAmount');
      print('cart $cartItems');

      if (cardData.isNotEmpty) {
        paymentWithSaveCard(context, totalAmount);
      } else {
        paymentWithoutSaveCard(context, totalAmount);
      }
      */
    } catch (e) {
      ProgressDialogUtils.hideProgressDialog();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.toString()}')),
      );
    }
  }

  paymentWithSaveCard(context, totalAmount) async {
    try {
      //STEP 1: Create Payment Intent
      ProgressDialogUtils.showProgressDialog();
      paymentIntent =
          await createPaymentIntent(true, totalAmount.toString(), 'PKR');

      //STEP 2: Initialize Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  //Gotten from payment intent
                  style: ThemeMode.light,
                  merchantDisplayName: 'Primax'))
          .then((value) {});
      try {
        // await Stripe.instance.presentPaymentSheet();
        ProgressDialogUtils.hideProgressDialog();
        
        // Show payment receipt dialog to upload image
        double calculatedAmount = double.parse(widget.totals ?? '0.00') + (widget.shipping ?? 0.0);
        PaymentResult? result = await showPaymentReceiptDialog(context, calculatedAmount);
        if (result == null || result.receiptUrl == null) {
          // User cancelled the upload
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment receipt upload was cancelled")),
          );
          return;
        }
        
        String receiptUrl = result.receiptUrl!;

        ProgressDialogUtils.showProgressDialog();
        
        // Payment was successful, now show receipt dialog
        OrderModel order =
            OrderModel.fromJson(paymentIntent!); // Convert JSON to Order model
        String orderCode = _generateOrderCode();
        String userId = sharedPref.getString('user_id')??'';
        print(order.paymentStatus);
        
        // Get payment amount from result
        double paidAmount = double.tryParse(result.amount ?? calculatedAmount.toString()) ?? calculatedAmount;
        
        Map<String, dynamic> orderData = {
          "orderCode": orderCode,
          "orderId": order.id,
          "paymentMethodId": order.paymentMethod,
          "customer": order.customerId,
          "latest_charge": order.latestCharge,
          "userId": userId,
          "customerName": userData['fullName'] ?? "N/A",
          "customerEmail": userData['email'] ?? "N/A",
          "customerPhone": userData['phone'] ?? "N/A",
          "address": _selectedAddress,
          "latitude": _selectedLocation.latitude,
          "longitude": _selectedLocation.longitude,
          "paymentMethod": cardData['paymentMethod'] ?? "Unknown",
          "cardNumber": cardData['cardNumber'] ?? "**** **** **** ****",
          "orderStatus": "Pending",
          "totalAmount": paidAmount,
          "originalAmount": calculatedAmount,
          "shippingCost": widget.shipping ?? 0.0,
          "orderedItems": cartItems,
          "payment_receipt_url": receiptUrl, // Add receipt URL to order data
          "timestamp": Timestamp.now(),
        };

        // Store order in Firestore
        await FirebaseFirestore.instance
            .collection("orders")
            .doc(orderCode)
            .set(orderData);

        // Clear cart after order placement
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('cart')
            .get()
            .then((snapshot) {
          for (DocumentSnapshot doc in snapshot.docs) {
            doc.reference.delete();
          }
        });
        sendNotificationToAllUsers(
          userId: sharedPref.getString('user_id'),
          title: 'You have place new order successfully',
          type: 'order_placed',
          id: '',
          newPrice: 0.0,
          oldPrice: 0.0,
        );
        ProgressDialogUtils.hideProgressDialog();

        showReceiptDialog(context, order); // Show receipt dialog
      } on Exception catch (e) {
        ProgressDialogUtils.hideProgressDialog();

        print("Payment failed: $e");
      }
      //STEP 3: Display Payment sheet
    } catch (err) {
      print(err);
      ProgressDialogUtils.hideProgressDialog();

      throw Exception(err);
    }
  }

  paymentWithoutSaveCard(context, totalAmount) async {
    try {
      //STEP 1: Create Payment Intent
      ProgressDialogUtils.showProgressDialog();
      paymentIntent =
          await createPaymentIntent(false, totalAmount.toString(), 'PKR');

      //STEP 2: Initialize Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  //Gotten from payment intent
                  style: ThemeMode.light,
                  merchantDisplayName: 'Primax'))
          .then((value) {});

      try {
        // await Stripe.instance.presentPaymentSheet();
        ProgressDialogUtils.hideProgressDialog();
        displayPaymentSheet();
        // Payment was successful, now show receipt dialog
      } on Exception catch (e) {
        print("Payment failed: $e");
      }
      //STEP 3: Display Payment sheet
    } catch (err) {
      print(err);
      ProgressDialogUtils.hideProgressDialog();

      throw Exception(err);
    }
  }

  /// **Create order without Stripe payment**
  Future<void> directCreateOrder(BuildContext context, double paidAmount, String receiptUrl) async {
    try {
      ProgressDialogUtils.showProgressDialog();
      
      // Generate order code
      String orderCode = _generateOrderCode();
      String userId = sharedPref.getString('user_id') ?? '';
      
      // Create order data
      Map<String, dynamic> orderData = {
        "orderCode": orderCode,
        "orderId": "MANUAL_${DateTime.now().millisecondsSinceEpoch}",
        "paymentMethodId": "MANUAL_PAYMENT",
        "customer": userId,
        "latest_charge": "",
        "userId": userId,
        "customerName": userData['fullName'] ?? "N/A",
        "customerEmail": userData['email'] ?? "N/A",
        "customerPhone": userData['phone'] ?? "N/A",
        "address": _selectedAddress,
        "latitude": _selectedLocation.latitude,
        "longitude": _selectedLocation.longitude,
        "paymentMethod": "Bank Transfer", 
        "cardNumber": "",
        "orderStatus": "Pending",
        "totalAmount": paidAmount,
        "originalAmount": double.parse(widget.totals ?? '0.00') + (widget.shipping ?? 0.0),
        "shippingCost": widget.shipping ?? 0.0,
        "orderedItems": cartItems,
        "payment_receipt_url": receiptUrl, // Add receipt URL to order data
        "timestamp": Timestamp.now(),
      };
      
      // Store order in Firestore
      await FirebaseFirestore.instance
          .collection("orders")
          .doc(orderCode)
          .set(orderData);
      
      // Clear cart after order placement
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      
      // Send notification
      sendNotificationToAllUsers(
        userId: sharedPref.getString('user_id'),
        title: 'You have placed a new order successfully',
        type: 'order_placed',
        id: '',
        newPrice: 0.0,
        oldPrice: 0.0,
      );
      
      ProgressDialogUtils.hideProgressDialog();
      
      // Show success dialog
      _showOrderSuccessDialog();
      
    } catch (e) {
      ProgressDialogUtils.hideProgressDialog();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create order: ${e.toString()}')),
      );
    }
  }

  /// **Show Order Success Dialog**
  void _showOrderSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Image.asset(Images.dialogFrame),
          content: Padding(
            padding: const EdgeInsets.only(left: 60.0),
            child: Text(
              "Your Order Is \n Successfully Placed!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          actions: [
            CustomButton(
              onPressed: () {
                DashboardScreen().launch(context,
                    isNewTask: true,
                    pageRouteAnimation: PageRouteAnimation.Slide);
              },
              text: 'Back to Home',
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: CommonBackButton(onPressed: () {
          Navigator.pop(context);
        }),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Material(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ContactInfoWidget(
                          userData: userData,
                          onEmailUpdate: (email) {
                            userData['email'] = email;
                          },
                          onPhoneUpdate: (phone) {
                            userData['phone'] = phone;
                          }),
                      SizedBox(height: 20),
                      _buildAddressSection(),
                      SizedBox(height: 20),
                      // _buildShippingInfo(),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCostSummary(),
                  SizedBox(height: 20),
                  CustomButton(
                      onPressed: () {
                        _placeOrder(context);
                      },
                      text: 'Payment'),
                ],
              ),
            ),
          ],
        ),
      ),
      // bottomSheet: Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: Column(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       _buildCostSummary(),
      //       SizedBox(height: 20),
      //       CustomButton(onPressed: _placeOrder, text: 'Payment'),
      //     ],
      //   ),
      // ),
    );
  }

  Widget _buildAddressSection() {
    return InkWell(
      onTap: () async {
        Map<String, dynamic> address = await MyAddress()
            .launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
        _selectedAddress = address['address'];
        _selectedLocation = LatLng(address['latitude'], address['longitude']);
        setState(() {});
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('Address',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedAddress),
                Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
          SizedBox(
            height: 150,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _selectedLocation,
                zoom: 15.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('selected-location'),
                  position: _selectedLocation,
                  draggable: true,
                  onDragEnd: _onMarkerDragEnd,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfo() {
    return InkWell(
      onTap: () async {
        try {
          Map<String, dynamic> cardData1 = await MyCardsScreen()
              .launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
          cardData = cardData1;
          setState(() {});

        }catch(e){
          e.toString();
        }
      },
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Payment Method',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 10),
          if (cardData.isNotEmpty)
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Image.asset(_getCardLogo(cardData['paymentMethod']) ?? '',
                      width: 50),
                  SizedBox(width: 10),
                  Text(
                      '**** **** **** ${(cardData['cardNumber'] ?? '0000000000000000').substring(cardData['cardNumber'].length - 4, cardData['cardNumber'].length)}'),
                  Spacer(),
                  Icon(Icons.keyboard_arrow_down),
                ],
              ),
            )
          else
            Row(
              children: [
                SizedBox(width: 10),
                Text('Please add card information'),
                Spacer(),
                Icon(Icons.add),
              ],
            ),
        ]),
      ),
    );
  }

  String _getCardLogo(String cardType) {
    switch (cardType) {
      case "Visa":
        return "assets/visa.png";
      case "Mastercard":
        return "assets/mastercard.png";
      case "Amex":
        return "assets/amex.png";
      case "Discover":
        return "assets/discover.png";
      default:
        return "assets/visa.png";
    }
  }

  Widget _buildCostSummary() {
    return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _costRow('Subtotal', 'PKR${widget.totals}'),
            _costRow('Shipping', 'PKR${widget.shipping}'),
            Divider(),
            _costRow('Total Cost',
                'PKR${double.parse(widget.totals ?? '0.00') + (widget.shipping ?? 0.0)}',
                isBold: true),
          ],
        ));
  }

  Widget _costRow(String label, String amount, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(amount,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
