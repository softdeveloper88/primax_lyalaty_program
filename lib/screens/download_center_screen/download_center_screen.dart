import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DownloadCenterScreen extends StatefulWidget {
  const DownloadCenterScreen({super.key});

  @override
  State<DownloadCenterScreen> createState() => _DownloadCenterScreenState();
}

class _DownloadCenterScreenState extends State<DownloadCenterScreen> {
  int selectedCategory = 0; // 0 for Product Datasheets, 1 for User Manuals

  final List<Map<String, String>> brands = [
    {"name": "Nexa", "image": "assets/images/pic1.png"},
    {"name": "Galaxy", "image": "assets/images/pic2.png"},
    {"name": "Venus", "image": "assets/images/pic3.png"},
  ];

  final List<String> documentCategories = [
    "Product Datasheets",
    "Product User Manuals"
  ];

  final List<String> images = [
    "assets/image.png",
    "assets/image.png",
    "assets/image.png",
    "assets/image.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:  Container(
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
          "Download Center",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),

      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar with Back Button and Title
              const SizedBox(height: 16),

              // Choose Brand Section
              const Text(
                "Choose Brand",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: brands.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return ChoiceChip(
                      showCheckmark: false,
                      label: Row(
                        children: [
                          Image.asset(brands[index]["image"]!,
                              width: 40, height: 50),
                          const SizedBox(width: 8),
                          Text(brands[index]["name"]!),
                        ],
                      ),
                      selected: selectedCategory == index,
                      onSelected: (bool selected) {
                        setState(() {
                          selectedCategory = index;
                        });
                      },
                      color: WidgetStateProperty.all(
                        Colors.grey.shade100,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: Colors.blue.withOpacity(0.2),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: selectedCategory == index
                              ? Colors.blue
                              : Colors.grey.shade200,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Document Category Toggle
              const Text(
                "Document Category",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(documentCategories.length, (index) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: selectedCategory == index
                                  ? Colors.blue
                                  : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                          color: selectedCategory == index
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            documentCategories[index],
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: selectedCategory == index
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Grid of Images with Download Button
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            images[index],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            // margin: const EdgeInsets.only(right: 8, bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 6),
                            decoration: BoxDecoration(
                              // color: Colors.green,
                              gradient: LinearGradient(
                                colors: [Color(0xFF47C6EB), Color(0xFF54E88C)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                            ),
                            child:  SvgPicture.asset(
                              height: 25,
                              width: 25,
                              'assets/icons/ic_download.svg',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
