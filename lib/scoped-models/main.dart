import 'package:scoped_model/scoped_model.dart';

import './conected_products.dart';

class MainModel extends Model with ConectedProductModel,UserModel , ProductsModel {}
