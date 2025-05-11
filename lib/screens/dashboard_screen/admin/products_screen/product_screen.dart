import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/main.dart';
import 'package:primax_lyalaty_program/screens/home_screen/home_screen.dart';
import 'package:primax_lyalaty_program/screens/product_details_screen/product_details_screen.dart';

import '../../../../widgets/comman_back_button.dart';
import 'add_product_screen.dart';


class ProductScreen extends StatelessWidget {

  const ProductScreen({super.key,});

  @override
  Widget build(BuildContext context) {
    // Query Firestore for only the favorite products of the current user
    Query queryRef = FirebaseFirestore.instance.collection('products'); // Assuming 'favorites' is an array

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Products",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading:CommonBackButton(onPressed: (){
          Navigator.pop(context);
        }),
        actions: [
          IconButton(onPressed: (){
            AddUpdateProduct().launch(context);
          }, icon: Icon(Icons.add))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: queryRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No product Found'));
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
                    ProductDetailsScreen(data, productId: filteredDocs[index].id,isFromAdmin:true)
                        .launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                  },
                  child: ProductCard(data, productId: filteredDocs[index].id,isFromAdmin:true),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
