import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/main.dart';
import 'package:primax_lyalaty_program/screens/product_details_screen/product_details_screen.dart';

import '../widgets/comman_back_button.dart';
import 'home_screen/home_screen.dart';

class FavoriteScreen extends StatelessWidget {

  const FavoriteScreen({super.key,});

  @override
  Widget build(BuildContext context) {
    // Query Firestore for only the favorite products of the current user
    Query queryRef = FirebaseFirestore.instance
        .collection('products')
        .where('favoritedBy', arrayContains: sharedPref.getString('user_id')); // Assuming 'favorites' is an array

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Favorites",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading:CommonBackButton(onPressed: (){
          Navigator.pop(context);
        }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: queryRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No Favorites Found',style: TextStyle(fontSize: 16,)));
            }

            List<QueryDocumentSnapshot<Object?>> filteredDocs = snapshot.data!.docs;

            return AlignedGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              itemCount: filteredDocs.length??0,
              itemBuilder: (context, index) {
                var data = filteredDocs[index].data() as Map<String, dynamic>;
                return InkWell(
                  onTap: () {
                    ProductDetailsScreen(data, productId: filteredDocs[index].id)
                        .launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                  },
                  child: ProductCard(data, productId: filteredDocs[index].id),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
