import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';

class NewsEventDetailsScreen extends StatefulWidget {
  @override
  _NewsEventDetailsScreenState createState() => _NewsEventDetailsScreenState();
}

class _NewsEventDetailsScreenState extends State<NewsEventDetailsScreen> {
  int _currentIndex = 0;
  final List<String> imageUrls = [
    "assets/images/img.png",
    "assets/images/img.png",
    "assets/images/img.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            // Your primary page content
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CarouselSlider(
                    items: imageUrls.map((imageUrl) {
                      return Image.asset(
                        imageUrl,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 300,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                  ), // Dots Indicator
                  Positioned(
                    bottom: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: imageUrls.asMap().entries.map((entry) {
                        return Container(
                          width: _currentIndex == entry.key ? 20 : 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            // shape: BoxShape.circle,
                            color: _currentIndex == entry.key
                                ? Colors.green
                                : Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                // margin: EdgeInsets.only(left: 10),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100)),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.black),
                  onPressed: () {},
                ),
              ),
            ),
            // Bottom Sheet
            DraggableScrollableSheet(
              initialChildSize: 0.7,
              // Half screen initially
              minChildSize: 0.7,
              // Minimum size (half screen)
              maxChildSize: 1.0,
              // Full screen when expanded
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
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10)
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Your existing content
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset('assets/icons/location.svg'),
                              const Text(
                                "Lahore Service Center 1",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Event Title
                        const Text(
                          "Primax Solar Solar Inverter Launch",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        // Organizer and Time Row
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Text(
                                "N", // First letter of Life Art
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              "Life Art",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Container(
                              height: 35,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.green,width: 0.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Row(
                                children:  [
                                  SvgPicture.asset('assets/icons/clock.svg', color: Colors.green),
                                  SizedBox(width: 4),
                                  Text("11:00 - 12:00 AM",style:TextStyle(color: Colors.black)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // About Event
                        const Text(
                          "About Event",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Primax Solar Energy proudly hosted an extraordinary event to unveil "
                          "the latest addition to its innovative product lineup: the NEXA Hybrid Solar Inverter. "
                          "Designed to redefine reliability and efficiency, the NEXA series boasts a robust design, "
                          "ensuring unmatched protection against dust, water, and challenging environmental conditions.",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 16),

                        // Bullet Points Section
                        const Text(
                          "The launch event brought together industry leaders,",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),

                        BulletPoint(
                            "Product Presentation: A detailed demonstration of the NEXA Hybrid Inverter’s features, including its hybrid capability for seamless integration with both solar and grid power systems, exceptional energy conversion rates, and enhanced durability."),
                        BulletPoint(
                            "Live Performance Showcase: A hands-on showcase where attendees experienced the inverter’s superior performance in real-time scenarios, emphasizing its ability to withstand extreme conditions while delivering optimal energy output."),
                        BulletPoint(
                            "Expert Talks: Industry experts shared insights into the evolving energy landscape, highlighting how NEXA’s advanced technology can contribute to sustainable living and energy independence."),
                        BulletPoint(
                            "Networking Opportunities: The event facilitated valuable interactions among industry professionals, partners, and renewable energy enthusiasts, fostering collaborations and partnerships for a greener future."),
                        const SizedBox(height: 16),

                        // Final Summary
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "The NEXA Hybrid Solar Inverter launch reaffirmed Primax Solar Energy’s commitment to driving innovation in renewable energy solutions. Attendees left inspired by the possibilities of integrating robust and efficient solar energy systems into everyday life.",
                            style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.black54),
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomButton(text: 'Registration', onPressed: (){},
                        width:400,
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Bullet Point Widget
class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 16, color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}
