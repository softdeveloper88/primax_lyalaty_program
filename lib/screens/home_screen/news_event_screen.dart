import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/screens/login_screen/login_screen.dart';
import 'package:primax_lyalaty_program/widgets/media_viewer_widget.dart';
import '../../core/utils/comman_data.dart';
import '../../main.dart';
import '../../widgets/custom_button.dart';
import '../../core/utils/comman_widget.dart';
import '../news_event_details_screen/news_event_details_screen.dart';
import 'widget/header_widget.dart';
import 'widget/searchbar_widget.dart';
import 'web_view_screen.dart';

class NewsEventScreen extends StatefulWidget {
  const NewsEventScreen({super.key});
  
  @override
  State<NewsEventScreen> createState() => _NewsEventScreenState();
}

class _NewsEventScreenState extends State<NewsEventScreen> with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  String selectedCategory = "";
  Timer? _debounce;
  String query = '';
  final ScrollController _scrollController = ScrollController();
  bool isCollapsed = false;
  bool _isUpdating = false;
  
  // Store futures to prevent rebuilding
  late Future<QuerySnapshot> _newsFuture;
  late Future<QuerySnapshot> _eventsFuture;

  // Use AnimationController for smoother transitions
  late AnimationController _animationController;
  late Animation<double> _animation;

  void updateSearch(String search) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          query = search.toLowerCase();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    
    // Initialize futures
    _loadData();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );

    // Remove animation listener to prevent constant rebuilds
  }
  
  void _loadData() {
    _newsFuture = FirebaseFirestore.instance.collection('news').get();
    _eventsFuture = FirebaseFirestore.instance.collection('events').get();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    // Avoid multiple updates during scroll
    if (_isUpdating) return;
    
    // Use a threshold value to prevent frequent toggling
    final double threshold = 15.0;
    
    if (_scrollController.offset > threshold && !isCollapsed) {
      _isUpdating = true;
      // Don't use setState inside scroll event - it causes jank
      // Instead, only animate and update the collapsed state
      isCollapsed = true;
      _animationController.forward().then((_) {
        _isUpdating = false;
      });
    } else if (_scrollController.offset <= threshold/2 && isCollapsed) {
      _isUpdating = true;
      isCollapsed = false;
      _animationController.reverse().then((_) {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    // Header related dimensions
    final headerExpandedHeight = 160.0;
    final headerCollapsedHeight = 60.0;
    final searchBarHeight = 50.0;

    // Dynamic top padding will be calculated in AnimatedBuilder

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/img_splash.png',
              fit: BoxFit.cover,
            ),
          ),

          // Header with animation
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final double animatedHeaderHeight = headerExpandedHeight - 
                    (_animation.value * (headerExpandedHeight - headerCollapsedHeight));
                return Container(
                  height: animatedHeaderHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    gradient: setGradient(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 60 - (_animation.value * 50)),
                        Opacity(
                          opacity: 1.0 - _animation.value,
                          child: isCollapsed ? SizedBox() : const HeaderWidget(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Search bar with animation
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                top: headerExpandedHeight - searchBarHeight / 2 - 
                    (_animation.value * (headerExpandedHeight - headerCollapsedHeight - 10)),
                left: 16,
                right: 16,
                child: child!,
              );
            },
            child: SearchBarWidget(updateSearch),
          ),

          // Main content with unified scrolling
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final contentTopPadding = headerExpandedHeight + searchBarHeight / 2 + 10 -
                  (_animation.value * (headerExpandedHeight - headerCollapsedHeight));
              return Positioned(
                top: contentTopPadding,
                left: 0,
                right: 0,
                bottom: 0,
                child: child!,
              );
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(), // Better for preventing over-scroll refreshes
              slivers: [
                // Tabs section
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: NewsEventsTabs(
                      callback: (i) {
                        if (selectedIndex != i) {
                          setState(() {
                            selectedIndex = i;
                            // Reload data when tab changes
                            _loadData();
                          });
                        }
                      },
                      onCategorySelected: (category) {
                        setState(() {
                          if(selectedIndex==0) {
                            selectedCategory = category;
                            // Reload data when category changes
                            _loadData();
                          } else {
                            selectedCategory='';
                          }
                        });
                      },
                    ),
                  ),
                ),

                // News/Events List
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                  sliver: SliverToBoxAdapter(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        // Block scroll updates during animation
                        return _isUpdating;
                      },
                      child: _buildNewsEventsList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildNewsEventsList() {
    return FutureBuilder<QuerySnapshot>(
      future: selectedIndex == 0 ? _newsFuture : _eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No data available"));
        }

        List<DocumentSnapshot> data = snapshot.data!.docs;

        if (selectedCategory.isNotEmpty) {
          data = data.where((doc) {
            return doc['category'] == selectedCategory;
          }).toList();
        }

        if (query.isNotEmpty) {
          data = data.where((doc) {
            String title = doc['title'].toString().toLowerCase();
            return title.contains(query);
          }).toList();
        }

        if (data.isEmpty) {
          return Center(child: Text("No matching items found"));
        }

        return ListView.builder(
          itemCount: data.length,
          padding: EdgeInsets.only(top: 8),
          physics: NeverScrollableScrollPhysics(), // Important for nested scrolling
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return NewsCard(
              selectedIndex,
              data[index],
            );
          },
        );
      },
    );
  }
}

// The rest of the class implementations remain the same
class NewsCard extends StatefulWidget {
  final int selectedIndex;
  final DocumentSnapshot data;

  const NewsCard(this.selectedIndex, this.data, {super.key});

  @override
  State<StatefulWidget> createState() =>_NewsCardState();

}
class _NewsCardState extends State<NewsCard> {
  int _currentIndex = 0;

  Future<bool> isRegister(String eventId) async {
    DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance.collection('events').doc(eventId).get();

    List<String> registerUser = List<String>.from(eventSnapshot['register_users'] ?? []);
    return registerUser.contains(sharedPref.getString('user_id') ?? '');
  }
  bool isRegisterUser=false;
  void checkRegistration() async {
    isRegisterUser = await isRegister(widget.data.id??'');
    if(mounted) {
      setState(() {});
    }
  }
  @override
  void initState() {
    if(widget.selectedIndex==1) {
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
    String location = widget.data['location'] ?? "No Location";
    String time = widget.data['time'] ?? "No Time";
    String displayText = description;
    bool isLongText = description.length > 100;

    if (isLongText) {
      displayText = "${description.substring(0, 100)}..."; // Truncate
    }
    return InkWell(
      onTap: (){
        // // Check if this is a news item with a URL
        // if (widget.selectedIndex == 0 && widget.data['images'] != null && widget.data['images'].toString().isNotEmpty) {
        //   // Open URL in WebView
        //   WebViewScreen(
        //     url: widget.data['images'],
        //     title: title,
        //   ).launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
        // } else {
          // Normal behavior - open details screen
          NewsEventDetailsScreen(widget.data,widget.selectedIndex==1).launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
        // }
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
                      return MediaViewerWidget(
                        mediaUrl: imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 180,
                      autoPlay: false,
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
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: HtmlWidget(
                          displayText,
                          textStyle: TextStyle(color: Colors.black54),
                        ),
                      ),
                      if (widget.selectedIndex == 0 && widget.data['images'] != null && widget.data['images'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.open_in_new,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if(widget.selectedIndex==1) Container(
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
                        Expanded(
                          child: Row(
                            children:  [
                              SvgPicture.asset('assets/icons/location.svg', color: Colors.green, width: 16, height: 16),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children:  [
                              SvgPicture.asset('assets/icons/clock.svg', color: Colors.green, width: 16, height: 16),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  time,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if(widget.selectedIndex==1) Expanded(
                          child: Container(
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
                                // SvgPicture.asset('assets/icons/clock.svg', color: Colors.green),
                                SizedBox(width: 4),
                                Expanded(child: Text(category,style:TextStyle(color: Colors.green))),
                              ],
                            ),
                          ),
                        ),
                        if(widget.selectedIndex==1)  Expanded(
                          child: CustomButton(
                            height: 35,
                            onPressed: () {
                              if(widget.selectedIndex==1){
                                if(sharedPref.getString('user_id') !=null) {
                                  toggleRegister(widget.data.id);

                                } else {
                                  LoginScreen().launch(context, pageRouteAnimation: PageRouteAnimation
                                      .Slide);
                                }
                              }
                            },
                            text: widget.selectedIndex==0?"Checkout":isRegisterUser?"Registered":"Registration",
                          ),
                        ),
                      ],
                    ),
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

class NewsEventsTabs extends StatefulWidget {
  final Function(int)? callback;
  final Function(String)? onCategorySelected;

  const NewsEventsTabs({this.callback, this.onCategorySelected, Key? key})
      : super(key: key);

  @override
  _NewsEventsTabsState createState() => _NewsEventsTabsState();
}

class _NewsEventsTabsState extends State<NewsEventsTabs> {
  int selectedIndex = 0;
  String selectedCategory = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 6),
            ],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              _tabButton("News", 0),
              const SizedBox(width: 8),
              _tabButton("Events", 1),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Show categories only when "News" tab is selected
        if (selectedIndex == 0) _buildCategoryTabs(),
      ],
    );
  }

  Widget _tabButton(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (selectedIndex != index) {
            setState(() {
              selectedIndex = index;
              selectedCategory = ""; // Reset category when switching tabs
            });

            widget.callback?.call(index); // Ensure tab change is notified

            if (index == 1) {
              widget.onCategorySelected?.call(""); // Trigger data reload for Events
            }
          }
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

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 10,
        children: [
          _categoryChip("Primax News"),
          _categoryChip("Market News"),
          _categoryChip("Activities"),
        ],
      ),
    );
  }

  Widget _categoryChip(String category) {
    return ChoiceChip(
      label: Text(category),
      selected: selectedCategory == category,
      showCheckmark: false,
      onSelected: (selected) {
        // Always call the callback even when deselecting (selected becomes false)
        final String newCategory = selected ? category : "";
        if (selectedCategory != newCategory) {
          setState(() {
            selectedCategory = newCategory;
          });
          widget.onCategorySelected?.call(selectedCategory);
        }
      },
      selectedColor: Colors.blue.withOpacity(0.3),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selectedCategory == category ? Colors.green : Colors.grey.shade300,
        ),
      ),
    );
  }
}

class FilterChipWidget extends StatefulWidget {
  final String label;
  final Function(bool)? onSelected;
  final bool selected;

  const FilterChipWidget({
    Key? key,
    required this.label,
    this.onSelected,
    this.selected = false,
  }) : super(key: key);

  @override
  _FilterChipWidgetState createState() => _FilterChipWidgetState();
}

class _FilterChipWidgetState extends State<FilterChipWidget> {
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    isSelected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(widget.label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (selected) {
        setState(() {
          isSelected = selected;
        });
        if (widget.onSelected != null) {
          widget.onSelected!(selected);
        }
      },
      selectedColor: Colors.blue.withOpacity(0.3),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? Colors.green : Colors.grey.shade300,
        ),
      ),
    );
  }
}
