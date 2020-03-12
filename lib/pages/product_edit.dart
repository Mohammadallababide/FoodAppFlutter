import 'package:flutter/material.dart';
import '../widgets/helpers/13.2 ensure_visible.dart.dart';
class ProductEditPage extends StatefulWidget {
  final Function addProduct;
  final Map<String, dynamic> product;
  final Function updateProduct;
  final int indexProduct;
  ProductEditPage({this.addProduct, this.updateProduct, this.product,this.indexProduct});
  @override
  State<StatefulWidget> createState() {
    return _ProductEditPageState();
  }
}

class _ProductEditPageState extends State<ProductEditPage> {
  String titleValue;
  String descriptionValue;
  double priceValue;
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': 'assets/food.jpg'
  };
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final titleFocusNode =FocusNode();
  final descriptionFocusNode =FocusNode();
  final priceFocusNode =FocusNode();
  Widget _buildTitleTextField() {
    return EnsureVisibleWhenFocused(
      focusNode: titleFocusNode,
          child: TextFormField(
            focusNode: titleFocusNode,
        decoration: InputDecoration(labelText: 'Product Title'),
        initialValue: widget.product == null ? '' : widget.product['title'],
        // autovalidate: true,
        validator: (String value) {
          if (value.isEmpty || value.length < 5) {
            return 'title is requered and should be more than 5 charecter';
          }
        },
        onSaved: (String value) {
          _formData['title'] = value;
        },
      ),
    );
  }

  Widget _buildDescraptionTextField() {
    return EnsureVisibleWhenFocused(
      focusNode: descriptionFocusNode,
          child: TextFormField(
            focusNode: descriptionFocusNode,
        maxLines: 4,
        decoration: InputDecoration(labelText: 'Product Description'),
        initialValue: widget.product == null ? '' : widget.product['description'],
        validator: (String value) {
          if (value.isEmpty || value.length < 10) {
            return 'the descraption is requered and should be more than 10 charecters';
          }
        },
        onSaved: (String value) {
          _formData['description'] = value;
        },
      ),
    );
  }

  Widget _buildPhoneTextField() {
    return EnsureVisibleWhenFocused(
      focusNode: priceFocusNode,
          child: TextFormField(
            focusNode: priceFocusNode,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Product Price'),
        initialValue:    widget.product == null ? '' : widget.product['price'].toString(),
        validator: (String value) {
          if (value.isEmpty ||
              !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
            return 'the price is required and should be a number';
          }
        },
        onSaved: (String value) {
          _formData['price'] = double.parse(value);
        },
      ),
    );
  }

  void _submitForm() {
    if (!formKey.currentState.validate()) {
      return;
    }
    formKey.currentState.save();
if(widget.product==null){
    widget.addProduct(_formData);
}
else{
  widget.updateProduct(widget.indexProduct,_formData);
}
    Navigator.pushReplacementNamed(context, '/products');
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    final Widget pageContent = GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              _buildTitleTextField(),
              _buildDescraptionTextField(),
              _buildPhoneTextField(),
              SizedBox(
                height: 10.0,
              ),
              RaisedButton(
                child: Text('Save'),
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
                onPressed: _submitForm,
              )
            ],
          ),
        ),
      ),
    );
    return widget.product == null
        ? pageContent
        : Scaffold(
            appBar: AppBar(
              title: Text('Edit Product'),
            ),
            body: pageContent,
          );
  }
}
