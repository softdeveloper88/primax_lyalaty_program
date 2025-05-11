import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/screens/dashboard_screen/admin/orders_screen/show_orders_screen.dart';
import 'package:primax_lyalaty_program/screens/dashboard_screen/admin/products_screen/product_screen.dart';
import 'package:primax_lyalaty_program/screens/dashboard_screen/admin/stores_screen/show_stores_screen.dart';
import 'package:primax_lyalaty_program/screens/dashboard_screen/admin/users/show_users_screen.dart';
import 'package:primax_lyalaty_program/screens/home_screen/news_event_screen.dart';
import 'package:primax_lyalaty_program/screens/notification_screen.dart';
import 'package:primax_lyalaty_program/widgets/comman_back_button.dart';

import 'brands_screen/show_brands_screen.dart';
import 'downloads/download_list_screen.dart';
import 'orders_screen/order_by_status_screen.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int usersCount = 0;
  int totalOrders = 0;
  int pendingOrders = 0;
  int acceptedOrders = 0;
  int completedOrders = 0;
  int cancelOrders = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    var usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    var ordersSnapshot = await FirebaseFirestore.instance.collection('orders').get();

    setState(() {
      usersCount = usersSnapshot.size;
      totalOrders = ordersSnapshot.size;
      pendingOrders = ordersSnapshot.docs.where((doc) => doc['orderStatus'] == 'Pending').length;
      acceptedOrders = ordersSnapshot.docs.where((doc) => doc['orderStatus'] == 'Accepted').length;
      completedOrders = ordersSnapshot.docs.where((doc) => doc['orderStatus'] == 'Completed').length;
      cancelOrders = ordersSnapshot.docs.where((doc) => doc['orderStatus'] == 'Cancellation Requested').length;
    });
  }

  Widget buildStatCard(String title, int count, IconData icon, Color color,Function onTap) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap:()=> onTap(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 36, color: color),
                SizedBox(height: 10),
                Text(
                  '$count',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(title, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDashboardCard(String title, IconData icon, Color color,VoidCallback onTap) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap:(){
            print('object');
            onTap();
            },

          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color, size: 30),
                ),
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard'),
      centerTitle: true,
      leading: CommonBackButton(onPressed: ()=>Navigator.pop(context),),
      actions: [
        IconButton(
            onPressed: (){
              NotificationScreen(userId:'1').launch(context,pageRouteAnimation:PageRouteAnimation.Slide);

            },
            icon: Icon(CupertinoIcons.bell_fill))
      ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              // Top Stats
              Row(
                children: [
                  buildStatCard('Total Users', usersCount, LucideIcons.users, Colors.blue,(){
                    ShowUsersScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
                  }),
                  buildStatCard('Total Orders', totalOrders, LucideIcons.package, Colors.green,(){
                    OrderByStatusScreen(status:'All').launch(context,pageRouteAnimation:PageRouteAnimation.Slide);

                  }),

                ],
              ),
              SizedBox(height: 16),

              Row(
                children: [
                  buildStatCard('Cancel Orders Request', cancelOrders, LucideIcons.package2, Colors.red,(){
                    OrderByStatusScreen(status:'Cancellation Requested').launch(context,pageRouteAnimation:PageRouteAnimation.Slide);

                  }),
                  buildStatCard('Pending Orders', pendingOrders, LucideIcons.clock, Colors.orange,(){
                    OrderByStatusScreen(status:'Pending').launch(context,pageRouteAnimation:PageRouteAnimation.Slide);
                  }),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [

                  buildStatCard('Accepted Orders', acceptedOrders, LucideIcons.checkCircle, Colors.blueAccent,(){
                    OrderByStatusScreen(status:'Accepted').launch(context,pageRouteAnimation:PageRouteAnimation.Slide);

                  }),
                  buildStatCard('Completed Orders', completedOrders, LucideIcons.check, Colors.green,(){
                    OrderByStatusScreen(status:'Completed').launch(context,pageRouteAnimation:PageRouteAnimation.Slide);

                  }),
                ],
              ),
              SizedBox(height: 24),
              // Dashboard Cards
              Row(
                children: [
                  buildDashboardCard('Downloads', LucideIcons.download, Colors.purple,(){
                    DownloadListScreen().launch(context);
                  }),
                  buildDashboardCard('News & Events', LucideIcons.calendar, Colors.orange,(){
                    NewsEventScreen(isFromAdmin:true,).launch(context);

                  }),
                ],
              ),
              // SizedBox(height: 16),
              // Row(
              //   children: [
              //     buildDashboardCard('News', LucideIcons.newspaper, Colors.red,(){
              //       NewsEventScreen(isFromAdmin:true,).launch(context);
              //
              //     }),
              //     buildDashboardCard('Orders', LucideIcons.shoppingBag, Colors.blue,(){
              //       ShowOrdersScreen().launch(context);
              //
              //     }),
              //   ],
              // ),
              SizedBox(height: 16),
              Row(
                children: [
                  buildDashboardCard('Products', LucideIcons.box, Colors.green,(){
                    ProductScreen().launch(context);

                  }),
                  buildDashboardCard('Stores', LucideIcons.store, Colors.teal,(){
                    ShowStoresScreen().launch(context);

                  }),
                ],
              ),
              Row(
                children: [

                  buildDashboardCard('Brands', LucideIcons.image, Colors.teal,(){
                    ShowBrandsScreen().launch(context);

                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
