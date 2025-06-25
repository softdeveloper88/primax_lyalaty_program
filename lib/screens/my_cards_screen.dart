import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:credit_card_type_detector/credit_card_type_detector.dart';
// import 'package:credit_card_type_detector/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/main.dart';
import 'package:primax_lyalaty_program/screens/addnew_card.dart';

import '../widgets/comman_back_button.dart';
import '../widgets/images.dart';

class MyCardsScreen extends StatelessWidget {
  final String userId = sharedPref.getString('user_id')??''; // Get user ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading:CommonBackButton(onPressed: (){
    Navigator.pop(context);
    }),
        title: Text(
          'Cards',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // Fetch and Display Cards
            SizedBox(
              height: 300,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('cards')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildNoCardView(context);
                  }

                  var cards = snapshot.data!.docs;

                  return ListView.builder(
                    padding: EdgeInsets.all( 10),
                    scrollDirection: Axis.horizontal,
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      var cardData = cards[index].data() as Map<String, dynamic>;
                      return Container(
                        margin: EdgeInsets.all(6),
                        child:
                      //   CreditCardUi(
                      //     doesSupportNfc: true,
                      //     placeNfcIconAtTheEnd: true,
                      //     cardProviderLogo: Image.asset('assets/visa.png',height: 20,width: 20,),
                      //     cardHolderFullName: cardData['cardOwner'],
                      //     cardNumber: cardData['cardNumber'],
                      //     validThru: cardData['exp'],
                      //     cvvNumber:  cardData['cvv'],
                      //     enableFlipping: true,
                      //     cardType: CardType.credit,
                      //   ),
                      // );
                        // CreditCardWidget(
                        // backgroundImage: 'assets/images/card.png',
                        //  cardBgColor: cardDarkColor,
                        // cardNumber: cardData['cardNumber'],
                        // expiryDate: cardData['exp'],
                        // cardHolderName: cardData['cardOwner'],
                        // cvvCode: cardData['cvv'],
                        // showBackView: false, //true when you want to show cvv(back) view
                        // onCreditCardWidgetChange: (CreditCardBrand brand) {

                        // }, // Callback for anytime credit card brand is changed
                      // );
                      _buildCreditCard(context, cardData,cards[index].id));
                    },
                  );
                },
              ),
            ),

            SizedBox(height: 10),

            // Add New Card Button
            InkWell(
              onTap: () {
                // AddNewCardScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/Frame11.png',
                  scale: 4.5,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Build Payment Method Selection Icons**
  Widget _buildPaymentMethodIcon(String assetPath, String label) {
    return Column(
      children: [
        SizedBox(width: 10),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xffF0F5FA),
            borderRadius: BorderRadius.circular(15),
            shape: BoxShape.rectangle,
            border: Border.all(color: Colors.grey),
          ),
          child: Image.asset(assetPath, scale: 3, width: 60, height: 60),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Color(0xff464E57))),
      ],
    );
  }
  /// **Build the Credit Card UI with Auto-Detected Card Type**
  void _deleteCard(BuildContext context,cardId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cards')
        .doc(cardId)
        .delete();
  }
  Widget _buildCreditCard(BuildContext context, Map<String, dynamic> cardData,cardId) {
    String cardNumber = cardData['cardNumber'] ?? '0000000000000000';
    // String cardType = _detectCardType(cardNumber);

    return GestureDetector(
      onTap: () {
        Navigator.pop(context, cardData);
      },
      child: Container(
        width: 400,
        margin: EdgeInsets.only(bottom: 15),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          image: DecorationImage(image:AssetImage('assets/images/card.png')),
          // gradient: _getCardGradient(cardType),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Type Logo + Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Image.asset("assets/chip.png", height: 30), // Chip icon
                // Image.asset(_getCardLogo(cardType), height: 30),
                TextButton(
                  onPressed: () => _deleteCard(context,cardId),
                  child: Image.asset(
                    Images.deleteicon,
                    scale: 3.5,
                  ),
                ),// Card Type (Visa, Mastercard)
              ],
            ),
            SizedBox(height: 20),

            // Masked Card Number
            Text(
              _maskCardNumber(cardNumber),
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            // Expiry Date & Card Holder
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("EXPIRY", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(
                      cardData['exp'] ?? '00/00',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("CARDHOLDER", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(
                      cardData['cardOwner'] ?? 'CARDHOLDER',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// **Detect Card Type Based on Number**
  // String _detectCardType(String cardNumber) {
  //   var types = detectCCType(cardNumber); // Returns a Set<CreditCardType>
  //
  //   if (types.isNotEmpty) {
  //     CreditCardType type = types.single; // Get the first detected type
  //     switch (type) {
  //       case CreditCardType.visa:
  //         return "Visa";
  //       case CreditCardType.mastercard:
  //         return "Mastercard";
  //       case CreditCardType.americanExpress:
  //         return "American Express";
  //       case CreditCardType.discover:
  //         return "Discover";
  //       case CreditCardType.jcb:
  //         return "JCB";
  //       case CreditCardType.unionPay:
  //         return "UnionPay";
  //       case CreditCardType.dinersClub:
  //         return "Diners Club";
  //       default:
  //         return "Unknown";
  //     }
  //   }
  //   return "Unknown"; // If no type is detected
  // }
  /// **Mask Card Number (Show Only Last 4 Digits)**
  String _maskCardNumber(String number) {
    if (number.length < 4) return "**** **** **** ****";
    return "**** **** **** ${number.substring(number.length - 4)}";
  }

  /// **Get Card Logo Based on Type**
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

  /// **No Card View**
  Widget _buildNoCardViewNo() {
    return Center(
      child: Column(
        children: [
          Image.asset("assets/no_card.png", height: 200),
          SizedBox(height: 20),
          Text("No Cards Added", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          Text("Add a card to use it for payments.", style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}

  /// **Build No Card View**
  Widget _buildNoCardView(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xffF0F5FA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Container(
                  height: 150,
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/42.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Text("No Cards Added", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20)),
              Text(
                "You can add a card and save it for later",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

