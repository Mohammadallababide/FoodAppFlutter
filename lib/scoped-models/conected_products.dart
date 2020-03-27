import 'package:flutter_course/models/auth.dart';
import 'package:scoped_model/scoped_model.dart';
import '../models/product.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';

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
          'https://flutter-products-152af.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
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
      print('NetWork Wrong');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Null> fetchProducts({onlyForuser = false}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final http.Response response = await http.get(
          'https://flutter-products-152af.firebaseio.com/products.json?auth=${_authenticatedUser.token}');
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
          isFavorite: productData['wishlistUsers'] == null
              ? false
              : (productData['wishlistUsers'] as Map<String, dynamic>)
                  .containsKey(_authenticatedUser.id),
        );
        fetchingProductsData.add(product);
      });
      _products = onlyForuser
          ? fetchingProductsData.where((Product product) {
              return product.userId == _authenticatedUser.id;
            }).toList()
          : fetchingProductsData;
      _isLoading = false;
      notifyListeners();
      // _selProductId =null;
    } catch (error) {
      print('NetWork Wrong');
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
          'https://flutter-products-152af.firebaseio.com/products/${selctedProduct.id}.json?auth=${_authenticatedUser.token}',
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
      print('NetWork Wrong');
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
          'https://flutter-products-152af.firebaseio.com/products/${deletedProductId}.json?auth=${_authenticatedUser.token}');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      print('NetWork Wrong');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void toggleProductFavoriteStaus() async {
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
    http.Response response;
    if (newFavorite) {
      response = await http.put(
          'https://flutter-products-152af.firebaseio.com/products/${selctedProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(true));
    } else {
      response = await http.delete(
        'https://flutter-products-152af.firebaseio.com/products/${selctedProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final Product upadateProduct = Product(
          id: selctedProduct.id,
          description: selctedProduct.description,
          price: selctedProduct.price,
          title: selctedProduct.title,
          image: selctedProduct.image,
          // for undo toggel action when any wron occuared
          isFavorite: !newFavorite,
          userEmail: selctedProduct.userEmail,
          userId: selctedProduct.userId,
        );
        _products[selectedProductIndex] = upadateProduct;
        //  for update the widget that wraping by model when exucute this function
        notifyListeners();
      }
    }
  }

  void toggelDissplayMode() {
    _showFavorite = !_showFavorite;
    notifyListeners();
  }
}

mixin UserModel on ConectedProductModel {
  PublishSubject<bool> _userSubject = PublishSubject();

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Timer _authTimer;
  User get user {
    return _authenticatedUser;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    http.Response response;
    Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    _isLoading = true;
    notifyListeners();
    if (mode == AuthMode.Login) {
      response = await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCyOYgztVLcIlTtgda1sfV-OZ4PwW9b0Ck',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      response = await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCyOYgztVLcIlTtgda1sfV-OZ4PwW9b0Ck',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    String message = 'something is wrong';
    bool hasError = true;
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Authincecation successed';
      _authenticatedUser = User(
        id: responseData['localId'],
        email: email,
        token: responseData['idToken'],
      );
      _userSubject.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      setAuthTimeOut(int.parse(responseData['expiresIn']));
      final SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString('token', responseData['idToken']);
      pref.setString('userEmail', email);
      pref.setString('userId', responseData['localId']);
      pref.setString('expiryTime', expiryTime.toIso8601String());
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'the email not found';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'invalid password';
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'email alrady exists';
    }
    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  void autoAuthenticate() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final String token = pref.getString('token');
    final String expiryTimeString = pref.getString('expiryTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final parsedExpiryTime = DateTime.parse(expiryTimeString);
      //  check if we have valied expiry time or token
      if (parsedExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }
      final String userEmail = pref.getString('userEmail');
      final String userId = pref.getString('userId');
      //  calculate remin time ...
      final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
      _authenticatedUser = User(id: userId, email: userEmail, token: token);
      _userSubject.add(true);
      setAuthTimeOut(tokenLifespan);
      notifyListeners();
    }
  }

  void logout() async {
    _authenticatedUser = null;
    // for clear the existing timer
    _authTimer.cancel();
    _userSubject.add(false);
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove('token');
    pref.remove('userEmail');
    pref.remove('userId');
  }

  void setAuthTimeOut(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }
}
mixin UtilityModel on ConectedProductModel {
  bool get isLoading {
    return _isLoading;
  }
}
