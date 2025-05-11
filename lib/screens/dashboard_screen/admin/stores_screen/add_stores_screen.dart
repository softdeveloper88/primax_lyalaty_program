import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:primax_lyalaty_program/widgets/custom_text__form_field.dart';

import 'custom_place_picker.dart';

class AddStoresScreen extends StatefulWidget {
  final String? storeId;

  AddStoresScreen({super.key, this.storeId});

  @override
  _AddStoresScreenState createState() => _AddStoresScreenState();
}

class _AddStoresScreenState extends State<AddStoresScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _openTimeController = TextEditingController();
  final TextEditingController _closeTimeController = TextEditingController();
  List<TextEditingController> _imageControllers = [];

  List<String> _gallery = [];
  LatLng _selectedLocation = LatLng(37.7749, -122.4194);
  bool _isUpdating = false;
  bool _isUploading = false;
  GoogleMapController? _mapController;
  LatLng _initialPosition = LatLng(37.7749, -122.4194); // Default SF
  Set<Marker> markers = {};

  final List<String> _categories = [
    'Official Outlet',
    'Care Centers',
    'Installers',
    'Flagship Stores'
  ];
  String? _selectedCategory;
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
    var markMyIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/icons/ic_mark_pin.png');
    markers.add(
      Marker(
        icon: markMyIcon,
        markerId: MarkerId('My Location'),
        position:
        LatLng(_initialPosition.longitude, _initialPosition.longitude),
        infoWindow: InfoWindow(title: 'My location', snippet: ''),
      ),
    );
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(_initialPosition),
    );
    setState(() {});

    // _fetchStores(); // Fetch widget?.stores when location is available
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    if (widget.storeId != null) {
      _isUpdating = true;
      _fetchStoreData();
    }
  }

  Future<void> _fetchStoreData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('stores')
        .doc(widget.storeId)
        .get();
    if (doc.exists) {
      setState(() {
        _nameController.text = doc['name'];
        _addressController.text = doc['address'];
        _contactController.text = doc['contact'];
        _openTimeController.text = doc['time'].split(' - ')[0];
        _closeTimeController.text = doc['time'].split(' - ')[1];
        _gallery = List<String>.from(doc['gallery']);
        _selectedLocation = LatLng(doc['latitude'], doc['longitude']);
        _latitudeController.text = doc['latitude'].toString();
        _longitudeController.text = doc['longitude'].toString();
        _selectedCategory = doc['category'];
        _imageControllers = _gallery.map((url) {
          var controller = TextEditingController(text: url);
          return controller;
        }).toList();
        // if (_imageControllers.isEmpty) {
        //   _imageControllers.add(TextEditingController());
        // }
      });
    }
  }

  Future<void> _uploadData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);

      final data = {
        'name': _nameController.text,
        'address': _addressController.text,
        'contact': _contactController.text,
        'latitude': double.tryParse(_latitudeController.text) ??
            _selectedLocation.latitude,
        'longitude': double.tryParse(_longitudeController.text) ??
            _selectedLocation.longitude,
        'time': "${_openTimeController.text} - ${_closeTimeController.text}",
        'category': _selectedCategory,
        'gallery': _gallery,
      };

      if (_isUpdating) {
        await FirebaseFirestore.instance
            .collection('stores')
            .doc(widget.storeId)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection('stores').add(data);
      }

      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isUpdating ? 'Store updated' : 'Store added')));
      Navigator.pop(context);
    }
  }

  void _selectTime(TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      String formattedTime = DateFormat.jm().format(
        DateTime(2022, 1, 1, picked.hour, picked.minute),
      );
      setState(() => controller.text = formattedTime);
    }
  }

  void _updateLocation(LatLng newLocation) async {
    setState(() {
      _selectedLocation = newLocation;
      _latitudeController.text = newLocation.latitude.toString();
      _longitudeController.text = newLocation.longitude.toString();
    });
    List<Placemark> placemarks = await placemarkFromCoordinates(
        newLocation.latitude, newLocation.longitude);
    setState(() {
      _addressController.text = placemarks.first.street ?? "";
    });
  }

  void _addImageField() {
    setState(() {
      _imageControllers.add(TextEditingController());
    });
  }

  void _removeImageField(int index) {
    setState(() {
      _imageControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(_isUpdating ? 'Update Store' : 'Add Store')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 10,
              children: [
                // SizedBox(
                //   height: 300,
                //   child: GoogleMap(
                //     scrollGesturesEnabled:true,
                //     myLocationButtonEnabled: true,
                //     mapType: MapType.normal,
                //     mapToolbarEnabled: true,
                //     initialCameraPosition:
                //         CameraPosition(target: _selectedLocation, zoom: 14),
                //     markers: {
                //       Marker(
                //         markerId: MarkerId('storeLocation'),
                //         position: _selectedLocation,
                //         draggable: true,
                //         onDragEnd: _updateLocation,
                //       ),
                //     },
                //     onMapCreated: (controller) => _mapController = controller,
                //     onTap: _updateLocation,
                //   ),
                // ),
                CustomTextFormField(
                  controller: _nameController,
                  hintText: 'Store Name',
                  // decoration: InputDecoration(labelText: 'Store Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Store Name is required' : null,
                ),
                CustomTextFormField(
                  controller: _addressController,
                  hintText: 'Address',
                  suffix: IconButton(
                      onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CustomPlacePicker()),
                          );

                          if (result != null) {
                            print("Selected Location: ${result['lat']}, ${result['lng']}");
                            print("Address: ${result['address']}");
                            _addressController.text=result['address'];
                            _latitudeController.text=result['lat'].toString();
                            _longitudeController.text=result['lng'].toString();
                          }

                      },
                      icon: Icon(Icons.map)),
                  // decoration: InputDecoration(labelText: 'Address'),
                  validator: (value) =>
                      value!.isEmpty ? 'Address is required' : null,
                ),
                CustomTextFormField(
                  controller: _contactController,
                  hintText: 'Contact Number',
                  // decoration: InputDecoration(labelText: 'Contact Number'),
                  validator: (value) =>
                      value!.isEmpty ? 'Contact Number is required' : null,
                ),
                CustomTextFormField(
                  controller: _latitudeController,
                  hintText: 'Latitude',
                  // decoration: InputDecoration(labelText: 'Latitude'),
                  validator: (value) =>
                      value!.isEmpty ? 'Latitude is required' : null,
                ),
                CustomTextFormField(
                  controller: _longitudeController,
                  hintText: 'Longitude',
                  // decoration: InputDecoration(labelText: 'Longitude'),
                  validator: (value) =>
                      value!.isEmpty ? 'Longitude is required' : null,
                ),
                Container(
                  padding: EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,

                    decoration: InputDecoration(labelText: 'Category',),
                    onChanged: (value) => setState(() => _selectedCategory = value),
                    items: _categories
                        .map((category) => DropdownMenuItem(
                            value: category, child: Text(category)))
                        .toList(),
                  ),
                ),
                CustomTextFormField(
                  controller: _openTimeController,
                  hintText: 'Opening Time',
                  // decoration: InputDecoration(labelText: 'Opening Time'),
                  isReadOnly: true,
                  onTap: () => _selectTime(_openTimeController),
                  validator: (value) =>
                      value!.isEmpty ? 'Opening time is required' : null,
                ),
                CustomTextFormField(
                  controller: _closeTimeController,
                  hintText: 'Closing Time',
                  // decoration: InputDecoration(labelText: 'Closing Time'),
                  isReadOnly: true,
                  onTap: () => _selectTime(_closeTimeController),
                  validator: (value) =>
                      value!.isEmpty ? 'Closing time is required' : null,
                ),
                ..._imageControllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  return Row(
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          controller: entry.value,
                          hintText: 'Gallery Image URL ${index + 1}',
                          // decoration: InputDecoration(
                          //     labelText: 'Gallery Image URL ${index + 1}'),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: () => _removeImageField(index),
                      ),
                    ],
                  );
                }).toList(),
                ElevatedButton(
                    onPressed: _addImageField, child: Text('Add Gallery Image')),
                SizedBox(height: 16),
                ElevatedButton(
                    onPressed: _isUploading ? null : _uploadData,
                    child: _isUploading
                        ? CircularProgressIndicator()
                        : Text(_isUpdating ? 'Update' : 'Add')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
