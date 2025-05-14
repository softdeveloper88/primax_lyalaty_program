import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/core/utils/comman_widget.dart';
import 'package:primax_lyalaty_program/main.dart';
import 'package:primax_lyalaty_program/screens/checkout.dart';
import 'package:primax_lyalaty_program/screens/login_screen/login_screen.dart';
import 'package:primax_lyalaty_program/screens/my_cart_screen.dart';
import 'package:primax_lyalaty_program/widgets/comman_back_button.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';


class ProductDetailsScreen extends StatefulWidget {
  ProductDetailsScreen(this.data, {Key? key, this.productId, this.isFromAdmin=false}) : super(key: key);
  Map<String, dynamic>? data;
  String? productId;
  bool isFromAdmin;

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  double _rotationY = 0.0; // Rotation angle
   List<dynamic> productImages=[];
  int _currentIndex = 0;
  int _currentImageIndex = 0;
  int _selectedSize = 40;
   List<dynamic> sizes = [];

   String selectImageUrl='';
   bool isExpanded=false;
  @override
  void initState() {
    productImages=widget.data?['gallery'];
    sizes=widget.data?['size'];
    selectImageUrl=widget.data?['gallery'][0];
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    List<dynamic> ratingValues = widget.data?['rate'].toList();
    double totalRating = ratingValues.fold(0, (sum, rating) => sum + rating);
    double averageRating = ratingValues.isNotEmpty ? totalRating / ratingValues.length : 0;

    String previewText = widget.data?['description'].replaceAll(RegExp(r'<[^>]*>'), ''); // Remove HTML tags
    previewText = previewText.length > 200 ? "${previewText.substring(0, 200)}..." : previewText;


    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        elevation: 0,
        leading: CommonBackButton(onPressed: (){
          Navigator.pop(context);
        }),
        title:  Text(
          widget.data?['name'],
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
          //   onPressed: () {},
          // ),
        ],
      ),
      body: Stack(
          children: [
            // Your primary page content
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    if (details.primaryDelta! < 0) {
                      // Swipe left -> next image
                      if (_currentImageIndex < productImages.length - 1) {
                        _currentImageIndex++;
                      }
                    } else {
                      // Swipe right -> previous image
                      if (_currentImageIndex > 0) {
                        _currentImageIndex--;
                      }
                    }
                    selectImageUrl = productImages[_currentImageIndex];
                  });
                  // setState(() {
                  //
                  //   if(_currentImageIndex<productImages.length) {
                  //     _currentImageIndex++;
                  //     selectImageUrl = productImages[_currentImageIndex];
                  //   }
                  //   _rotationY += (details.primaryDelta ?? 0) * 0.01;
                  // });
                },
                child: Center(
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002) // Perspective
                      ..rotateY(_rotationY), // Rotate on Y-axis
                    child: Image.network(
                      selectImageUrl,
                      height: 200,
                      width: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 150,
              left: 0,
              right: 0,
              child: SvgPicture.asset(
                      'assets/images/line.svg',
                      fit: BoxFit.contain,
                    ),

            ),
            // Bottom Sheet
            DraggableScrollableSheet(
              initialChildSize: 0.65, // Slightly larger to show gallery fully
              minChildSize: 0.65,     // Minimum size to ensure gallery visibility
              maxChildSize: 1.0,     // Full screen when expanded
              snap: true,
              snapSizes: const [0.65, 1.0],
              builder: (context, scrollController) {
                return Container(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: widget.data?['is_purchasable'] ? 80 : 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: SingleChildScrollView(
                    controller:scrollController,
                    child: Column(
                      children: [
                        // Your existing content
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(
                          widget.data?['brand'],
                                style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                               Text(
                                widget.data?['name'],
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children:  [
                                  if(widget.data?['is_purchasable']) Text(
                                    "PKR${widget.data?['price']}",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.star, color: Colors.yellow, size: 18),
                                  Text(averageRating.toString()),
                                ],
                              ),
                              const SizedBox(height: 8),

                              isExpanded
                                  ? HtmlWidget( widget.data?['description']) // Show full HTML content
                                  : HtmlWidget( "<p>$previewText</p>"), // Show trimmed content

                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    isExpanded = !isExpanded;
                                  });
                                },
                                child: Text(isExpanded ? "See Less" : "See More"),
                              ),
                              const SizedBox(height: 16),

                              // Gallery Section
                              const Text("Gallery", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                            Container(
                              height: 80, // Fixed height for the gallery
                              margin: EdgeInsets.only(bottom: 16), // Add bottom margin
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(productImages.length, (index) {
                                    final img = productImages[index];
  
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _currentIndex = index;
                                          selectImageUrl = img;
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: _currentIndex == index ? Colors.blue : Colors.grey,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(img, width: 60, height: 60, fit: BoxFit.cover),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),

                              // const SizedBox(height: 16),

                              // Size Selection
                              // const Text("Size", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              // const SizedBox(height: 8),
                              // Row(
                              //   children: sizes.map((size) {
                              //     return GestureDetector(
                              //       onTap: () {
                              //         setState(() {
                              //           _selectedSize = size;
                              //         });
                              //       },
                              //       child: Container(
                              //         margin: const EdgeInsets.only(right: 8),
                              //         padding: const EdgeInsets.all(12),
                              //         decoration: BoxDecoration(
                              //           // color: _selectedSize == size ? Colors.blue : Colors.white,
                              //           shape: BoxShape.circle,
                              //           gradient: _selectedSize == size ?setGradient():null,
                              //           border: Border.all(color: Colors.grey),
                              //           boxShadow: [
                              //             if (_selectedSize == size)
                              //               BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 8)
                              //           ],
                              //         ),
                              //         child: Text(
                              //           "$size",
                              //           style: TextStyle(
                              //             fontSize: 16,
                              //             fontWeight: FontWeight.bold,
                              //             color: _selectedSize == size ? Colors.white : Colors.black,
                              //           ),
                              //         ),
                              //       ),
                              //     );
                              //   }).toList(),
                              // ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),

      bottomNavigationBar: widget.data?['is_purchasable']? BottomAppBar(
        color: Colors.white,
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Price", style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
                Text("PKR${widget.data?['price']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Visibility(
            visible: !(widget.isFromAdmin),
            child: Expanded(
              child: CustomButton(
                onPressed: () {
                  // if(widget.data?['is_purchasable']) {
                  if (sharedPref.getString('user_id') !=
                      null) {
                    print('share');
                    addToCart(widget.productId ?? '',
                        widget.data!['name'],
                        widget.data!['price'],
                        widget.data!['image_url']);
                    MyCartScreen().launch(context,
                        pageRouteAnimation: PageRouteAnimation
                            .Slide);
                  } else {
                    LoginScreen().launch(context,
                        pageRouteAnimation: PageRouteAnimation
                            .Slide);
                  }
                  // }else{
                  //   toast("You can't purchase this product please try again later",length: Toast.LENGTH_LONG);
                  // }
                },
                text: 'Add To Cart',
              ),
            ),
          ),
        ],
            ),
      ):SizedBox(),
      );
    }
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> addToCart(String productId, String name, double price, String imageUrl) async {
    String userId = auth.currentUser!.uid;
    DocumentReference cartItemRef = firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId);

    DocumentSnapshot cartItemSnapshot = await cartItemRef.get();

    if (cartItemSnapshot.exists) {
      // Product already in cart, increase quantity
      await cartItemRef.update({
        'quantity': FieldValue.increment(1),
      });
    } else {
      // Product not in cart, add new item
      await cartItemRef.set({
        'id': productId,
        'name': name,
        'price': price,
        'quantity': 1,
        'imageUrl': imageUrl,
      });
    }
  }
      // SingleChildScrollView(
      //   child: Stack(
      //     // crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       // Product Image with 3D Rotation
      //       GestureDetector(
      //         onHorizontalDragUpdate: (details) {
      //           setState(() {
      //             _rotationY += (details.primaryDelta ?? 0) * 0.01;
      //           });
      //         },
      //         child: Center(
      //           child: Transform(
      //             alignment: Alignment.center,
      //             transform: Matrix4.identity()
      //               ..setEntry(3, 2, 0.002) // Perspective
      //               ..rotateY(_rotationY), // Rotate on Y-axis
      //             child: Image.asset(
      //               'assets/images/pic2.png',
      //               height: 200,
      //               width: 200,
      //               fit: BoxFit.contain,
      //             ),
      //           ),
      //         ),
      //       ),
      //       // const SizedBox(height: 10),
      //
      //       // Product Title, Price & Rating
      //       DraggableScrollableSheet(
      //           initialChildSize: 0.5,
      //           // Half screen initially
      //           minChildSize: 0.5,
      //           // Minimum size (half screen)
      //           maxChildSize: 1.0,
      //           // Full screen when expanded
      //           snap: true,
      //           snapSizes: const [0.5, 1.0],
      //           builder: (context, scrollController) {
      //             return Container(
      //                 constraints: BoxConstraints(maxHeight: 600),
      //                 padding: const EdgeInsets.all(16),
      //                 decoration: const BoxDecoration(
      //                   color: Colors.white,
      //                   borderRadius: BorderRadius.only(
      //                       topLeft: Radius.circular(20),
      //                       topRight: Radius.circular(20)),
      //                   boxShadow: [
      //                     BoxShadow(color: Colors.black12, blurRadius: 10)
      //                   ],
      //                 ),
      //                 child: Column(
      //                   children: [
      //                     Padding(
      //                       padding:
      //                           const EdgeInsets.symmetric(horizontal: 16.0),
      //                       child: Column(
      //                         crossAxisAlignment: CrossAxisAlignment.start,
      //                         children: [
      //                           const Text(
      //                             "NEXA SERIES",
      //                             style: TextStyle(
      //                                 fontSize: 14,
      //                                 color: Colors.blue,
      //                                 fontWeight: FontWeight.bold),
      //                           ),
      //                           const SizedBox(height: 4),
      //                           const Text(
      //                             "NEXA PSE-DUAL-12KW",
      //                             style: TextStyle(
      //                                 fontSize: 22,
      //                                 fontWeight: FontWeight.bold),
      //                           ),
      //                           const SizedBox(height: 4),
      //                           Row(
      //                             children: const [
      //                               Text(
      //                                 "PKR12.99",
      //                                 style: TextStyle(
      //                                     fontSize: 18,
      //                                     fontWeight: FontWeight.bold),
      //                               ),
      //                               SizedBox(width: 8),
      //                               Icon(Icons.star,
      //                                   color: Colors.yellow, size: 18),
      //                               Text("5.0"),
      //                             ],
      //                           ),
      //                           const SizedBox(height: 8),
      //                           const Text(
      //                             "• Dual outputs for smart load management\n"
      //                             "• Maximum PV input current 27A x 2 (Max 40A)\n"
      //                             "• Maximum PV input 6000 x 2 (12000W)",
      //                             style: TextStyle(
      //                                 fontSize: 14, color: Colors.black54),
      //                           ),
      //                           const SizedBox(height: 16),
      //
      //                           // Gallery Section
      //                           const Text("Gallery",
      //                               style: TextStyle(
      //                                   fontSize: 16,
      //                                   fontWeight: FontWeight.bold)),
      //                           const SizedBox(height: 8),
      //                           Row(
      //                             children: productImages.map((img) {
      //                               int index = productImages.indexOf(img);
      //                               return GestureDetector(
      //                                 onTap: () {
      //                                   setState(() {
      //                                     _currentIndex = index;
      //                                   });
      //                                 },
      //                                 child: Container(
      //                                   margin: const EdgeInsets.only(right: 8),
      //                                   padding: const EdgeInsets.all(4),
      //                                   decoration: BoxDecoration(
      //                                     border: Border.all(
      //                                       color: _currentIndex == index
      //                                           ? Colors.blue
      //                                           : Colors.transparent,
      //                                       width: 2,
      //                                     ),
      //                                     borderRadius:
      //                                         BorderRadius.circular(10),
      //                                   ),
      //                                   child: ClipRRect(
      //                                     borderRadius:
      //                                         BorderRadius.circular(8),
      //                                     child: Image.asset(img,
      //                                         width: 60,
      //                                         height: 60,
      //                                         fit: BoxFit.cover),
      //                                   ),
      //                                 ),
      //                               );
      //                             }).toList(),
      //                           ),
      //                           const SizedBox(height: 16),
      //
      //                           // Size Selection
      //                           const Text("Size",
      //                               style: TextStyle(
      //                                   fontSize: 16,
      //                                   fontWeight: FontWeight.bold)),
      //                           const SizedBox(height: 8),
      //                           Row(
      //                             children: sizes.map((size) {
      //                               return GestureDetector(
      //                                 onTap: () {
      //                                   setState(() {
      //                                     _selectedSize = size;
      //                                   });
      //                                 },
      //                                 child: Container(
      //                                   margin: const EdgeInsets.only(right: 8),
      //                                   padding: const EdgeInsets.all(12),
      //                                   decoration: BoxDecoration(
      //                                     color: _selectedSize == size
      //                                         ? Colors.blue
      //                                         : Colors.white,
      //                                     shape: BoxShape.circle,
      //                                     border:
      //                                         Border.all(color: Colors.grey),
      //                                     boxShadow: [
      //                                       if (_selectedSize == size)
      //                                         BoxShadow(
      //                                             color: Colors.blue
      //                                                 .withOpacity(0.4),
      //                                             blurRadius: 8)
      //                                     ],
      //                                   ),
      //                                   child: Text(
      //                                     "$size",
      //                                     style: TextStyle(
      //                                       fontSize: 16,
      //                                       fontWeight: FontWeight.bold,
      //                                       color: _selectedSize == size
      //                                           ? Colors.white
      //                                           : Colors.black,
      //                                     ),
      //                                   ),
      //                                 ),
      //                               );
      //                             }).toList(),
      //                           ),
      //                           const SizedBox(height: 20),
      //                         ],
      //                       ),
      //                     ),
      //                     Row(
      //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                       children: [
      //                         const Text("PKR12.99",
      //                             style: TextStyle(
      //                                 fontSize: 18,
      //                                 fontWeight: FontWeight.bold)),
      //                         ElevatedButton(
      //                           onPressed: () {},
      //                           style: ElevatedButton.styleFrom(
      //                             padding: const EdgeInsets.symmetric(
      //                                 horizontal: 40, vertical: 12),
      //                             shape: RoundedRectangleBorder(
      //                                 borderRadius: BorderRadius.circular(30)),
      //                             backgroundColor: Colors.blue,
      //                           ),
      //                           child: const Text("Add To Cart",
      //                               style: TextStyle(fontSize: 16)),
      //                         ),
      //                       ],
      //                     ),
      //                   ],
      //                 ));
      //           })
      //     ],
      //   ),
      // ),

      // Bottom Add to Cart Section
    // );
  // }
}


class ImageGallery3D extends StatefulWidget {
  ImageGallery3D(this.productImages);
  List<String> productImages;

  @override
  _ImageGallery3DState createState() => _ImageGallery3DState();
}

class _ImageGallery3DState extends State<ImageGallery3D> {

  int _currentImageIndex = 0;
  double _rotationX = 0;
  double _rotationY = 0;
  double _targetRotationY = 0;
  double _targetRotationX = 0;
  double _opacity = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onScaleUpdate: (details) {
            setState(() {
              _targetRotationX += details.focalPointDelta.dy * 0.005;
              _targetRotationY += details.focalPointDelta.dx * 0.005;
            });
          },
          onHorizontalDragEnd: (details) {
            setState(() {
              if (details.primaryVelocity! < 0) {
                // Swipe left -> Next image
                if (_currentImageIndex < widget.productImages.length - 1) {
                  _changeImage(_currentImageIndex + 1);
                }
              } else {
                // Swipe right -> Previous image
                if (_currentImageIndex > 0) {
                  _changeImage(_currentImageIndex - 1);
                }
              }
            });
          },
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: _rotationY, end: _targetRotationY),
            duration: const Duration(milliseconds: 500),
            builder: (context, double rotY, child) {
              return TweenAnimationBuilder(
                tween: Tween<double>(begin: _rotationX, end: _targetRotationX),
                duration: const Duration(milliseconds: 500),
                builder: (context, double rotX, child) {
                  return TweenAnimationBuilder(
                    tween: Tween<double>(begin: _opacity, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, double opacity, child) {
                      return Opacity(
                        opacity: opacity,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.002) // Perspective effect
                            ..rotateX(rotX) // Smooth X rotation
                            ..rotateY(rotY), // Smooth Y rotation
                          child: Image.network(
                            widget.productImages[_currentImageIndex],
                            height: 200,
                            width: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _changeImage(int newIndex) {
    setState(() {
      _opacity = 0.0; // Fade out effect
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      setState(() {
        _currentImageIndex = newIndex;
        _opacity = 1.0; // Fade in new image
      });
    });
  }
}
