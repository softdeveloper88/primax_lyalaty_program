import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';

import '../main.dart';

class AddNewAddress extends StatefulWidget {
  final String? addressId; // If null, it means adding a new address.

  const AddNewAddress({super.key, this.addressId});

  @override
  _AddNewAddressState createState() => _AddNewAddressState();
}

class _AddNewAddressState extends State<AddNewAddress> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _postCodeController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();

  String selectedLabel = "Home";
  bool isPrimary = false;
  LatLng? _currentLocation;
  GoogleMapController? _mapController;
  Marker? _marker;

  @override
  void initState() {
    super.initState();
    if (widget.addressId != null) {
      _loadExistingAddress();
    } else {
      _determinePosition();
    }
  }

  /// Load existing address data for updating
  Future<void> _loadExistingAddress() async {
    String userId = sharedPref.getString('user_id')??'';
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc(widget.addressId)
        .get();

    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;

      setState(() {
        _addressController.text = data['address'];
        _streetController.text = data['street'];
        _postCodeController.text = data['postCode'];
        _apartmentController.text = data['apartment'];
        selectedLabel = data['title'] ?? "Home";
        isPrimary = data['isPrimary'] ?? false;
        _currentLocation = LatLng(data['latitude'], data['longitude']);
        _marker = Marker(
          markerId: const MarkerId("currentLocation"),
          position: _currentLocation!,
          draggable: true,
          onDragEnd: (newPos) {
            _updateAddressFromCoordinates(newPos);
          },
        );
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentLocation!),
        );
      }
    }
  }

  /// Get the user's current location (optional)
  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _useDefaultLocation();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _useDefaultLocation();
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      LatLng newPosition = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = newPosition;
        _marker = Marker(
          markerId: const MarkerId("currentLocation"),
          position: newPosition,
          draggable: true,
          onDragEnd: (newPos) {
            _updateAddressFromCoordinates(newPos);
          },
        );
      });

      _updateAddressFromCoordinates(newPosition);

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(newPosition),
        );
      }
    } catch (e) {
      print("Error getting location: $e. Using default location.");
      _useDefaultLocation();
    }
  }

  /// Use default location when user location is unavailable
  void _useDefaultLocation() {
    LatLng defaultPosition = LatLng(37.7749, -122.4194); // Default SF location
    
    setState(() {
      _currentLocation = defaultPosition;
      _marker = Marker(
        markerId: const MarkerId("currentLocation"),
        position: defaultPosition,
        draggable: true,
        onDragEnd: (newPos) {
          _updateAddressFromCoordinates(newPos);
        },
      );
    });

    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(defaultPosition),
      );
    }
  }

  /// Reverse geocode the coordinates into an address
  Future<void> _updateAddressFromCoordinates(LatLng position) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address =
            "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";

        setState(() {
          _addressController.text = address;
          _postCodeController.text = place.postalCode ?? '';
          _streetController.text = place.street ?? '';
        });
      }
    } catch (e) {
      print("Error fetching address: $e");
    }
  }

  /// Save or update the address
  void _saveAddress() async {
    if (_addressController.text.isEmpty ||
        _streetController.text.isEmpty ||
        _postCodeController.text.isEmpty ||
        _apartmentController.text.isEmpty ||
        _currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and set location on map")),
      );
      return;
    }

    String userId = sharedPref.getString('user_id')??'';
    CollectionReference addressCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('addresses');

    Map<String, dynamic> addressData = {
      'title': selectedLabel,
      'address': _addressController.text,
      'street': _streetController.text,
      'postCode': _postCodeController.text,
      'apartment': _apartmentController.text,
      'latitude': _currentLocation!.latitude,
      'longitude': _currentLocation!.longitude,
      'isPrimary': isPrimary,
      'createdAt': Timestamp.now(),
    };

    if (widget.addressId == null) {
      // Add new address
      await addressCollection.add(addressData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address saved successfully")),
      );
    } else {
      // Update existing address
      await addressCollection.doc(widget.addressId).update(addressData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address updated successfully")),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 240,
            width: double.infinity,
            child: _currentLocation == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation!,
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              markers: _marker != null ? {_marker!} : {},
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildTextField(
              controller: _addressController,
              label: 'Address',
              hintText: 'Fetching address...',
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _streetController,
                    label: 'Street',
                    hintText: 'Hason Nagar',
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildTextField(
                    controller: _postCodeController,
                    label: 'Post Code',
                    hintText: '34567',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildTextField(
              controller: _apartmentController,
              label: 'Apartment',
              hintText: '345',
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomButton(
              onPressed: _saveAddress,
              text: widget.addressId == null ? "Save Location" : "Update Location",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xffF0F5FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
