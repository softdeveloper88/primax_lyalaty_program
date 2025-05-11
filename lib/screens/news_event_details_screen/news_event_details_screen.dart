import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/core/utils/comman_data.dart';
import 'package:primax_lyalaty_program/main.dart';
import 'package:primax_lyalaty_program/screens/login_screen/login_screen.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';

class NewsEventDetailsScreen extends StatefulWidget {
  NewsEventDetailsScreen(this.data,this.isEvent, {super.key});
  DocumentSnapshot<Object?> data;
  bool isEvent;
  @override
  _NewsEventDetailsScreenState createState() => _NewsEventDetailsScreenState();
}

class _NewsEventDetailsScreenState extends State<NewsEventDetailsScreen> {
  int _currentIndex = 0;

  Future<bool> isRegister(String eventId) async {
    DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance.collection('events').doc(eventId).get();

    List<String> registerUser = List<String>.from(eventSnapshot['register_users'] ?? []);
    return registerUser.contains(sharedPref.getString('user_id'));
  }
  bool isRegisterUser=false;
  void checkRegistration() async {
    isRegisterUser = await isRegister(widget.data.id??'');
    setState(() {});
  }
  @override
  void initState() {
    if(widget.isEvent) {
      checkRegistration();
    }
    super.initState();
  }
  Future<void> toggleRegister(String eventId) async {

    // Optimistically update UI
    setState(() {
      isRegisterUser = !isRegisterUser;
    });

    DocumentReference eventPref = FirebaseFirestore.instance.collection('events').doc(eventId);

    try {
      DocumentSnapshot productSnapshot = await eventPref.get();
      List<String> registerUser = List<String>.from(productSnapshot['register_users'] ?? []);

      if (registerUser.contains(sharedPref.getString('user_id'))) {
        // Remove from favorites in Firestore
        await eventPref.update({
          'register_users': FieldValue.arrayRemove([sharedPref.getString('user_id')]),
        });

      } else {
        // Add to favorites in Firestore
        await eventPref.update({
          'register_users': FieldValue.arrayUnion([sharedPref.getString('user_id')]),
        });
        sendNotificationToAllUsers(userId: sharedPref.getString('user_id'),title: 'You have successfully registered in event',type: 'event_register',id:'' ,newPrice:0.0,oldPrice: 0.0,);

      }
    } catch (e) {
      // If Firestore update fails, revert the UI change
      setState(() {
        isRegisterUser = !isRegisterUser;
      });
      print("Error updating Register status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = List<String>.from(widget.data['images'] ?? []);
    String title = widget.data['title'] ?? "No Title";
    String description = widget.data['description'] ?? "No Description";
    String category = widget.data['category'] ?? "General";
    String author = widget.data['author'] ?? "Primax";
    String authorImage = widget.data['author_image'] ?? "Primax";
    String location = widget.data['location'] ?? "No Location";
    String time = widget.data['time'] ?? "No Time";

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
                      return Image.network(
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
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
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Visibility(
                                  visible: !widget.isEvent,
                                  child: SvgPicture.asset('assets/icons/location.svg')),
                               Text(
                                 !widget.isEvent?location:category,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Event Title
                         Text(
                          title,
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        // Organizer and Time Row
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundImage: (authorImage.contains('http://')|| authorImage.contains('https://'))?NetworkImage(
                                authorImage, // First letter of Life Art
                               ):AssetImage('assets/images/app_logo.png'),
                            ),
                            const SizedBox(width: 5),
                             Text(
                               'By ${author.replaceAll("By ", '')}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Visibility(
                              visible: widget.isEvent,
                              child: Container(
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
                                    Text(time,style:TextStyle(color: Colors.black)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // About Event
                         Text(
                       widget.isEvent?  "About Event":"News",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                         HtmlWidget(
                           description,
                          textStyle: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 16),

                        // Bullet Points Section
                        const SizedBox(height: 24),
                       Visibility(
                         visible: widget.isEvent,
                         child: CustomButton(text:isRegisterUser?"Registered":"Registration",
                              onPressed: (){
                                if(sharedPref.getString('user_id') !=null) {
                                  toggleRegister(widget.data.id);

                                } else {
                                  LoginScreen().launch(context, pageRouteAnimation: PageRouteAnimation
                                      .Slide);
                                }

                              },
                          width:400,
                          ),
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
