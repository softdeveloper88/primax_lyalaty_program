import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/screens/dashboard_screen/admin/downloads/add_download_manul.dart';

class DownloadListScreen extends StatefulWidget {
  @override
  _DownloadListScreenState createState() => _DownloadListScreenState();
}

class _DownloadListScreenState extends State<DownloadListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deleteData(String id) async {
    await _firestore.collection('downloads').doc(id).delete();
  }

  Future<void> _updateData(String id) async {
   AddDownloadManul(id:id).launch(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Download Data',),actions: [
        IconButton(onPressed: (){
          AddDownloadManul().launch(context);

        }, icon: Icon(LucideIcons.plus))
      ],),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('downloads').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {

              var doc = data[index];
              return ListTile(
                title: Text(doc['file_name']),
                subtitle: Text(doc['brand']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _updateData(doc.id); // Update data
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteData(doc.id); // Delete data
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
