import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:primax_lyalaty_program/core/utils/comman_widget.dart';
import 'package:primax_lyalaty_program/widgets/comman_back_button.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/comman_data.dart';

class StoreDetailScreen extends StatefulWidget {
  Map<String, dynamic>? stores;
  String? selectedCategory;
  StoreDetailScreen({this.stores, this.selectedCategory, super.key});

  @override
  _StoreDetailScreenState createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  GoogleMapController? mapController;
  LatLng _initialPosition = LatLng(37.7749, -122.4194); // Default SF
  String searchQuery = "";

  // List<Map<String, dynamic>> widget?.stores = [];
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Request location permission and get current location
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permission denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permission permanently denied. Open settings.");
      await openAppSettings();
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });

    final Uint8List markerIcon =
        await getBytesFromAsset('assets/icons/ic_mark_location.png', 350);
    markers.add(
      Marker(
        icon: BitmapDescriptor.fromBytes(markerIcon),
        markerId: MarkerId('My Location'),
        position:
            LatLng(_initialPosition.longitude, _initialPosition.longitude),
        infoWindow: InfoWindow(title: 'My location', snippet: ''),
      ),
    );
    mapController?.animateCamera(
      CameraUpdate.newLatLng(_initialPosition),
    );
    setState(() {});
    _updateMarkers();
    // _fetchStores(); // Fetch widget?.stores when location is available
  }

  // Fetch widget?.stores from Firebase Firestore with filtering
  // Future<void> _fetchStores() async {
  //   Query query = FirebaseFirestore.instance.collection('widget?.stores');
  //
  //   // Apply category filter if selected
  //   if (selectedCategory.isNotEmpty) {
  //     query = query.where('category', isEqualTo: selectedCategory);
  //   }
  //
  //   // Apply text search filter if searchQuery is not empty
  //   if (searchQuery.isNotEmpty) {
  //     query = query
  //         .where('name', isGreaterThanOrEqualTo: searchQuery)
  //         .where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff');
  //   }
  //
  //   try {
  //     QuerySnapshot snapshot = await query.get();
  //
  //     setState(() {
  //       widget.stores = snapshot.docs
  //           .map((doc) => {
  //         'id': doc.id, // Store UID
  //         ...doc.data() as Map<String, dynamic>,
  //       })
  //           .toList();
  //
  //       _updateMarkers(); // Refresh Google Map markers
  //     });
  //   } catch (e) {
  //     print("Error fetching widget?.stores: $e");
  //   }
  // }

  void _updateMarkers() async {
    markers.clear();

    // for (var store in widget?.stores) {
    final double lat = widget.stores?['latitude'];
    final double lng = widget.stores?['longitude'];
    final String name = widget.stores?['name'];
    final String address = widget.stores?['address'];

    final Uint8List markerIcon =
        await getBytesFromAsset('assets/icons/ic_mark_location.png', 350);

    markers.add(
      Marker(
        icon: BitmapDescriptor.fromBytes(markerIcon),
        markerId: MarkerId(name),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: name, snippet: address),
      ),
    );
    mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(lat, lng),
      ),
    );
    // }

    setState(() {}); // Refresh UI
  }

  void _launchMaps(LatLng pickupLocation, LatLng destinationLocation) async {
    String googleMapsUrl =
        "https://www.google.com/maps/dir/?api=1&origin=${pickupLocation!.latitude},${pickupLocation!.longitude}&destination=${destinationLocation!.latitude},${destinationLocation!.longitude}&travelmode=driving";

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch Maps.")),
      );
    }
  }

  // Show bottom sheet with store data
  double calculateDistanceFromLatLng(
      pickupLat, pickupLng, destinationLat, destinationLng) {
    double distanceInMeters = Geolocator.distanceBetween(
      pickupLat,
      pickupLng,
      destinationLat,
      destinationLng,
    );

    return distanceInMeters / 1000; // Convert meters to kilometers
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          Container(
            margin: const EdgeInsets.only(bottom: 500.0),
            child: GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
                if (_initialPosition != LatLng(37.7749, -122.4194)) {
                  controller.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(_initialPosition.latitude , _initialPosition.longitude),
                      14.0,
                    ),
                  );
                }
              },
              liteModeEnabled: true,
              mapType: MapType.normal,
              myLocationButtonEnabled: false,
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.3),
              initialCameraPosition: CameraPosition(
                target: LatLng(_initialPosition.latitude, _initialPosition.longitude),
                zoom: 14.0,
              ),
              markers: markers,
              // myLocationEnabled: true,
            ),
          ),

          // Search Bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              spacing: 10,
              children: [
                CommonBackButton(onPressed: ()=>Navigator.pop(context)),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                    ),
                    child: Row(
                      spacing: 10,
                      children: [
                        if (widget.selectedCategory?.isNotEmpty ?? false)
                          Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: setGradient()),
                              child: Text(
                                widget.selectedCategory ?? '',
                                style: TextStyle(color: Colors.white),
                              )),
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                  
                              // _fetchStores();
                              // _showSearchResults(); // Fetch new results as user types
                            },
                            readOnly: false, // onTap: _showSearchResults,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'search...',
                                icon: Icon(Icons.search_sharp)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips
          // Floating Button for My Location
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: _getCurrentLocation,
              child: Icon(Icons.my_location),
            ),
          ),
          DraggableScrollableSheet(
              initialChildSize: 0.6,
              // Half screen initially
              minChildSize: 0.6,
              // Minimum size (half screen)
              maxChildSize: 1.0,
              // Full screen when expanded
              snap: true,
              snapSizes: const [0.6, 1.0],
              builder: (context, scrollController) {
                var gallery = widget.stores?['gallery'] as List;
                return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      // borderRadius: BorderRadius.only(
                      //   topLeft: Radius.circular(20),
                      //   topRight: Radius.circular(20),
                      // ),
                      // boxShadow: [
                      //   BoxShadow(color: Colors.black12, blurRadius: 10)
                      // ],
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          Center(
                              child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20)),
                            height: 10,
                            width: 100,
                          )),
                          Column(
                            spacing: 5,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: SvgPicture.asset(
                                  'assets/icons/ic_location.svg',
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                              Text(
                                widget.stores?['name'],
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                widget.stores?['address'],
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    spacing: 5,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/ic_clock_fill.svg',
                                        height: 20,
                                        width: 20,
                                      ),
                                      Text(widget.stores?['time'])
                                    ],
                                  ),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Row(
                                    spacing: 5,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/ic_routing.svg',
                                        height: 20,
                                        width: 20,
                                      ),
                                      Text(
                                          '${calculateDistanceFromLatLng(_initialPosition.latitude, _initialPosition.longitude, widget.stores?['latitude'], widget.stores?['longitude']).toStringAsFixed(2)}km'),
                                    ],
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey.shade200,
                              ),
                              if(gallery.isNotEmpty)Row(
                                children: [
                                  Text("Picture"),
                                ],
                              ),
                             if(gallery.isNotEmpty) SizedBox(
                                height: 100,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: gallery.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                          margin: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.grey)),
                                          child: gallery[index] == ''
                                              ? Center(
                                                  child: Text('No image'),
                                                )
                                              : Image.network(
                                                  gallery[index],
                                                ));
                                    }),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: MaterialButton(
                                      onPressed: () {
                                        _launchDialer(
                                            widget.stores?['contact']);
                                      },
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          // gradient: LinearGradient(
                                          //   colors: [
                                          //     startColor ?? const Color(0xFF00C853), // Default green
                                          //     endColor ?? const Color(0xFF00B0FF), // Default blue
                                          //   ],
                                          // ),
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Contact',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: CustomButton(
                                        height: 40,
                                        text: 'Direction',
                                        onPressed: () {
                                          _launchMaps(
                                              _initialPosition,
                                              LatLng(widget.stores?['latitude'],
                                                  widget.stores?['longitude']));
                                        }),
                                  )
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ));
              })
        ],
      ),
    );
  }

  void _launchDialer(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
