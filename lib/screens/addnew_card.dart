// import 'dart:convert';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
// import 'package:http/http.dart' as http;
// import 'package:primax_lyalaty_program/core/utils/progress_dialog_utils.dart';
// import 'package:primax_lyalaty_program/main.dart';
// import 'package:primax_lyalaty_program/widgets/custom_button.dart';
//
// import '../core/utils/constants.dart';
//
// class AddNewCardScreen extends StatefulWidget {
//   @override
//   _AddNewCardScreenState createState() => _AddNewCardScreenState();
// }
//
// class _AddNewCardScreenState extends State<AddNewCardScreen> {
//   final TextEditingController _cardOwnerController = TextEditingController();
//   final TextEditingController _cardNumberController = TextEditingController();
//   final TextEditingController _expController = TextEditingController();
//   final TextEditingController _cvvController = TextEditingController();
//   // final CardFormEditController _cardFormEditController =
//   //     CardFormEditController();
//   final _formKey = GlobalKey<FormState>();
//   bool _isCardComplete = false;
//
//   String selectedPaymentMethod = "Mastercard";
//   bool saveCardInfo = true;
//   String? cardNumberError;
//   String? expError;
//   String? cvvError;
//   // CardFieldInputDetails? _cardDetails;
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   /// **Save Card Details**
//   void _saveCardDetails() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (!_isCardComplete) return;
//     ProgressDialogUtils.showProgressDialog();
//     createCustomer().then((v) async {
//       final billingDetails = BillingDetails(
//         name: _cardOwnerController.text,
//         email: FirebaseAuth.instance.currentUser?.email,
//         phone: FirebaseAuth.instance.currentUser?.phoneNumber,
//         address: Address(
//           city: '',
//           country: '',
//           line1: '',
//           postalCode: '',
//           state: '',
//           line2: '',
//         ),
//       );
//       // Create payment method with Stripe
//
//       final paymentMethod = await Stripe.instance.createPaymentMethod(
//         params: PaymentMethodParams.card(
//           paymentMethodData: PaymentMethodData(billingDetails: billingDetails),
//         ),
//       );
//
//       // Step 3: Save Payment Method to Firestore
//       final paymentMethodId = paymentMethod.id;
//
//       final isAttached = await attachPaymentMethodToCustomer(
//           dotenv.env['STRIPE_SECRET']!, customerIds, paymentMethodId);
//
//       if (isAttached) {
//         print('PaymentMethod attached successfully!');
//
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(sharedPref.getString('user_id'))
//           .collection('cards')
//           .add({
//         'paymentMethod': _cardDetails?.brand ?? "",
//         'paymentMethodId': paymentMethodId,
//         'cardOwner': _cardOwnerController.text,
//         'cardNumber': _cardDetails?.last4 ?? '',
//         'exp':
//             '${_cardDetails?.expiryMonth ?? ''}/${_cardDetails?.expiryYear ?? ''}',
//         'cvv': _cardDetails?.cvc ?? '***',
//         'saveCardInfo': saveCardInfo,
//         'customerId': customerIds,
//         'createdAt': Timestamp.now(),
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Card saved successfully")),
//       );
//         ProgressDialogUtils.hideProgressDialog();
//
//       Navigator.pop(context);
//       } else {
//         print('Failed to attach PaymentMethod.');
//       }
//     }).catchError((e) {
//       print(e);
//       ProgressDialogUtils.hideProgressDialog();
//
//     });
//   }
//
//   CardSystemData? _cardSystemData;
//
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   String customerIds = '';
//   Future<String?> createStripeCustomer(
//     String stripeSecretKey,
//     Map<String, dynamic> customerData,
//   ) async {
//     try {
//       final response = await http.post(
//         Uri.parse('https://api.stripe.com/v1/customers'),
//         headers: {
//           'Authorization': 'Bearer $stripeSecretKey',
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//         body: customerData.entries
//             .map((entry) => '${entry.key}=${entry.value}')
//             .join('&'),
//       );
//
//       if (response.statusCode == 200) {
//         final decodedResponse = json.decode(response.body);
//         return decodedResponse['id'];
//       } else {
//         print('Failed to create Stripe customer: ${response.body}');
//         return null;
//       }
//     } catch (error) {
//       print('Error creating Stripe customer: $error');
//       return null;
//     }
//   }
//
//   Future<void> createCustomer() async {
//    // Replace with your secret key
//     final customerData = {
//       'email': sharedPref.getString('user_email'),
//       'name': sharedPref.getString('user_name'),
//       'description': 'customer',
//       'metadata[userId]': '123',
//       'metadata[accountType]': 'premium',
//     };
//
//     final customerId =
//         await createStripeCustomer(stripeSecretKey, customerData);
//
//     if (customerId != null) {
//       setState(() {
//         customerIds = customerId;
//       });
//       print('Stripe Customer ID: $customerId');
//     } else {
//       print('Failed to create customer.');
//     }
//   }
//
//   Future<bool> attachPaymentMethodToCustomer(
//     String stripeSecretKey,
//     String customerId,
//     String paymentMethodId,
//   ) async {
//     try {
//       final response = await http.post(
//         Uri.parse(
//             'https://api.stripe.com/v1/payment_methods/$paymentMethodId/attach'),
//         headers: {
//           'Authorization': 'Bearer $stripeSecretKey',
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//         body: {
//           'customer': customerId,
//         },
//       );
//
//       if (response.statusCode == 200) {
//         return true; // Attachment successful
//       } else {
//         print('Failed to attach PaymentMethod: ${response.body}');
//         return false; // Attachment failed
//       }
//     } catch (error) {
//       print('Error attaching PaymentMethod: $error');
//       return false; // Attachment failed
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Image.asset(
//             'assets/Back.png',
//             height: 60,
//             width: 60,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'Add New Card',
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),
//       body: Form(
//         key: _formKey,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   spacing: 10,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildPaymentMethodIcon('assets/visa.png', 'Visa',
//                         isSelected: selectedPaymentMethod == "Visa"),
//                     _buildPaymentMethodIcon(
//                         'assets/mastercard.png', 'Mastercard',
//                         isSelected: selectedPaymentMethod == "Mastercard"),
//                     _buildPaymentMethodIcon('assets/paypal.png', 'PayPal',
//                         isSelected: selectedPaymentMethod == "PayPal"),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 24),
//               _buildTextFieldName(
//                 controller: _cardOwnerController,
//                 label: 'Card Owner',
//                 hintText: 'e.g. John Doe',
//                 validator: (value) => value!.trim().isEmpty
//                     ? "Cardholder name is required"
//                     : null,
//               ),
//               // SizedBox(height: 16),
//               // _buildTextField(
//               //   controller: _cardNumberController,
//               //   label: 'Card Number (${_cardSystemData?.system ?? ''})',
//               //   hintText: '1234 5678 9012 3456',
//               //   errorText: cardNumberError,
//               //   keyboardType: TextInputType.number,
//               //   validator: (value) => value!.trim().isEmpty
//               //       ? "Card number is required"
//               //       : null,
//               // ),
//               // SizedBox(height: 16),
//               // Row(
//               //   children: [
//               //     Expanded(
//               //       child: _buildTextField(
//               //         controller: _expController,
//               //         label: 'EXP',
//               //         hintText: '12/24',
//               //         errorText: expError,
//               //         keyboardType: TextInputType.datetime,
//               //         validator: (value) => value!.trim().isEmpty
//               //             ? "Expire Date is required"
//               //             : null,
//               //       ),
//               //     ),
//               //     SizedBox(width: 16),
//               //     Expanded(
//               //       child: _buildTextField(
//               //         controller: _cvvController,
//               //         label: 'CVV',
//               //         hintText: '123',
//               //         errorText: cvvError,
//               //         keyboardType: TextInputType.number,
//               //         validator: (value) => value!.trim().isEmpty
//               //             ? "CVV  is required"
//               //             : null,
//               //       ),
//               //     ),
//               //   ],
//               // ),
//               SizedBox(height: 10),
//               Row(
//                 children: [
//                   Text('Card Details',
//                       style:
//                           TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//               SizedBox(height: 10),
//               // Expanded(
//               //   child: CardFormField(
//               //     style: CardFormStyle(
//               //       textColor: Colors.black45,
//               //       cursorColor: Colors.black,
//               //       borderColor: Colors.black,
//               //       placeholderColor: Colors.black38
//               //     ),
//               //     onCardChanged: (cardDetails) {
//               //       setState(() {
//               //         _isCardComplete = cardDetails?.complete ?? false;
//               //         _cardDetails = cardDetails;
//               //       });
//               //
//               //       print('Card Details: $cardDetails');
//               //     },
//               //     controller: _cardFormEditController,
//               //   ),
//               // ),
//               CardField(
//                 onCardChanged: (cardDetails) {
//                   setState(() {
//                     _isCardComplete = cardDetails?.complete??false;
//                   _cardDetails=cardDetails;
//                   });
//
//                   print('Card Details: ${cardDetails}');
//                 },
//                 androidPlatformViewRenderType: AndroidPlatformViewRenderType.expensiveAndroidView,
//                 decoration: InputDecoration(
//                   hintText: '4242 4242 4242 4242',
//                   filled: true,
//                   fillColor: Color(0xffF0F5FA),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                   hintStyle: TextStyle(
//                     color: Colors.black.withOpacity(.3),
//                   ),
//                   errorStyle: TextStyle(
//                     color: Colors.red,
//                   ),
//                 ),
//                 style: TextStyle(
//                   backgroundColor: Colors.grey[200],
//                   color: Colors.black,
//                   fontSize: 16.0,
//                 ),
//               ),
//               SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('Save card info', style: TextStyle(fontSize: 16)),
//                   Switch(
//                     value: saveCardInfo,
//                     onChanged: (value) {
//                       setState(() {
//                         saveCardInfo = value;
//                       });
//                     },
//                     activeTrackColor: Color(0xff4BC76D),
//                   ),
//                 ],
//               ),
//               Spacer(),
//               CustomButton(text: 'Add Card', onPressed: _saveCardDetails),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPaymentMethodIcon(String assetPath, String label,
//       {bool isSelected = false}) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedPaymentMethod = label;
//         });
//       },
//       child: Column(
//         children: [
//           SizedBox(width: 10),
//           Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Color(0xffF0F5FA),
//               borderRadius: BorderRadius.circular(15),
//               border: Border.all(
//                   color: isSelected ? Colors.green : Colors.grey, width: 2),
//             ),
//             child: Image.asset(assetPath, scale: 3, width: 60, height: 60),
//           ),
//           SizedBox(height: 4),
//           Text(label,
//               style: TextStyle(
//                 fontSize: 13,
//                 color: Color(0xff464E57),
//               )),
//         ],
//       ),
//     );
//   }
//
//   /// **Build Input Fields**
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hintText,
//     String? Function(String?)? validator,
//     TextInputType keyboardType = TextInputType.text,
//     String? errorText,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//         SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           validator: validator,
//           decoration: InputDecoration(
//             hintText: hintText,
//             errorText: errorText,
//             filled: true,
//             fillColor: Color(0xffF0F5FA),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//             hintStyle: TextStyle(
//               color: Colors.black.withOpacity(.3),
//             ),
//             errorStyle: TextStyle(
//               color: Colors.red,
//             ),
//           ),
//           keyboardType: keyboardType,
//           inputFormatters: [
//             label == 'EXP'
//                 ? CreditCardExpirationDateFormatter()
//                 : label == 'CVV'
//                     ? CreditCardCvcInputFormatter()
//                     : CreditCardNumberInputFormatter(
//                         onCardSystemSelected: (CardSystemData? cardSystemData) {
//                           setState(() {
//                             _cardSystemData = cardSystemData;
//                           });
//                         },
//                       ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTextFieldName({
//     required TextEditingController controller,
//     required String label,
//     required String hintText,
//     String? Function(String?)? validator,
//     TextInputType keyboardType = TextInputType.text,
//     String? errorText,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//         SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           validator: validator,
//           decoration: InputDecoration(
//             hintText: hintText,
//             errorText: errorText,
//             filled: true,
//             fillColor: Color(0xffF0F5FA),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//             hintStyle: TextStyle(
//               color: Colors.black.withOpacity(.3),
//             ),
//             errorStyle: TextStyle(
//               color: Colors.red,
//             ),
//           ),
//           keyboardType: keyboardType,
//         ),
//       ],
//     );
//   }
// }
