import 'package:scoped_model/scoped_model.dart';
import '../models/product.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

mixin ConectedProductModel on Model {
  List<Product> _products = [];
  String _selProductId;
  bool _isLoading = false;
  User _authenticatedUser;
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

  int get selectedProductIndex {
    return _products.indexWhere((Product product) {
      return product.id == _selProductId;
    });
  }

// to set index to the selctedProductIndex
  void selectedProduct(String productId) {
    _selProductId = productId;
    notifyListeners();
  }

  String get selctedProductId {
    return _selProductId;
  }

  Product get selctedProduct {
    if (selctedProductId == null) {
      return null;
    }
    // firstwhere function return one item when the body is true
    return _products.firstWhere((Product product) {
      return product.id == _selProductId;
    });
  }

  //  here in the addProduct we make the return type of the function is Future to use then method
  Future<bool> addProduct(
      {String title, double price, String description, String image}) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'price': price,
      'description': description,
      'image':
          'https://static.onecms.io/wp-content/uploads/sites/9/2019/10/chocolate-scorecard-child-labor-FT-BLOG1019.jpg',
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
    };
    try {
      final http.Response response = await http.post(
          'https://flutter-products-152af.firebaseio.com/products.json',
          body: json.encode(productData));
      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseDate = json.decode(response.body);
      Product newProduct = Product(
          id: responseDate['name'],
          title: title,
          image: image,
          price: price,
          description: description,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id);
      _products.add(newProduct);
      _isLoading = false;
      //  for update the widget that wraping by model when exucute this function
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Null> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final http.Response response = await http
          .get('https://flutter-products-152af.firebaseio.com/products.json');
      final List<Product> fetchingProductsData = [];
      final Map<String, dynamic> productDataList = json.decode(response.body);
      //  here we ensure if the found products on the server
      if (productDataList == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      productDataList.forEach((String productId, dynamic productData) {
        final Product product = Product(
          id: productId,
          title: productData['title'],
          price: productData['price'],
          description: productData['description'],
          image: productData['image'],
          userEmail: productData['userEmail'],
          userId: productData['userId'],
        );
        fetchingProductsData.add(product);
      });
      _products = fetchingProductsData;
      _isLoading = false;
      notifyListeners();
      // _selProductId =null;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return;
    }
  }

  Future<bool> updateProduct(
      {String title, double price, String description, String image}) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> updateData = {
      'title': title,
      'price': price,
      'description': description,
      'image':
          'https://static.onecms.io/wp-content/uploads/sites/9/2019/10/chocolate-scorecard-child-labor-FT-BLOG1019.jpg',
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
    };
    try {
      final http.Response response = await http.put(
          'https://flutter-products-152af.firebaseio.com/products/${selctedProduct.id}.json',
          body: json.encode(updateData));

      _isLoading = false;
      Product updateProduct = Product(
          id: selctedProduct.id,
          title: title,
          image: image,
          price: price,
          description: description,
          userEmail: selctedProduct.userEmail,
          userId: selctedProduct.userId);
      _products[selectedProductIndex] = updateProduct;
      //  for update the widget that wraping by model when exucute this function
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct() async {
    try {
      _isLoading = true;
      final deletedProductId = selctedProduct.id;
      _products.removeAt(selectedProductIndex);
      _selProductId = null;
      //  for update the widget that wraping by model when exucute this function
      notifyListeners();
      final http.Response response = await http.delete(
          'https://flutter-products-152af.firebaseio.com/products/${deletedProductId}.json');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void toggleProductFavoriteStaus() {
    final bool isCurrentFavorite = selctedProduct.isFavorite;
    final bool newFavorite = !isCurrentFavorite;
    final Product upadateProduct = Product(
      id: selctedProduct.id,
      description: selctedProduct.description,
      price: selctedProduct.price,
      title: selctedProduct.title,
      image: selctedProduct.image,
      isFavorite: newFavorite,
      userEmail: selctedProduct.userEmail,
      userId: selctedProduct.userId,
    );
    _products[selectedProductIndex] = upadateProduct;

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
mixin UtilityModel on ConectedProductModel {
  bool get isLoading {
    return _isLoading;
  }
}
