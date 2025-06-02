import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';
import 'package:primax_lyalaty_program/widgets/custom_text__form_field.dart';

class AddNewsEvent extends StatefulWidget {
  AddNewsEvent({super.key, this.id, required this.isEvent});

  final String? id;
  final bool isEvent;

  @override
  _AddNewsEventState createState() => _AddNewsEventState();
}

class _AddNewsEventState extends State<AddNewsEvent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _authorImageController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _fromTimeController = TextEditingController();
  final TextEditingController _toTimeController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  bool _isUploading = false;
  bool _isUpdating = false;
  List<TextEditingController> _imageControllers = [];
  List<dynamic> registerUser = [];

  final List<String> _newsCategories = [
    'Primax News',
    'Market News',
    'Activities'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _isUpdating = true;
      _fetchData();
    } else {
      _imageControllers.add(TextEditingController());
    }
  }

  Future<void> _fetchData() async {
    if (widget.id != null) {
      String collection = widget.isEvent ? 'events' : 'news';
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(widget.id)
          .get();

      if (doc.exists) {
        setState(() {
          _authorController.text = doc['author'];
          _authorImageController.text = doc['author_image'];
          _categoryController.text = doc['category'];
          _descriptionController.text = doc['description'];
          _locationController.text = doc['location'];
          _fromTimeController.text = doc['time'].split(' - ')[0];;
          _toTimeController.text = doc['time'].split(' - ')[1];;
          _titleController.text = doc['title'];
          _urlController.text = doc['url'] ?? '';
          registerUser= doc['register_users'] as List;
          List<String> images = List<String>.from(doc['images'] ?? []);
          _imageControllers = images.map((url) {
            var controller = TextEditingController(text: url);
            return controller;
          }).toList();

          if (_imageControllers.isEmpty) {
            _imageControllers.add(TextEditingController());
          }
        });
      }
    }
  }

  Future<void> _uploadData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      List<String> images = _imageControllers
          .map((controller) => controller.text)
          .where((url) => url.isNotEmpty)
          .toList();
      final data = {
        'author': _authorController.text,
        'author_image': _authorImageController.text,
        'category': _categoryController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'register_users': registerUser,
        'time': '${_fromTimeController.text} - ${_toTimeController.text}',
        'title': _titleController.text,
        'url': _urlController.text,
        'images': images,
      };

      String collection = widget.isEvent ? 'events' : 'news';

      if (_isUpdating) {
        await FirebaseFirestore.instance
            .collection(collection)
            .doc(widget.id)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection(collection).add(data);
      }

      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_isUpdating
                ? 'Data updated successfully'
                : 'Data uploaded successfully')),
      );
      Navigator.pop(context);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.isEvent ? 'Upload Event' : 'Upload News'),
      ),
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
                  controller: _authorController,
                  hintText: 'Author',
                  validator: (value) =>
                      value!.isEmpty ? 'Author is required' : null,
                ),
                CustomTextFormField(
                  controller: _authorImageController,
                  hintText: 'Author Image URL',
                  validator: (value) =>
                      value!.isEmpty ? 'Author image URL is required' : null,
                ),
                widget.isEvent
                    ? CustomTextFormField(
                        controller: _categoryController,
                        hintText: 'Event Category',
                        validator: (value) =>
                            value!.isEmpty ? 'Category is required' : null,
                      )
                    : Container(
                        padding: EdgeInsets.only(left: 3),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10)),
                        child: DropdownButtonFormField<String>(
                          value: _categoryController.text.isEmpty
                              ? null
                              : _categoryController.text,
                          // hint:  'News Category',
                          onChanged: (value) {
                            setState(() {
                              _categoryController.text = value!;
                            });
                          },
                          items: _newsCategories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          validator: (value) =>
                              value == null ? 'Category is required' : null,
                        ),
                      ),
                CustomTextFormField(
                  maxLines: 5,
                  controller: _descriptionController,
                  hintText: 'Description',
                  validator: (value) =>
                      value!.isEmpty ? 'Description is required' : null,
                ),
                CustomTextFormField(
                  controller: _locationController,
                  hintText: 'Location',
                  validator: (value) =>
                      value!.isEmpty ? 'Location is required' : null,
                ),
                if(widget.isEvent)CustomTextFormField(
                  isReadOnly: true,
                  onTap: ()=>_selectTime(_fromTimeController),
                  controller: _fromTimeController,
                  hintText: 'From Time',
                  validator: (value) =>
                  (value!.isEmpty && (widget.isEvent))? 'Time is required' : null,
                ),
                if(widget.isEvent)  CustomTextFormField(
                  isReadOnly: true,
                  onTap: ()=>_selectTime(_toTimeController),
                  controller: _toTimeController,
                  hintText: 'To Time',
                  validator: (value) =>
                  (value!.isEmpty && (widget.isEvent))? 'Time is required' : null,
                ),
                CustomTextFormField(
                  controller: _titleController,
                  hintText: 'Title',
                  validator: (value) =>
                      value!.isEmpty ? 'Title is required' : null,
                ),
                if (!widget.isEvent)
                  CustomTextFormField(
                    controller: _urlController,
                    hintText: 'External URL (optional for Market News)',
                    textInputType: TextInputType.url,
                  ),
                ..._imageControllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  return Row(
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          controller: entry.value,
                          hintText: 'Image URL ${index + 1}',
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: () => _removeImageField(index),
                      ),
                    ],
                  );
                }).toList(),
                CustomButton(
                    onPressed: _addImageField, text: 'Add Image URL'),
                SizedBox(height: 16),
                CustomButton(
                  onPressed:()=> _isUploading ? null : _uploadData(),
                  text:_isUpdating ? 'Update' : 'Upload',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
