import 'package:simple_cyrptocoin_portfolio/models/coin.dart';

class Coins {
  final Set<Coin> _coins;
  final Set<String> _coinIds;

  Coins({required Set<Coin> coins})
      : _coins = coins,
        _coinIds = coins.map((e) => e.coinID).toSet();

  Set<Coin> get coins => _coins;
  Set<String> get coinIds => _coinIds;

  void addCoin(Coin coin, bool updateDB) async {
    _coins.add(coin);
    _coinIds.add(coin.coinID);
    if (updateDB) {
      await coin.insertEntry();
    }
  }

  bool isEmpty() {
    return _coins.isEmpty;
  }

  Future<void> deleteCoin(Coin coin, bool updateDB) async {
    _coins.remove(coin);
    _coinIds.remove(coin.coinID);
    if (updateDB) {
      await coin.deleteEntry();
    }
  }

  Future<void> addAllCoins() async {
    for (Coin coin in _coins) {
      await coin.insertEntry();
    }
  }
}
