import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth.dart';

import '../screens/orders_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Hello Friend!'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Shop'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Orders'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(OrdersScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exposure_neg_1),
            title: Text('Logout'),
            onTap: () {
              // Navigator.of(context)
              //     .pushReplacementNamed(UserProductsScreen.routeName);
              Navigator.of(context).pop();
              Provider.of<Auth>(context).logout();
            },
          ),
        ],
      ),
    );
  }
}
