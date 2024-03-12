import 'package:simple_cyrptocoin_portfolio/utils/dbhelper.dart';

class Coin {
  final String _coinId;
  String _name;
  double _total;
  double _price;
  double _amount;
  String _imageUrl;
  Coin(
      {required String coinId,
      required String name,
      required double price,
      required double total,
      required String imageUrl})
      : _imageUrl = imageUrl,
        _price = price,
        _name = name,
        _coinId = coinId,
        _total = total,
        _amount = price * total;

  String get coinID => _coinId;
  String get name => _name;
  String get imageUrl => _imageUrl;
  double get total => _total;
  double get price => _price;
  double get amount => _amount;

  void setName(String name) {
    _name = name;
  }

  void setPrice(double price) {
    _price = price;
    _amount = price * total;
  }

  void setTotal(double total) {
    _total = total;
    _amount = price * total;
  }

  void setURL(String url) {
    _imageUrl = url;
  }

  Future<void> updateEntry() async {
    Map<String, dynamic> data = {
      "coin_id": _coinId,
      "total": _total,
      "price": _price,
      "coin_name": _name,
      "image_url": _imageUrl
    };
    await DBHelper().update("user_totals", data);
  }

  Future<int> insertEntry() async {
    Map<String, dynamic> data = {
      "coin_id": _coinId,
      "total": _total,
      "price": _price,
      "coin_name": _name,
      "image_url": _imageUrl
    };
    return await DBHelper().insert("user_totals", data);
  }

  Future<void> deleteEntry() async {
    DBHelper().delete("user_totals", _coinId);
  }

  @override
  bool operator ==(Object other) {
    return (other is Coin) && other._coinId == _coinId;
  }

  @override
  int get hashCode => identityHashCode(_coinId);
}
