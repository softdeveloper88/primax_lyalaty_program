import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:primax_lyalaty_program/screens/dashboard_screen/admin/brands_screen/add_brand_screen.dart';
import 'package:primax_lyalaty_program/screens/dashboard_screen/admin/stores_screen/add_stores_screen.dart';

class ShowBrandsScreen extends StatefulWidget {
  @override
  _ShowBrandsScreenState createState() => _ShowBrandsScreenState();
}

class _ShowBrandsScreenState extends State<ShowBrandsScreen> {
  final CollectionReference stores = FirebaseFirestore.instance.collection('brands');

  void _deleteStore(String id) {
    stores.doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Brands deleted successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddBrandScreen(),
              ),
            );
          }, icon: Icon(Icons.add))
        ],
        title: Text('Brands'),
      ),
      body: StreamBuilder(
        stream: stores.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No Brands available'));
          }

          return ListView(
            children: snapshot.data!.docs.map((store) {
              Map<String, dynamic> data = store.data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  leading: Image.network(data['imageUrl'],height: 50,width: 50,),
                  title: Text(data['name'] ?? 'No Name'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddBrandScreen(brandId: store.id,initialName: store['name'],initialImageUrl: store['imageUrl'],),
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
