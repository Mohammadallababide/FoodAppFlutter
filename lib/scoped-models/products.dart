import 'package:scoped_model/scoped_model.dart';

import '../models/product.dart';

class ProductsModel extends Model {
  List<Product> _products = [];
  int _selctedProductIndex;
  //  if showFavorite is true we will show just favorit item if it null will retutn all items
  bool _showFavorite = false;
  List<Product> get products {
    // to ruturn copy of the list product to edit
    // on it not on the orginal list for construct the edit do just in the scoped model
    return List.from(_products);
  }

  List<Product> get dissplayedProduct {
    if (_showFavorite) {
      // here the where function give us itrable just to the item that return true to be in the new list <<to fillter result
      return _products.where((Product product) => product.isFavorite).toList();
    }else{
      return List.from(_products);
    }
  }
bool get disaplyFavoritesOnly{
  return _showFavorite;
}
// to set index to the selctedProductIndex
  void selectedProduct(int index) {
    _selctedProductIndex = index;
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
    //  to unselcted product when you add product
    _selctedProductIndex = null;
    //  for update the widget that wraping by model when exucute this function
    notifyListeners();
  }

  void updateProduct(Product product) {
    _products[_selctedProductIndex] = product;
    //  to unselcted product when you update product
    _selctedProductIndex = null;
    //  for update the widget that wraping by model when exucute this function
    notifyListeners();
  }

  void deleteProduct() {
    _products.removeAt(_selctedProductIndex);
    //  to unselcted product when you delete product
    _selctedProductIndex = null;
    //  for update the widget that wraping by model when exucute this function
    notifyListeners();
  }

  void toggleProductFavoriteStaus() {
    final bool isCurrentFavorite = selctedProduct.isFavorite;
    final bool newFavorite = !isCurrentFavorite;
    final Product upadateProduct = Product(
        description: selctedProduct.description,
        price: selctedProduct.price,
        title: selctedProduct.title,
        image: selctedProduct.image,
        isFavorite: newFavorite);
    _products[_selctedProductIndex] = upadateProduct;
    //  for update the widget that wraping by model when exucute this function
    notifyListeners();
    _selctedProductIndex = null;
  }

  void toggelDissplayMode() {
    _showFavorite = !_showFavorite;
    notifyListeners();
  }
}
