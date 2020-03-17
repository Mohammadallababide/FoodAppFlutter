import 'package:scoped_model/scoped_model.dart';
import '../models/product.dart';
import '../models/user.dart';

mixin ConectedProductModel on Model {
  List<Product> _products = [];
  int _selProductIndex;
  User _authenticatedUser;
  void addProduct(
      {String title, double price, String description, String image}) {
    Product newProduct = Product(
        title: title,
        image: image,
        price: price,
        description: description,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id);
    _products.add(newProduct);

    //  for update the widget that wraping by model when exucute this function
    notifyListeners();
  }
}
mixin ProductsModel on ConectedProductModel {
  //  if showFavorite is true we will show just favorit item if it null will retutn all items
  bool _showFavorite = false;
  List<Product> get allproducts {
    // to ruturn copy of the list product to edit
    // on it not on the orginal list for construct the edit do just in the scoped model
    return List.from(_products);
  }

  List<Product> get dissplayedProduct {
    if (_showFavorite) {
      // here the where function give us itrable just to the item that return true to be in the new list <<to fillter result
      return _products.where((Product product) => product.isFavorite).toList();
    } else {
      return List.from(_products);
    }
  }

  bool get disaplyFavoritesOnly {
    return _showFavorite;
  }

// to set index to the selctedProductIndex
  void selectedProduct(int index) {
    _selProductIndex = index;
    if (index == null) {
      notifyListeners();
    }
  }

  int get selctedProductIndex {
    return _selProductIndex;
  }

  Product get selctedProduct {
    if (selctedProductIndex == null) {
      return null;
    }
    return _products[selctedProductIndex];
  }

  void updateProduct(
      {String title, double price, String description, String image}) {
    Product updateProduct = Product(
        title: title,
        image: image,
        price: price,
        description: description,
        userEmail: selctedProduct.userEmail,
        userId: selctedProduct.userId);
    _products[selctedProductIndex] = updateProduct;

    //  for update the widget that wraping by model when exucute this function
    notifyListeners();
  }

  void deleteProduct() {
    _products.removeAt(selctedProductIndex);

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
      isFavorite: newFavorite,
      userEmail: selctedProduct.userEmail,
      userId: selctedProduct.userId,
    );
    _products[selctedProductIndex] = upadateProduct;

    //  for update the widget that wraping by model when exucute this function
    notifyListeners();
  }

  void toggelDissplayMode() {
    _showFavorite = !_showFavorite;
    notifyListeners();
  }
}

mixin UserModel on ConectedProductModel {
  void Login(String emial, String password) {
    _authenticatedUser =
        User(email: emial, password: password, id: 'fafadsjnl');
  }
}
