import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class CustomPlacePicker extends StatefulWidget {
  @override
  _CustomPlacePickerState createState() => _CustomPlacePickerState();
}

class _CustomPlacePickerState extends State<CustomPlacePicker> {
  GoogleMapController? _mapController;
  LatLng _selectedLocation = LatLng(37.7749, -122.4194); // Default: San Francisco
  String _selectedAddress = "Move marker to select location";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  /// Get Current Location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(_selectedLocation));
    _getAddressFromLatLng(_selectedLocation);
  }

  /// Reverse Geocoding to Get Address
  Future<void> _getAddressFromLatLng(LatLng position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude);
    setState(() {
      _selectedAddress = '${placemarks.first.street ?? ""},${placemarks.first.subLocality ?? ""},${placemarks.first.locality ?? ""},${placemarks.first.country ?? ""}';
    });
    // final apiKey = "AIzaSyCmfyHmxODNkO16pSnD_HenPwjfpgdm5o4";
    // final url =
    //     "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey";
    //
    // final response = await http.get(Uri.parse(url));
    // if (response.statusCode == 200) {
    //   final data = json.decode(response.body);
    //   if (data['results'].isNotEmpty) {
    //     setState(() {
    //       _selectedAddress = data['results'][0]['formatted_address'];
    //     });
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Location")),
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(target: _selectedLocation, zoom: 14),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            markers: {
              Marker(
                markerId: MarkerId("selected-location"),
                position: _selectedLocation,
                draggable: true,
                onDragEnd: (LatLng newPosition) {
                  setState(() {
                    _selectedLocation = newPosition;
                  });
                  _getAddressFromLatLng(newPosition);
                },
              ),
            },
            onTap: (LatLng position) {
              setState(() {
                _selectedLocation = position;
              });
              _getAddressFromLatLng(position);
            },
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Text(_selectedAddress, textAlign: TextAlign.center),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {"lat": _selectedLocation.latitude, "lng": _selectedLocation.longitude, "address": _selectedAddress});
                  },
                  child: Text("Confirm Location"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
