import 'package:flutter/material.dart';
import '../products/price.dart';
import '../ui_elements/title_defualt.dart';
import '../products/addres_tag.dart';
class ProductCard extends StatelessWidget {
  final Map<String , dynamic> products;
  final int indexProduct ;
  ProductCard(this.products,this.indexProduct);
  @override
  Widget build(BuildContext context) {
  return  Card(
      child: Column(
        children: <Widget>[
          Image.asset(products['image']),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          TitleDefault(products['title']) ,

              SizedBox(
                width: 20.0,
              ),
              PriseTag(products['price'].toString()),
            ],
          ),
          AddressTag('Syria-Damascus-Almedan-BigFive_Mole '),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.info,
                      color: Theme.of(context).accentColor,
                    ),
                    onPressed: () => Navigator.pushNamed<bool>(
                        context, '/product/' + indexProduct.toString()),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () => Navigator.pushNamed<bool>(
                        context, '/product/' + indexProduct.toString()),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}