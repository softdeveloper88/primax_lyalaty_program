import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:primax_lyalaty_program/widgets/custom_button.dart';
import 'package:primax_lyalaty_program/widgets/custom_text__form_field.dart';

class PaymentResult {
  final String? receiptUrl;
  final String? amount;
  
  PaymentResult(this.receiptUrl, this.amount);
}

Future<PaymentResult?> showPaymentReceiptDialog(BuildContext context, double suggestedAmount) async {
  String? uploadedImageUrl;
  File? selectedImage;
  bool isLoading = false;
  final TextEditingController amountController = TextEditingController(text: suggestedAmount.toString());
  final ImagePicker _picker = ImagePicker();
  
  // Fetch admin bank account info
  final bankAccountsSnapshot = await FirebaseFirestore.instance
      .collection('bank_accounts')
      .get();
  
  List<Map<String, dynamic>> bankAccounts = [];
  if (bankAccountsSnapshot.docs.isNotEmpty) {
    bankAccounts = bankAccountsSnapshot.docs
        .map((doc) => doc.data())
        .toList();
  }

  PaymentResult? result = await showDialog<PaymentResult>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Function to pick image from gallery
          Future<void> pickImage() async {
            final XFile? image = await _picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 80,
            );
            if (image != null) {
              setState(() {
                selectedImage = File(image.path);
              });
            }
          }

          // Function to compress image before upload
          Future<File?> compressImage(File file) async {
            try {
              // Get the file extension
              final fileExtension = path.extension(file.path);
              
              // Create a temporary file with the same extension
              final tempDir = await getTemporaryDirectory();
              final targetPath = path.join(tempDir.path, 'compressed_${DateTime.now().millisecondsSinceEpoch}$fileExtension');
              
              // Compress the image - adjust quality as needed
              final compressedFile = await FlutterImageCompress.compressAndGetFile(
                file.path,
                targetPath,
                quality: 70, // Adjust quality (0-100)
                minWidth: 1080, // Adjust maximum dimensions if needed
                minHeight: 1080,
              );
              
              return compressedFile != null ? File(compressedFile.path) : null;
            } catch (e) {
              print('Error compressing image: $e');
              return null; // Return original file if compression fails
            }
          }

          // Function to upload image to Firebase Storage
          Future<void> uploadImage() async {
            // Validate inputs
            if (selectedImage == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select a payment receipt image')),
              );
              return;
            }
            
            if (amountController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter the payment amount')),
              );
              return;
            }
            
            // Parse amount to verify it's a valid number
            try {
              double.parse(amountController.text.trim());
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid payment amount')),
              );
              return;
            }

            setState(() {
              isLoading = true;
            });

            try {
              // Create a unique file name
              final String fileName = 'payment_receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
              
              // Compress the image before uploading
              File? compressedImage = await compressImage(selectedImage!);
              File fileToUpload = compressedImage ?? selectedImage!;
              
              // Reference to storage with better configuration
              final Reference storageRef = FirebaseStorage.instance.ref();
              final Reference receiptRef = storageRef.child('payment_receipts/$fileName');

              // Configure metadata for better caching
              final SettableMetadata metadata = SettableMetadata(
                contentType: 'image/jpeg',
                customMetadata: {'timestamp': DateTime.now().toIso8601String()},
                cacheControl: 'public, max-age=31536000', // Cache for 1 year
              );

              // Upload the file with optimized settings
              final UploadTask uploadTask = receiptRef.putFile(fileToUpload, metadata);
              
              // Listen to upload progress for better UX
              uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
                final progress = snapshot.bytesTransferred / snapshot.totalBytes;
                print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
              });
              
              // Wait for upload to complete
              await uploadTask.whenComplete(() => print('Upload complete'));
              
              // Get download URL
              uploadedImageUrl = await receiptRef.getDownloadURL();
              
              // Close the dialog and return results
              Navigator.pop(context, PaymentResult(
                uploadedImageUrl, 
                amountController.text.trim()
              ));
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment receipt uploaded successfully')),
              );
            } catch (e) {
              setState(() {
                isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error uploading receipt: $e')),
              );
            }
          }

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: const Text(
                            'PAYMENT CONFIRMATION',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.blue,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    const Divider(thickness: 1),
                    const SizedBox(height: 15),
                    
                    const Text(
                      'Primax Bank Account Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Show bank account info
                    bankAccounts.isEmpty
                        ? const Text('No bank account information available. Please contact admin.')
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: bankAccounts.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bank: ${bankAccounts[index]['bank_name'] ?? ''}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 5),
                                      Text('Account Name: ${bankAccounts[index]['account_name'] ?? ''}'),
                                      const SizedBox(height: 5),
                                      Text('Account Number: ${bankAccounts[index]['account_number'] ?? ''}'),
                                      if (bankAccounts[index]['branch_code'] != null) ...[
                                        const SizedBox(height: 5),
                                        Text('Branch Code: ${bankAccounts[index]['branch_code']}'),
                                      ],
                                      // if (bankAccounts[index]['swiftCode'] != null) ...[
                                      //   const SizedBox(height: 5),
                                      //   Text('Swift Code: ${bankAccounts[index]['swiftCode']}'),
                                      // ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                    
                    const SizedBox(height: 20),
                    const Text(
                      'Payment Amount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Amount textfield
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter payment amount',
                            prefixText: 'PKR ',
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    const Text(
                      'Upload Payment Receipt',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Image preview
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Center(
                              child: Text('No image selected'),
                            ),
                    ),
                    
                    const SizedBox(height: 15),
                    
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            onPressed: pickImage,
                            text: "Select Image",
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 15),
                    
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            onPressed: isLoading ? (){} : uploadImage,
                            text: isLoading ? "Uploading..." : "Upload & Confirm Payment",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );

  return result;
}