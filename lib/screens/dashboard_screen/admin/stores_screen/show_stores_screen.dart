import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:primax_lyalaty_program/screens/dashboard_screen/admin/stores_screen/add_stores_screen.dart';

class ShowStoresScreen extends StatefulWidget {
  @override
  _ShowStoresScreenState createState() => _ShowStoresScreenState();
}

class _ShowStoresScreenState extends State<ShowStoresScreen> {
  final CollectionReference stores = FirebaseFirestore.instance.collection('stores');

  void _deleteStore(String id) {
    stores.doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Store deleted successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stores'),
        actions: [
          IconButton(onPressed: (){ Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddStoresScreen()),
          );}, icon: Icon(Icons.add))
        ],
      ),
      body: StreamBuilder(
        stream: stores.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No stores available'));
          }

          return ListView(
            children: snapshot.data!.docs.map((store) {
              Map<String, dynamic> data = store.data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(data['name'] ?? 'No Name'),
                  subtitle: Text(data['category'] ?? 'No Category'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddStoresScreen(storeId: store.id,),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteStore(store.id),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
