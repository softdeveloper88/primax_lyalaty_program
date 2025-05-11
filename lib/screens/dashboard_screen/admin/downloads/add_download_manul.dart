import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';
import 'package:primax_lyalaty_program/widgets/custom_text__form_field.dart';

class AddDownloadManul extends StatefulWidget {
  AddDownloadManul({super.key, this.id});
  String? id; // Optional parameter for the document id
  @override
  _AddDownloadManulState createState() => _AddDownloadManulState();
}

class _AddDownloadManulState extends State<AddDownloadManul> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _fileUrlController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _wattController = TextEditingController();

  bool _isUploading = false;

  String? _selectedBrand;
  String? _selectedCategory;

  final List<String> brands = []; // Example brands
  final List<String> categories = ['Product User Manuals', 'Product Datasheets']; // Example categories

  // This is used for checking if the user is updating or adding new data
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _isUpdating = true;
      _fetchData();
    }
    getBrands();
  }
  bool isBrandLoading=true;
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
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('downloads').doc(widget.id).get();

      if (doc.exists) {
        // Populate the form with the current values from Firestore
        setState(() {
          _fileNameController.text = doc['file_name'];
          _fileUrlController.text = doc['file_url'];
          _imageUrlController.text = doc['image'];
          _selectedBrand = doc['brand'];
          _selectedCategory = doc['category'];
          _wattController.text = doc['watt'].toString();
        });
      }
    }
  }

  Future<void> _uploadData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      // Collect data for upload/update
      final data = {
        'brand': _selectedBrand,
        'category': _selectedCategory,
        'file_name': _fileNameController.text,
        'file_url': _fileUrlController.text,
        'image': _imageUrlController.text,
        'watt': int.parse(_wattController.text),
      };

      if (_isUpdating) {
        // Update the existing document in Firestore
        await FirebaseFirestore.instance.collection('downloads').doc(widget.id).update(data);
      } else {
        // Add new document to Firestore
        await FirebaseFirestore.instance.collection('downloads').add(data);
      }

      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isUpdating ? 'Data updated successfully' : 'Data uploaded successfully')));
      Navigator.pop(context); // Optionally pop to the previous screen after submitting
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isUpdating ? 'Update Data' : 'Upload Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
          padding: EdgeInsets.only(left: 3),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10)),
                child:isBrandLoading?Text("Brand Fetching..."): DropdownButtonFormField<String>(
                  value: _selectedBrand,
                  hint: Text( 'Brand'),
                  onChanged: (value) {
                    setState(() {
                      _selectedBrand = value;
                    });
                  },
                  items: brands.map((brand) {
                    return DropdownMenuItem<String>(
                      value: brand,
                      child: Text(brand),
                    );
                  }).toList(),
                  validator: (value) => value == null ? 'Brand is required' : null,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.only(left: 3),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),

                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint:  Text('Category'),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  validator: (value) => value == null ? 'Category is required' : null,
                ),
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                controller: _fileNameController,
                hintText:  'File Name',
                validator: (value) => value!.isEmpty ? 'File name is required' : null,
              ),
              SizedBox(height: 16),

              CustomTextFormField(
                controller: _fileUrlController,
                hintText:  'File URL',
                validator: (value) => value!.isEmpty ? 'File URL is required' : null,
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                controller: _imageUrlController,
                hintText:  'Image URL',
                validator: (value) => value!.isEmpty ? 'Image URL is required' : null,
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                controller: _wattController,
                hintText: 'Watt should example 12000(12k)',
                textInputType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'watt is required' : null,
              ),
              SizedBox(height: 16),
              _isUploading ? Center(child: CircularProgressIndicator()):CustomButton(
                onPressed: (){_isUploading ? null : _uploadData();},
                text:_isUpdating ? 'Update' : 'Upload',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
