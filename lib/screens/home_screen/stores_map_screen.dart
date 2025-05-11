import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:primax_lyalaty_program/core/utils/comman_widget.dart';
import 'package:primax_lyalaty_program/screens/home_screen/store_detaile_screen.dart';
import 'dart:ui' as ui;

import '../../core/utils/comman_data.dart';
class StoresMapScreen extends StatefulWidget {
  @override
  _StoresMapScreenState createState() => _StoresMapScreenState();
}

class _StoresMapScreenState extends State<StoresMapScreen> {
  GoogleMapController? mapController;
  LatLng _initialPosition = LatLng(37.7749, -122.4194); // Default SF
  String selectedCategory = "";
  String searchQuery = "";
  List<Map<String, dynamic>> stores = [];
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _fetchStores(); // Fetch stores when location is available
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

    // BitmapDescriptor markMyIcon = await _createCustomMarkerIcon();
    final Uint8List markerIcon = await getBytesFromAsset('assets/icons/ic_mark_location.png',350);

    markers.add(
      Marker(
        icon:  BitmapDescriptor.fromBytes(markerIcon),
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
    _fetchStores(); // Fetch stores when location is available

  }

  // Fetch stores from Firebase Firestore with filtering
  Future<void> _fetchStores() async {
    Query query = FirebaseFirestore.instance.collection('stores');

    // Apply category filter if selected
    if (selectedCategory.isNotEmpty) {
      query = query.where('category', isEqualTo: selectedCategory);
    }

    // Apply text search filter if searchQuery is not empty
    if (searchQuery.isNotEmpty) {
      query = query
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff');
    }

    try {
      QuerySnapshot snapshot = await query.get();

      setState(() {
        stores = snapshot.docs
            .map((doc) => {
                  'id': doc.id, // Store UID
                  ...doc.data() as Map<String, dynamic>,
                })
            .toList();

        _updateMarkers(); // Refresh Google Map markers
      });
    } catch (e) {
      print("Error fetching stores: $e");
    }
  }
    void _updateMarkers() async {
    markers.clear();

    for (var store in stores) {
      final double lat = store['latitude'];
      final double lng = store['longitude'];
      final String name = store['name'];
      final String address = store['address'];

      // var markIcon = await BitmapDescriptor.fromAssetImage(
      //     ImageConfiguration(devicePixelRatio: 2.5, size: Size(10.0, 10.0)),
      //     'assets/icons/ic_mark_location.png');
      final Uint8List markerIcon = await getBytesFromAsset('assets/icons/ic_mark_location.png',350);
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
    }

    setState(() {}); // Refresh UI
  }

  // Show bottom sheet with store data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
          scrollGesturesEnabled:true,
            onMapCreated: (controller) {
              mapController = controller;
              // Move camera if initial position isn't default
              if (_initialPosition != LatLng(37.7749, -122.4194)) {
                controller.animateCamera(
                  CameraUpdate.newLatLng(_initialPosition),
                );
              }
            },

            zoomGesturesEnabled: true,
            mapType: MapType.normal,
            myLocationButtonEnabled: false,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),

            markers: markers,
            liteModeEnabled: false,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
          ),
          // Search Bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
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
                  if (selectedCategory.isNotEmpty)
                    Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: setGradient()),
                        child: Text(
                          selectedCategory,
                          style: TextStyle(color: Colors.white),
                        )),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });

                        _fetchStores();
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
          // Filter Chips
          Positioned(
            top: 120,
            left: 20,
            right: 20,
            child: Column(
              spacing: 10,
              children: [
                Row(
                  spacing: 30,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildCategoryChip("Official Outlet")),
                    Expanded(child: _buildCategoryChip("Care Centers")),
                  ],
                ),
                Row(
                  spacing: 30,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildCategoryChip("Installers")),
                    Expanded(child: _buildCategoryChip("Flagship Stores")),
                  ],
                ),
              ],
            ),
          ),
          // Floating Button for My Location
          Positioned(
            bottom: 80,
            right: 20,
            child:GestureDetector(
            onTap:_getCurrentLocation,
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                  gradient: setGradient()
                ),
                child:Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (stores.isNotEmpty)
            DraggableScrollableSheet(
                initialChildSize: 0.4,
                // Half screen initially
                minChildSize: 0.4,
                // Minimum size (half screen)
                maxChildSize: 1.0,
                // Full screen when expanded
                snap: true,
                snapSizes: const [0.4, 1.0],
                builder: (context, scrollController) {
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
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: stores.length,
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    ListTile(
                                      leading: SvgPicture.asset(
                                          'assets/icons/ic_location.svg'),
                                      title: Text(
                                        stores[index]['name'],
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            stores[index]['address'],
                                            style:
                                                TextStyle(color: Colors.grey),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                              '${calculateDistanceFromLatLng(_initialPosition.latitude, _initialPosition.longitude, stores[index]['latitude'], stores[index]['longitude']).toStringAsFixed(2)}km',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                      trailing: Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.3),
                                                  blurRadius: 6,
                                                ),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(40)),
                                          child: SvgPicture.asset(
                                            'assets/icons/ic_route.svg',
                                            height: 20,
                                            width: 20,
                                          )),
                                      onTap: () {
                                        // Move camera to selected store
                                        StoreDetailScreen(
                                                stores: stores[index],
                                                selectedCategory:
                                                    selectedCategory)
                                            .launch(context,
                                                pageRouteAnimation:
                                                    PageRouteAnimation.Slide);
                                        mapController?.animateCamera(
                                          CameraUpdate.newLatLng(
                                            LatLng(stores[index]['latitude'],
                                                stores[index]['longitude']),
                                          ),
                                        );
                                        setState(() {});
                                        // Navigator.pop(context); // Close bottom sheet
                                      },
                                    ),
                                    Divider(
                                      color: Colors.grey.shade200,
                                    )
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ));
                })
        ],
      ),
    );
  }

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

  // Category Chip Widget
  Widget _buildCategoryChip(String label) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.transparent,
          ),
          gradient: selectedCategory != label ? setGradient() : null,
          color: Colors.white,
          borderRadius: BorderRadius.circular(30)),
      child: selectedCategory
      == label
          ?
      ShaderMask(
          shaderCallback: (Rect bounds) {
            return setGradient().createShader(bounds);
          },child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                   border: Border.all(
                     color: Colors.white, // This will be replaced by the gradient
                     width: 2,
                   ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  spacing: 5,
                  children: [
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ))
          : Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: selectedCategory
                != label ? setGradient() : null,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                spacing: 5,
                children: [
                  Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                        // gradient: selectedCategory != label?setGradient():null,
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
    ).onTap(() {
      setState(() {
        selectedCategory = label;
        searchQuery = "";
      });
      _fetchStores();
    });
  }
}
