import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/screens/create_account_screen/news_event_details_screen/news_event_details_screen.dart';
import 'package:primax_lyalaty_program/screens/home_screen/widget/main_widget.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';

import '../../core/utils/comman_widget.dart';

class NewsEventScreen extends StatefulWidget {
  const NewsEventScreen({super.key});
  @override
  State<NewsEventScreen> createState() => _NewsEventScreenState();
}

class _NewsEventScreenState extends State<NewsEventScreen> {
  int selectedIndex=0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: MainWidget(
      mWidget: Column(
        children: [
          NewsEventsTabs(callback: (i){
            setState(() {
              selectedIndex=i;
            });
          }),
         Expanded(
            child: ListView.builder(
              itemCount: 3,
              padding: EdgeInsets.all(8),
              itemBuilder: (context, index) {
                return  NewsCard(selectedIndex);
              }
            ),
          )
        ],
      ),
    )
        );
  }
}

class NewsEventsTabs extends StatefulWidget {
   NewsEventsTabs({this.callback,Key? key}) : super(key: key);
   Function(int)? callback;
  @override
  _NewsEventsTabsState createState() => _NewsEventsTabsState();
}

class _NewsEventsTabsState extends State<NewsEventsTabs> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 6,
                  ),
                ],
                borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                _tabButton("News", 0,(){
                  widget.callback!(0);
                }),
                const SizedBox(width: 8),
                _tabButton("Events", 1,(){
                  widget.callback!(1);

                }),
              ],
            )),
        const SizedBox(height: 10),
      if(selectedIndex==0)  Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: const [
            FilterChipWidget(label: "Primax News"),
            FilterChipWidget(label: "Market News"),
            FilterChipWidget(label: "Activities"),
          ],
        ),
      ],
    );
  }

  Widget _tabButton(String title, int index,callback) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
            callback();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: selectedIndex == index ? setGradient() : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selectedIndex == index ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  final String label;

  const FilterChipWidget({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey,width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}

class NewsCard extends StatefulWidget {
   NewsCard(this.selectedIndex, {super.key});
  int selectedIndex;
  @override
  State<StatefulWidget> createState() =>_NewsCardState();

}
class _NewsCardState extends State<NewsCard> {
  int _currentIndex = 0;
  final List<String> imageUrls = [
    "assets/images/img.png",
    "assets/images/img.png",
    "assets/images/img.png",
  ];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        NewsEventDetailsScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 4
            ),
          ],

        ),
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slideshow with images
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CarouselSlider(
                    items: imageUrls.map((imageUrl) {
                      return Image.asset(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 180,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                  ),
                  // Dots Indicator
                  Positioned(
                    bottom: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: imageUrls.asMap().entries.map((entry) {
                        return Container(
                          width:  _currentIndex == entry.key? 20:8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            // shape: BoxShape.circle,
                            color: _currentIndex == entry.key ? Colors.green : Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            // News Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Primax Solar Inverter Launch",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Primax Solar Energy proudly hosted an extraordinary event.",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  if(widget.selectedIndex==1)  Container(
                    height: 35,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF1FA3D1).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                      //border: Border.all(color: Colors.grey,width: 0.5),

                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children:  [
                            SvgPicture.asset('assets/icons/location.svg', color: Colors.green),
                            SizedBox(width: 4),
                            Text("Lahore Service Center 1"),
                          ],
                        ),
                        Row(
                          children:  [
                            SvgPicture.asset('assets/icons/clock.svg', color: Colors.green),
                            SizedBox(width: 4),
                            Text("11:00 - 12:00 AM"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 35,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey,width: 0.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          children:  [
                           if(widget.selectedIndex==0) SvgPicture.asset('assets/icons/clock.svg', color: Colors.green),
                            if(widget.selectedIndex==0)SizedBox(width: 4),
                            Text(widget.selectedIndex==0?"11:00 - 12:00 AM":"# Exhibition Activity",style:TextStyle(color: Colors.green)),
                          ],
                        ),
                      ),
                      CustomButton(
                        height: 35,
                        width: 150,
                        onPressed: () {},
                        text: widget.selectedIndex==0?"Checkout":"Registration",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventCard extends StatefulWidget {
  const EventCard({super.key});

  @override
  State<StatefulWidget> createState() =>_EventCardState();

}
class _EventCardState extends State<NewsCard> {
  int _currentIndex = 0;
  final List<String> imageUrls = [
    "assets/images/img.png",
    "assets/images/img.png",
    "assets/images/img.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 4
          ),
        ],

      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slideshow with images
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CarouselSlider(
                  items: imageUrls.map((imageUrl) {
                    return Image.asset(
                      imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
                  options: CarouselOptions(
                    height: 180,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 1.0,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
                // Dots Indicator
                Positioned(
                  bottom: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imageUrls.asMap().entries.map((entry) {
                      return Container(
                        width:  _currentIndex == entry.key? 20:8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // shape: BoxShape.circle,
                          color: _currentIndex == entry.key ? Colors.green : Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // News Details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Primax Solar Inverter Launch",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Primax Solar Energy proudly hosted an extraordinary event.",
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 35,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey,width: 0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.access_time, size: 16, color: Colors.green),
                          SizedBox(width: 4),
                          Text("11:00 - 12:00 AM"),
                        ],
                      ),
                    ),
                    CustomButton(
                      height: 35,
                      onPressed: () {},
                      text: "Checkout",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

