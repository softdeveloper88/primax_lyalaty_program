import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:primax_lyalaty_program/widgets/custom_text__form_field.dart';
import 'package:primax_lyalaty_program/widgets/custom_text__form_field.dart';

class AddBrandScreen extends StatefulWidget {
  final String? brandId;
  final String? initialName;
  final String? initialImageUrl;

  const AddBrandScreen({Key? key, this.brandId, this.initialName, this.initialImageUrl}) : super(key: key);

  @override
  _AddBrandScreenState createState() => _AddBrandScreenState();
}

class _AddBrandScreenState extends State<AddBrandScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null) {
      nameController.text = widget.initialName!;
    }
    if (widget.initialImageUrl != null) {
      imageUrlController.text = widget.initialImageUrl!;
    }
  }

  Future<void> saveBrand() async {
    if (!_formKey.currentState!.validate()) return;

    Map<String, dynamic> brandData = {
      'name': nameController.text.trim(),
      'imageUrl': imageUrlController.text.trim(),
      'timestamp':DateTime.timestamp(),
    };

    try {
      if (widget.brandId == null) {
        // Add new brand
        await FirebaseFirestore.instance.collection('brands').add(brandData);
      } else {
        // Update existing brand
        await FirebaseFirestore.instance.collection('brands').doc(widget.brandId).update(brandData);
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.brandId == null ? 'Add Brand' : 'Update Brand',)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextFormField(
                controller: nameController,
                hintText:  'Brand Name',
                validator: (value) => value!.isEmpty ? 'Enter brand name' : null,
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                controller: imageUrlController,
               hintText: 'Image URL',
                validator: (value) => value!.isEmpty ? 'Enter image URL' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: saveBrand,
                child: Text(widget.brandId == null ? 'Add Brand' : 'Update Brand'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
