import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/widgets/comman_back_button.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';

class ManageBankAccountScreen extends StatefulWidget {
  const ManageBankAccountScreen({Key? key}) : super(key: key);

  @override
  State<ManageBankAccountScreen> createState() => _ManageBankAccountScreenState();
}

class _ManageBankAccountScreenState extends State<ManageBankAccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _branchCodeController = TextEditingController();
  
  bool _isLoading = false;
  bool _hasExistingAccount = false;
  String? _documentId;
  
  @override
  void initState() {
    super.initState();
    _fetchBankAccountDetails();
  }
  
  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _branchCodeController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchBankAccountDetails() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('bank_accounts')
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data();
        _documentId = snapshot.docs.first.id;
        
        setState(() {
          _bankNameController.text = data['bank_name'] ?? '';
          _accountNameController.text = data['account_name'] ?? '';
          _accountNumberController.text = data['account_number'] ?? '';
          _branchCodeController.text = data['branch_code'] ?? '';
          _hasExistingAccount = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching bank account details: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _saveBankAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final bankData = {
        'bank_name': _bankNameController.text.trim(),
        'account_name': _accountNameController.text.trim(),
        'account_number': _accountNumberController.text.trim(),
        'branch_code': _branchCodeController.text.trim(),
        'updated_at': FieldValue.serverTimestamp(),
      };
      
      if (_hasExistingAccount && _documentId != null) {
        // Update existing record
        await FirebaseFirestore.instance
            .collection('bank_accounts')
            .doc(_documentId)
            .update(bankData);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bank account updated successfully')),
        );
      } else {
        // Create new record
        bankData['created_at'] = FieldValue.serverTimestamp();
        
        await FirebaseFirestore.instance
            .collection('bank_accounts')
            .add(bankData);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bank account added successfully')),
        );
        
        // Refresh to get the document ID
        _fetchBankAccountDetails();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving bank account details: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_hasExistingAccount ? 'Update Bank Account' : 'Add Bank Account'),
        centerTitle: true,
        leading: CommonBackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instructions
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'These bank details will be shown to users when they want to make payments. Please ensure the information is accurate.',
                        style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Bank Name
                    Text('Bank Name', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _bankNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter bank name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter bank name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Account Name
                    Text('Account Holder Name', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _accountNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter account holder name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter account holder name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Account Number
                    Text('Account Number', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _accountNumberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter account number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter account number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Branch Code
                    Text('Branch Code', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _branchCodeController,
                      decoration: InputDecoration(
                        hintText: 'Enter branch code',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter branch code';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32),
                    
                    // Save Button
                    CustomButton(
                      text: _hasExistingAccount ? 'Update Bank Account' : 'Save Bank Account',
                      onPressed: _saveBankAccount,
                      height: 50,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}