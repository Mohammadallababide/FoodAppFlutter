import 'package:scoped_model/scoped_model.dart';

import '../models/product.dart';

class ProductsModel extends Model {
  List<Product> _products = [];
  int _selctedProductIndex;

  List<Product> get products {
    return List.from(_products);
  }

  int get selctedProductIndex {
    return _selctedProductIndex;
  }

  Product get selctedProduct {
    if (_selctedProductIndex == null) {
      return null;
    }
    return _products[selctedProductIndex];
  }

  void addProduct(Product product) {
    _products.add(product);
    _selctedProductIndex = null;
  }

  void updateProduct(Product product) {
    _products[_selctedProductIndex] = product;
    _selctedProductIndex = null;
  }

  void deleteProduct() {
    _products.removeAt(_selctedProductIndex);
    _selctedProductIndex = null;
  }

  void selectedProduct(int index) {
    _selctedProductIndex = index;
  }
}
