import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:primax_lyalaty_program/core/utils/comman_data.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';
import 'package:primax_lyalaty_program/widgets/custom_text__form_field.dart';

class AddUpdateProduct extends StatefulWidget {
  final String? id;
  const AddUpdateProduct({super.key, this.id});

  @override
  _AddUpdateProductState createState() => _AddUpdateProductState();
}

class _AddUpdateProductState extends State<AddUpdateProduct> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _wattController = TextEditingController();
    TextEditingController _imageUrlController = TextEditingController();
  List<TextEditingController> _imageControllers = [];

  List<String> _gallery = [];
  List<int> _sizes = [];
  List<dynamic> _rate = [];
  List<dynamic> _favoritedBy = [];
  String? _selectedBrand;
  bool _isUpdating = false;
  bool _isPurchasable = true; // New field for purchase status

  final List<String> brands =[];
  bool isBrandLoading=true;
  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _isUpdating = true;
      _fetchData();
    }
    getBrands();
  }
  getBrands() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('brands').get();

      for (var doc in querySnapshot.docs) {
        brands.add(doc['name'] ?? '');
      }
      _selectedBrand=brands.first;
      isBrandLoading=false;
      setState(() {});
    } catch (e) {
      print("Error fetching brands: $e");

    }
  }
  Future<void> _fetchData() async {
    if (widget.id != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('products').doc(widget.id).get();
      if (doc.exists) {
        setState(() {
          _imageUrlController=TextEditingController(text: doc['image_url']);

          _nameController.text = doc['name'];
          _descriptionController.text = doc['description'];
          _priceController.text = doc['price'].toString();
          _wattController.text = doc['watt'].toString();
          _rate = doc['rate'] as List;
          _favoritedBy = doc['favoritedBy'] as List;
          _imageUrlController.text = doc['image_url'];
          _selectedBrand = doc['brand'];
          _gallery = List<String>.from(doc['gallery'] ?? []);
          _sizes = List<int>.from(doc['size'] ?? []);
          _isPurchasable = doc['is_purchasable'] ?? true; // Fetch purchase status
        });
        _imageControllers = _gallery.map((url) {
          var controller = TextEditingController(text: url);
          print(url);
          return controller;
        }).toList();
      }
    }
  }

  Future<void> _uploadData() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'watt': int.parse(_wattController.text),
        'rate': _rate,
        'favoritedBy': _favoritedBy,
        'image_url': _imageUrlController.text,
        'brand': _selectedBrand,
        'gallery': _gallery,
        'size': _sizes,
        'is_purchasable': _isPurchasable, // Save purchase status
      };

      if (_isUpdating) {
        await FirebaseFirestore.instance.collection('products').doc(widget.id).update(data);
      } else {
        await FirebaseFirestore.instance.collection('products').add(data);
      }

      sendNotificationToAllUsers(
        userId: '',
        title: 'We Have New Products With Offers',
        type: 'product',
        id: widget.id ?? '',
        newPrice: double.parse(_priceController.text),
        oldPrice: 0.0,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isUpdating ? 'Product updated successfully' : 'Product added successfully')),
      );
      Navigator.pop(context);
    }
  }

  void _addGalleryField() {
    setState(() {
      _imageControllers.add(TextEditingController());
    });
  }

  void _removeGalleryField(int index) {
    setState(() {
      _imageControllers.removeAt(index);
    });
  }

  void _addSizeField() {
    setState(() {
      _sizes.add(0);
    });
  }

  void _removeSizeField(int index) {
    setState(() {
      _sizes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isUpdating ? 'Update Product' : 'Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextFormField(
                  controller: _nameController,
                  hintText: 'Product Name',
                  validator: (value) => value!.isEmpty ? 'Name is required' : null,
                ),
                Container(
                  padding: EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:isBrandLoading?Text("Brand Fetching..."):  DropdownButtonFormField<String>(
                    value: _selectedBrand??brands.first,
                    onChanged: (value) {
                      setState(() {
                        _selectedBrand = value;
                      });
                    },
                    items: brands.map((brand) => DropdownMenuItem(value: brand, child: Text(brand))).toList(),
                  ),
                ),
                CustomTextFormField(
                  maxLines: 5,
                  controller: _descriptionController,
                  hintText: 'Description',
                  validator: (value) => value!.isEmpty ? 'Description is required' : null,
                ),
                CustomTextFormField(
                  controller: _wattController,
                  hintText: 'Watt should example 12000(12k)',
                  textInputType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'watt is required' : null,
                ),
                CustomTextFormField(
                  controller: _priceController,
                  hintText: 'Price',
                  textInputType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Price is required' : null,
                ),
                CustomTextFormField(
                  controller: _imageUrlController,
                  hintText: 'Main Image URL',
                  validator: (value) => value!.isEmpty ? 'Main image URL is required' : null,
                ),
                SizedBox(height: 16),

                // Toggle switch for Purchasable status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Purchasable:', style: TextStyle(fontSize: 16)),
                    Switch(
                      value: _isPurchasable,
                      onChanged: (value) {
                        setState(() {
                          _isPurchasable = value;
                        });
                      },
                    ),
                  ],
                ),

                SizedBox(height: 16),
                Text('Gallery Images:'),
              ..._imageControllers.asMap().entries.map((entry) {
            int index = entry.key;
            return Row(
              children: [
                CustomTextFormField(
                  width: MediaQuery.of(context).size.width-80,
                  controller: entry.value,
                  hintText: 'Gallery Image URL ${index + 1}',
                  // decoration: InputDecoration(
                  //     labelText: 'Gallery Image URL ${index + 1}'),
                ),
                IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed: () => _removeGalleryField(index),
                ),
              ],
            );
                      }).toList(),
                // Column(
                //   spacing: 10,
                //   children: _gallery.asMap().entries.map((entry) {
                //     int index = entry.key;
                //     return Row(
                //       children: [
                //         Expanded(
                //           child: CustomTextFormField(
                //             controller: ,
                //             initialValue: entry.value,
                //             hintText: 'Gallery Image URL',
                //             onChanged: (value) => _gallery[index] = value,
                //           ),
                //         ),
                //         IconButton(icon: Icon(Icons.remove_circle), onPressed: () => _removeGalleryField(index)),
                //       ],
                //     );
                //   }).toList(),
                // ),
                ElevatedButton(onPressed: _addGalleryField, child: Text('Add Gallery Image')),

                SizedBox(height: 16),
                // Text('Sizes:'),
                // Column(
                //   children: _sizes.asMap().entries.map((entry) {
                //     int index = entry.key;
                //     return Row(
                //       children: [
                //         Expanded(
                //           child: CustomTextFormField(
                //             initialValue: entry.value.toString(),
                //             hintText: 'Size',
                //             textInputType: TextInputType.number,
                //             onChanged: (value) => _sizes[index] = int.parse(value),
                //           ),
                //         ),
                //         IconButton(icon: Icon(Icons.remove), onPressed: () => _removeSizeField(index)),
                //       ],
                //     );
                //   }).toList(),
                // ),
                // ElevatedButton(onPressed: _addSizeField, child: Text('Add Size')),

                SizedBox(height: 16),
                CustomButton(onPressed: _uploadData, text: _isUpdating ? 'Update' : 'Upload'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
