import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';



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
      query = query.where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff');
    }

    try {
      QuerySnapshot snapshot = await query.get();

      setState(() {
        stores = snapshot.docs.map((doc) => {
          'id': doc.id, // Store UID
          ...doc.data() as Map<String, dynamic>,
        }).toList();

        _updateMarkers(); // Refresh Google Map markers
      });
    } catch (e) {
      print("Error fetching stores: $e");
    }
  }


  // Update map markers dynamically
  void _updateMarkers() {
    markers.clear();

    for (var store in stores) {
      final double lat = store['lat'] as double;
      final double lng = store['lng']  as double;
      final String name = store['name'];

      markers.add(
        Marker(
          markerId: MarkerId(name),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: name, snippet: store['address']),
        ),
      );
    }

    setState(() {}); // Refresh UI
  }

  // Show bottom sheet with store data
  void _showSearchResults() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows full-screen modal
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Search Results:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(
                decoration: InputDecoration(
                  hintText: "Search stores...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                  _fetchStores(); // Fetch new results as user types
                },
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.store),
                      title: Text(stores[index]['name']),
                      subtitle: Text(stores[index]['address']),
                      onTap: () {
                        // Move camera to selected store
                        mapController?.animateCamera(
                          CameraUpdate.newLatLng(
                            LatLng(stores[index]['lat'], stores[index]['lng']),
                          ),
                        );
                        Navigator.pop(context); // Close bottom sheet
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: (controller) => mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            markers: markers,
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
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: TextField(
                readOnly: true,
                onTap: _showSearchResults,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: selectedCategory.isEmpty ? "Search....." : selectedCategory,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),

          // Filter Chips
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategoryChip("Official Outlet"),
                _buildCategoryChip("Installers"),
                _buildCategoryChip("Flagship Stores"),
              ],
            ),
          ),

          // Floating Button for My Location
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.green,
              child: Icon(Icons.my_location),
              onPressed: _getCurrentLocation,
            ),
          ),

        ],
      ),
    );
  }

  // Category Chip Widget
  Widget _buildCategoryChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedCategory == label,
      onSelected: (bool selected) {
        setState(() {
          selectedCategory = selected ? label : "";
          searchQuery = "";
        });
        _fetchStores();
      },
      selectedColor: Colors.blue.shade100,
    );
  }
}

