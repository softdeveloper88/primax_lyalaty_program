import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/main.dart';
import 'package:primax_lyalaty_program/screens/add_new_address.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';
import 'package:primax_lyalaty_program/widgets/images.dart';

class MyAddress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/Back.png',
            height: 60,
            width: 60,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Address',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(sharedPref.getString('user_id'))
                    .collection('addresses')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No addresses found."));
                  }

                  var addresses = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      var addressData =
                          addresses[index].data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context, addressData);
                          },
                          child: CartItemCardScreen(
                            addressId: addresses[index].id,
                            userId: sharedPref.getString('user_id') ?? '',
                            image: Images.home,
                            title: addressData['title'] ?? 'Unknown',
                            address: addressData['address'] ?? '',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            CustomButton(
              width: double.maxFinite,
              onPressed: () {
                AddNewAddress().launch(context,
                    pageRouteAnimation: PageRouteAnimation.Slide);
                // Implement address addition logic here
              },
              text: "Add New Address",
            )
          ],
        ),
      ),
    );
  }
}

class CartItemCardScreen extends StatelessWidget {
  final String addressId;
  final String userId;
  final String image;
  final String title;
  final String address;

  CartItemCardScreen({
    super.key,
    required this.addressId,
    required this.userId,
    required this.image,
    required this.title,
    required this.address,
  });

  void _deleteAddress(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc(addressId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: Color(0xffF5F6FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, top: 10, right: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 30,
              child: Image.asset(
                image,
                scale: 3,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    address,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    AddNewAddress(
                      addressId: addressId,
                    ).launch(context,
                        pageRouteAnimation: PageRouteAnimation.Slide);
                  },
                  child: Image.asset(
                    Images.editicon,
                    scale: 3.5,
                  ),
                ),
                TextButton(
                  onPressed: () => _deleteAddress(context),
                  child: Image.asset(
                    Images.deleteicon,
                    scale: 3.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
