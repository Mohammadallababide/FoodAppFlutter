import '../../scoped-models/main.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

class LogOutListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ListTile(
        title: Text('Logout'),
        leading: Icon(Icons.exit_to_app),
        onTap: () {
          model.logout();
        },
      );
    });
  }
}
