import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/main.dart';
import '../widgets/products/products.dart';

class ProductsPage extends StatefulWidget {
  final MainModel model;
  ProductsPage(this.model);
  @override
  _StateProductsPage createState() => _StateProductsPage();
}

class _StateProductsPage extends State<ProductsPage> {
   @override
   initState(){
     widget.model.fetchProducts();
     super.initState();
   }
    Widget _buildSideDrawer(BuildContext context) {
      return Drawer(
        child: Column(
          children: <Widget>[
            AppBar(
              automaticallyImplyLeading: false,
              title: Text('Choose'),
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Manage Products'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/admin');
              },
            )
          ],
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        drawer: _buildSideDrawer(context),
        appBar: AppBar(
          title: Text('EasyList'),
          actions: <Widget>[
            ScopedModelDescendant<MainModel>(
              builder: (BuildContext context, Widget child, MainModel model) {
                return IconButton(
                  icon: Icon(
                    model.disaplyFavoritesOnly
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                  onPressed: () {
                    model.toggelDissplayMode();
                  },
                );
              },
            )
          ],
        ),
        body: Products(),
      );
    }
  }

