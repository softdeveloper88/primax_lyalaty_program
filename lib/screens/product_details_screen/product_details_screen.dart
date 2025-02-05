import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:primax_lyalaty_program/core/utils/comman_widget.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';

class ProductDetailsScreen extends StatefulWidget {
  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  double _rotationY = 0.0; // Rotation angle
  final List<String> productImages = [
    'assets/images/pic1.png',
    'assets/images/pic1.png',
    'assets/images/pic1.png',
    // "https://source.unsplash.com/400x400/?solar,inverter",
    // "https://source.unsplash.com/400x400/?energy,technology",
    // "https://source.unsplash.com/400x400/?electricity,solar",
  ];
  int _currentIndex = 0;
  int _selectedSize = 40;
  final List<int> sizes = [38, 39, 40, 41, 42, 43];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          // margin: EdgeInsets.only(left: 10),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white,
            borderRadius: BorderRadius.circular(100)
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
            onPressed: () {},
          ),
        ),
        title: const Text(
          "NEXA PSE-DUAL-12KW",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
            onPressed: () {},
          ),
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
                    _rotationY += (details.primaryDelta ?? 0) * 0.01;
                  });
                },
                child: Center(
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002) // Perspective
                      ..rotateY(_rotationY), // Rotate on Y-axis
                    child: Image.asset(
                      'assets/images/pic1.png',
                      height: 200,
                      width: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 140,
              left: 0,
              right: 0,
              child: SvgPicture.asset(
                      'assets/images/line.svg',
                      fit: BoxFit.contain,
                    ),

            ),
            // Bottom Sheet
            DraggableScrollableSheet(
              initialChildSize: 0.7, // Half screen initially
              minChildSize: 0.7,     // Minimum size (half screen)
              maxChildSize: 1.0,     // Full screen when expanded
              snap: true,
              snapSizes: const [0.7, 1.0],
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        // Your existing content
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "NEXA SERIES",
                                style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "NEXA PSE-DUAL-12KW",
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: const [
                                  Text(
                                    "\$12.99",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.star, color: Colors.yellow, size: 18),
                                  Text("5.0"),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "• Dual outputs for smart load management\n"
                                    "• Maximum PV input current 27A x 2 (Max 40A)\n"
                                    "• Maximum PV input 6000 x 2 (12000W)",
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              const SizedBox(height: 16),

                              // Gallery Section
                              const Text("Gallery", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Row(
                                children: productImages.map((img) {
                                  int index = productImages.indexOf(img);
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _currentIndex = index;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: _currentIndex == index ? Colors.blue : Colors.transparent,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(img, width: 60, height: 60, fit: BoxFit.cover),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),

                              // Size Selection
                              const Text("Size", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Row(
                                children: sizes.map((size) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedSize = size;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        // color: _selectedSize == size ? Colors.blue : Colors.white,
                                        shape: BoxShape.circle,
                                        gradient: _selectedSize == size ?setGradient():null,
                                        border: Border.all(color: Colors.grey),
                                        boxShadow: [
                                          if (_selectedSize == size)
                                            BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 8)
                                        ],
                                      ),
                                      child: Text(
                                        "$size",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedSize == size ? Colors.white : Colors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Price", style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
                                const Text("\$12.99", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            CustomButton(
                              onPressed: () {},
                              text: 'Add To Cart',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
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
      //                                 "\$12.99",
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
      //                         const Text("\$12.99",
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
