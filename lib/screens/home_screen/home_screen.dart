import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/screens/home_screen/widget/header_widget.dart';
import 'package:primax_lyalaty_program/screens/home_screen/widget/main_widget.dart';
import 'package:primax_lyalaty_program/screens/home_screen/widget/searchbar_widget.dart';
import 'package:primax_lyalaty_program/screens/product_details_screen/product_details_screen.dart';
import 'package:sizer/sizer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  mainWidget(){
    return Column(
      children: [
          const BrandSelector(),
          const SizedBox(height: 20),
          // Popular Series Section
          Expanded(
            child: const PopularSeries(),
          ),

      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainWidget(mWidget: mainWidget(),)
      // Stack(
      //   children: [
      //     SizedBox(
      //       width: double.maxFinite,
      //       height: double.maxFinite,
      //       child: Image.asset('assets/images/img_splash.png',fit: BoxFit.cover,),
      //     ),
      //     // Gradient background
      //     Container(
      //       height: 160,
      //       decoration: const BoxDecoration(
      //         borderRadius: BorderRadius.only(bottomLeft:Radius.circular(10),bottomRight: Radius.circular(10) ),
      //         gradient: LinearGradient(
      //           colors: [Color(0xFF47C6EB), Color(0xFF54E88C)],
      //           begin: Alignment.topLeft,
      //           end: Alignment.bottomRight,
      //         ),
      //       ),
      //     ),
      //     SafeArea(
      //       child: Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             // Header Section
      //             const SizedBox(height: 40),
      //
      //             const HeaderWidget(),
      //             const SizedBox(height: 20),
      //             // Search Bar
      //             const SearchBarWidget(),
      //             const SizedBox(height: 20),
      //             // Brand Selector
      //             const BrandSelector(),
      //             const SizedBox(height: 20),
      //             // Popular Series Section
      //             Expanded(
      //               child: const PopularSeries(),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}

class BrandSelector extends StatelessWidget {
  const BrandSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Choose Brand",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            _brandButton("Nexa", "assets/images/pic2.png"),
            _brandButton("Galaxy", "assets/images/pic2.png"),
            _brandButton("Venus", "assets/images/pic2.png"),
          ],
        ),
      ],
    );
  }

  Widget _brandButton(String name, String assetPath) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8,vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          spacing: 16,
          children: [
            Container(
              height: 40,
              width: 40,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Image.asset(assetPath, fit: BoxFit.cover), // Replace with actual brand image
            ),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PopularSeries extends StatelessWidget {
  const PopularSeries({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Popular Series",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              "View All",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 0,
              crossAxisSpacing: 20,
            childAspectRatio: MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height ),
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              return InkWell(
                  onTap: (){
                    ProductDetailsScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
                  },
                  child: const ProductCard());
            },
          ),
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),

          ),
          child: Stack(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/pic1.png"), // Replace with actual product image
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    // color: Colors.green,
                    gradient: LinearGradient(
                      colors: [Color(0xFF47C6EB), Color(0xFF54E88C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(Icons.favorite_border, color: Colors.white, size: 25),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  // margin: const EdgeInsets.only(right: 8, bottom: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 6),
                  decoration: BoxDecoration(
                    // color: Colors.green,
                    gradient: LinearGradient(
                      colors: [Color(0xFF47C6EB), Color(0xFF54E88C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10),bottomRight:  Radius.circular(10)),
                  ),
                  child: const Icon(Icons.add, color: Colors.white,size: 24,),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "NEXA Series",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16,color: Colors.blue),
              ),
              Text(
                "NEXA PSE-DUAL-12KW",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              SizedBox(height: 4),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 20,
                children: [
                  Text(
                    "\$12.99",
                    style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow, size: 16),
                      Text("5.0"),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        backgroundColor: const Color(0xFF47C6EB),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            SearchBar(),
            SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Text(
                  "No Results Found",
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




