import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/main.dart';
import 'package:primax_lyalaty_program/screens/dashboard_screen/admin/products_screen/add_product_screen.dart';
import 'package:primax_lyalaty_program/screens/home_screen/widget/header_widget.dart';
import 'package:primax_lyalaty_program/screens/home_screen/widget/searchbar_widget.dart';
import 'package:primax_lyalaty_program/screens/login_screen/login_screen.dart';
import 'package:primax_lyalaty_program/screens/product_details_screen/product_details_screen.dart';
import 'package:primax_lyalaty_program/widgets/comman_back_button.dart';

import '../../core/utils/comman_widget.dart';
import 'home_screen.dart';

class ShowAllProductScreen extends StatefulWidget {
  ShowAllProductScreen({super.key});

  @override
  State<ShowAllProductScreen> createState() => _ShowAllProductScreenState();
}

class _ShowAllProductScreenState extends State<ShowAllProductScreen> {
  Timer? _debounce;
  String query = '';
  int selectedBrandIndex = -1;
  List<Map<String, String>> brands = [];

  void updateSearch(String search) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        query = search;
      });
    });
  }
  @override
  void initState() {
    getBrands();
    super.initState();
  }

  getBrands() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('brands').orderBy('timestamp',descending: false).get();

      for (var doc in querySnapshot.docs) {
        brands.add({
          'id': doc.id, // Document ID
          'name': doc['name'] ?? '', // Assuming 'name' field exists
          'imageUrl': doc['imageUrl'] ?? '', // Assuming 'logo' field exists
        });
      }
      setState(() {});
      print("Brands: $brands"); // Debugging

    } catch (e) {
      print("Error fetching brands: $e");

    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: CommonBackButton(onPressed: ()=>Navigator.pop(context)),
        title: Text('All Products',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  SearchBarWidget(updateSearch),
                  const SizedBox(height: 20),
                  BrandSelector(
                    brands: brands,
                    selectedIndex: selectedBrandIndex,
                    onBrandSelected: (index) {
                      setState(() {
                        selectedBrandIndex = index;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: UnifiedProductGrid(
                query: query,
                selectedBrand: selectedBrandIndex != -1
                    ? '${brands[selectedBrandIndex]['name']}'
                    : null,
              ),
            ),
          ),
        ],
      )
      ,
      // body: Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       const SizedBox(height: 20),
      //       SearchBarWidget(updateSearch),
      //       const SizedBox(height: 20),
      //       BrandSelector(
      //         brands: brands,
      //         selectedIndex: selectedBrandIndex,
      //         onBrandSelected: (index) {
      //           setState(() {
      //             selectedBrandIndex = index;
      //           });
      //         },
      //       ),
      //       const SizedBox(height: 20),
      //       Expanded(
      //         child: PopularSeries(
      //           query: query,
      //           selectedBrand: selectedBrandIndex != -1
      //               ? '${brands[selectedBrandIndex]['name']} Series'
      //               : null,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}

// class BrandSelector extends StatelessWidget {
//   final List<Map<String, String>> brands;
//   final int selectedIndex;
//   final Function(int) onBrandSelected;
//
//   const BrandSelector({
//     required this.brands,
//     required this.selectedIndex,
//     required this.onBrandSelected,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("Choose Brand", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         const SizedBox(height: 10),
//         SizedBox(
//           height: 60,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: brands.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 10),
//             itemBuilder: (context, index) {
//               return ChoiceChip(
//                 showCheckmark: false,
//                 label: Row(
//                   children: [
//                     Image.network(brands[index]["imageUrl"]!, width: 40, height: 50),
//                     const SizedBox(width: 8),
//                     Text(brands[index]["name"]!),
//                   ],
//                 ),
//                 selected: selectedIndex == index,
//                 onSelected: (bool selected) {
//                   if(selectedIndex==index) {
//                     onBrandSelected(-1);
//                   }else{
//                     onBrandSelected(index);
//
//                   }
//                 },
//                 selectedColor: Colors.blue.withOpacity(0.2),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// class PopularSeries extends StatelessWidget {
//   final String query;
//   final String? selectedBrand;
//
//   const PopularSeries({required this.query, required this.selectedBrand, Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     Query queryRef = FirebaseFirestore.instance.collection('products').orderBy('watt', descending: true);
//     // if (selectedBrand != null) {
//     //   queryRef = queryRef.where('brand', isEqualTo: selectedBrand);
//     // }
//     //
//     // if (query.isNotEmpty) {
//     //   queryRef = queryRef
//     //       .where('name', isGreaterThanOrEqualTo: query)
//     //       .where('name', isGreaterThanOrEqualTo: '$query\uf8ff');
//     // }
//     print(queryRef.snapshots());
//     return StreamBuilder<QuerySnapshot>(
//       stream: queryRef.snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No Data Found'));
//         }
//         List<QueryDocumentSnapshot<Object?>>? filteredDocs;
//         filteredDocs=snapshot.data?.docs;
//         if (selectedBrand != null) {
//           print('brand $selectedBrand');
//           filteredDocs = snapshot.data!.docs.where((doc) {
//             String name = doc['brand'].toString().toLowerCase();
//             return name==(selectedBrand.toString().toLowerCase()); // Local filtering for "contains"
//           }).toList();
//         }
//         if (query.isNotEmpty) {
//           filteredDocs = snapshot.data!.docs.where((doc) {
//             String name = doc['name'].toString().toLowerCase();
//             return name.contains(
//                 query.toLowerCase()); // Local filtering for "contains"
//           }).toList();
//         }
//         if(filteredDocs?.isEmpty??false){
//           return const Center(child: Text('No Data Found'));
//         }
//         return AlignedGridView.count(
//           crossAxisCount: 2,
//           mainAxisSpacing: 16,
//           crossAxisSpacing: 16,
//           itemCount: filteredDocs?.length??0,
//           itemBuilder: (context, index) {
//             var data = filteredDocs?[index].data() as Map<String, dynamic>;
//             return InkWell(
//                 onTap: (){
//                   ProductDetailsScreen(data,productId:filteredDocs?[index].id).launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
//                 },
//                 child: ProductCard(data,productId:filteredDocs?[index].id));
//           },
//         );
//       },
//     );
//   }
//   double _calculateAspectRatio(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     return screenWidth / (screenHeight * 1.1); // Adjust the factor (0.55) as needed
//   }
// }
//
// class ProductCard extends StatefulWidget {
//   ProductCard(this.data, {Key? key, this.productId,this.isFromAdmin=false}) : super(key: key);
//   Map<String, dynamic>? data;
//   String? productId;
//   bool isFromAdmin;
//
//   @override
//   State<ProductCard> createState() => _ProductCardState();
// }
//
// class _ProductCardState extends State<ProductCard> {
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   final FirebaseAuth auth = FirebaseAuth.instance;
//
//   Future<void> toggleFavorite(String productId) async {
//     String userId = auth.currentUser!.uid;
//
//     // Optimistically update UI
//     setState(() {
//       isFav = !isFav;
//     });
//
//     DocumentReference productRef = firestore.collection('products').doc(productId);
//
//     try {
//       DocumentSnapshot productSnapshot = await productRef.get();
//       List<String> favoritedBy = List<String>.from(productSnapshot['favoritedBy'] ?? []);
//
//       if (favoritedBy.contains(userId)) {
//         // Remove from favorites in Firestore
//         await productRef.update({
//           'favoritedBy': FieldValue.arrayRemove([userId]),
//         });
//       } else {
//         // Add to favorites in Firestore
//         await productRef.update({
//           'favoritedBy': FieldValue.arrayUnion([userId]),
//         });
//       }
//     } catch (e) {
//       // If Firestore update fails, revert the UI change
//       setState(() {
//         isFav = !isFav;
//       });
//       print("Error updating favorite status: $e");
//     }
//   }
//
//   Future<bool> isFavorite(String productId) async {
//     DocumentSnapshot productSnapshot =
//     await firestore.collection('products').doc(productId).get();
//
//     List<String> favoritedBy = List<String>.from(productSnapshot['favoritedBy'] ?? []);
//     return favoritedBy.contains(sharedPref.getString('user_id'));
//   }
//   @override
//   void initState() {
//     checkFavorite();
//     super.initState();
//   }
//   bool isFav=false;
//   void checkFavorite() async {
//     isFav = await isFavorite(widget.productId??'');
//     if(mounted) {
//       setState(() {});
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     List<dynamic> ratingValues = widget.data?['rate'].toList();
//     double totalRating = ratingValues.fold(0, (sum, rating) => sum + rating);
//     double averageRating = ratingValues.isNotEmpty ? totalRating / ratingValues.length : 0;
//
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Stack(
//             children: [
//               Container(
//                 height: 250,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius:
//                   const BorderRadius.vertical(top: Radius.circular(12)),
//                 ),
//                 child:widget.data?['image_url']==null ?SizedBox(): Image.network(widget.data?['image_url']),
//               ),
//               if(widget.isFromAdmin) Positioned(
//                 top: 16,
//                 right: 16,
//                 child: Row(
//                   spacing: 10,
//                   children: [
//                     Container(
//                         padding: EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           // color: Colors.green,
//                           gradient: LinearGradient(
//                             colors: [Color(0xFF47C6EB), Color(0xFF54E88C)],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.circular(50),
//                         ),
//                         child:Icon(Icons.edit, color: Colors.white, size: 25)
//                     ).onTap(() async {
//                       AddUpdateProduct(id: widget.productId).launch(context);
//                     }),
//                     Container(
//                         padding: EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           // color: Colors.green,
//                           gradient: LinearGradient(
//                             colors: [Color(0xFF47C6EB), Color(0xFF54E88C)],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.circular(50),
//                         ),
//                         child:Icon(Icons.delete, color: Colors.red, size: 25)
//                     ).onTap(() async {
//                       await  FirebaseFirestore.instance
//                           .collection('products').doc(widget.productId).delete();
//
//                     }),
//                   ],
//                 ),
//               )
//               else Positioned(
//                 top: 16,
//                 right: 16,
//                 child: GestureDetector(
//                   onTap: () async {
//                     print('ddata');
//                     if(sharedPref.getString('user_id')!=null) {
//                       isFav = await isFavorite(widget.productId??'');
//
//                       await toggleFavorite(widget.productId??'');
//                       checkFavorite();
//
//                     }else{
//                       LoginScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
//                     }
//                   },
//                   child: Container(
//                     padding: EdgeInsets.all(4),
//                     decoration: BoxDecoration(
//                       // color: Colors.green,
//                       gradient: LinearGradient(
//                         colors: [Color(0xFF47C6EB), Color(0xFF54E88C)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                     child: isFav?Icon(Icons.favorite_outlined, color: Colors.white, size: 25):Icon(Icons.favorite_border,
//                         color: Colors.white, size: 25),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: 0,
//                 right: 0,
//                 child: Container(
//                   // margin: const EdgeInsets.only(right: 8, bottom: 8),
//                   padding:
//                   const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
//                   decoration: BoxDecoration(
//                     // color: Colors.green,
//                     gradient: LinearGradient(
//                       colors: [Color(0xFF47C6EB), Color(0xFF54E88C)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(10),
//                         bottomRight: Radius.circular(10)),
//                   ),
//                   child: const Icon(
//                     Icons.add,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 widget.data!['brand'],
//                 style: TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 16,
//                     color: Colors.blue),
//               ),
//               Text(
//                 widget.data!['name'],
//                 style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
//               ),
//               SizedBox(height: 4),
//               SizedBox(height: 4),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 spacing: 20,
//                 children: [
//                   Text(
//                     "PKR${widget.data!['price']}",
//                     style: TextStyle(
//                         color: Colors.black54, fontWeight: FontWeight.bold),
//                   ),
//                   Row(
//                     children: [
//                       Icon(Icons.star, color: Colors.yellow, size: 16),
//                       Text(
//                         '$averageRating',
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
