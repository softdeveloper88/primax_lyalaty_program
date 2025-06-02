import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/screens/dashboard_screen/admin/events/add_news_event.dart';
import 'package:primax_lyalaty_program/widgets/media_viewer_widget.dart';
import '../../../core/utils/comman_data.dart';
import '../../../core/utils/comman_widget.dart';
import 'events/event_registered_users_screen.dart';
import '../../news_event_details_screen/news_event_details_screen.dart';
import '../../home_screen/widget/searchbar_widget.dart';
import '../../home_screen/web_view_screen.dart';

class AdminNewsEventScreen extends StatefulWidget {
  const AdminNewsEventScreen({super.key});

  @override
  State<AdminNewsEventScreen> createState() => _AdminNewsEventScreenState();
}

class _AdminNewsEventScreenState extends State<AdminNewsEventScreen> {
  int selectedIndex = 0;
  String selectedCategory = "";
  Timer? _debounce;
  String query = '';

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
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedIndex == 0 ? 'News' : 'Events'),
        actions: [
          IconButton(
            onPressed: () {
              AddNewsEvent(isEvent: selectedIndex == 1).launch(context);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/img_splash.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                SearchBarWidget(updateSearch),
                const SizedBox(height: 20),
                AdminNewsEventsTabs(
                  callback: (i) {
                    setState(() {
                      selectedIndex = i;
                    });
                  },
                  onCategorySelected: (category) {
                    setState(() {
                      if (selectedIndex == 0) {
                        selectedCategory = category;
                      } else {
                        selectedCategory = '';
                      }
                    });
                  },
                ),
                Expanded(child: _buildNewsEventsList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsEventsList() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection(selectedIndex == 0 ? 'news' : 'events')
          .get(),
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
          itemBuilder: (context, index) {
            return AdminNewsCard(
              selectedIndex,
              data[index],
              onRefresh: () {
                setState(() {});
              },
            );
          },
        );
      },
    );
  }
}

class AdminNewsCard extends StatefulWidget {
  final int selectedIndex;
  final DocumentSnapshot data;
  final VoidCallback? onRefresh; // Add refresh callback

  const AdminNewsCard(this.selectedIndex, this.data,
      {super.key, this.onRefresh});

  @override
  State<StatefulWidget> createState() => _AdminNewsCardState();
}

class _AdminNewsCardState extends State<AdminNewsCard> {
  int _currentIndex = 0;

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
      displayText = "${description.substring(0, 100)}...";
    }

    return InkWell(
      onTap: () {
        // Check if this is a news item with a URL
        if (widget.selectedIndex == 0 && widget.data['images'] != null && widget.data['images'].toString().isNotEmpty) {
          // Open URL in WebView
          WebViewScreen(
            url: widget.data['images'],
            title: title,
          ).launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
        } else {
          // Normal behavior - open details screen
          NewsEventDetailsScreen(widget.data, widget.selectedIndex == 1)
              .launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 4,
            ),
          ],
        ),
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15)),
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
                  Positioned(
                    bottom: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: imageUrls.asMap().entries.map((entry) {
                        return Container(
                          width: _currentIndex == entry.key ? 20 : 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: _currentIndex == entry.key ? Colors.green : Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
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
                  if (widget.selectedIndex == 1)
                    Container(
                      height: 35,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF1FA3D1).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                SvgPicture.asset('assets/icons/location.svg',
                                    color: Colors.green, width: 16, height: 16),
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
                              children: [
                                SvgPicture.asset('assets/icons/clock.svg',
                                    color: Colors.green, width: 16, height: 16),
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
                  SizedBox(height: 8),
                  if (widget.selectedIndex == 0)
                    Container(
                      height: 35,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey, width: 0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 4),
                          Expanded(child: Text(category, style: TextStyle(color: Colors.green))),
                        ],
                      ),
                    ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          AddNewsEvent(isEvent: widget.selectedIndex == 1, id: widget.data.id).launch(context);
                        },
                        icon: Icon(LucideIcons.edit),
                      ),
                      IconButton(
                        onPressed: () async {
                          // Show confirmation dialog
                          bool? shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm Delete'),
                                content: Text(
                                    'Are you sure you want to delete this ${widget
                                        .selectedIndex == 0
                                        ? 'news'
                                        : 'event'}?'),
                                actions: [
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  TextButton(
                                    child: Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                  ),
                                ],
                              );
                            },
                          );

                          if (shouldDelete == true) {
                            await FirebaseFirestore.instance
                                .collection(
                                widget.selectedIndex == 0 ? 'news' : 'events')
                                .doc(widget.data.id)
                                .delete();

                            // Call refresh callback to update parent
                            widget.onRefresh?.call();
                          }
                        },
                        icon: Icon(Icons.delete, color: Colors.red),
                      ),
                      if (widget.selectedIndex == 1)
                        TextButton(
                          onPressed: () {
                            EventRegisteredUsersScreen(eventId: widget.data.id)
                                .launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                          },
                          child: Text(
                            "View Registered Users",
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                          ),
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

class AdminNewsEventsTabs extends StatefulWidget {
  final Function(int)? callback;
  final Function(String)? onCategorySelected;

  const AdminNewsEventsTabs({this.callback, this.onCategorySelected, Key? key})
      : super(key: key);

  @override
  _AdminNewsEventsTabsState createState() => _AdminNewsEventsTabsState();
}

class _AdminNewsEventsTabsState extends State<AdminNewsEventsTabs> {
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
              selectedCategory = "";
            });

            widget.callback?.call(index);

            if (index == 1) {
              widget.onCategorySelected?.call("");
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
