import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:simple_cyrptocoin_portfolio/models/coin.dart';
import 'package:simple_cyrptocoin_portfolio/models/coins.dart';

class HTTPHelper {
  static const String baseurl = "https://api.coingecko.com/api/v3";
  static const String apiKey = ""; // Add your API KEY here

  static Future<bool> getCoinPrices(Coins coinsM) async {
    final url = Uri.parse(
        "$baseurl/coins/markets?vs_currency=usd&ids=${coinsM.coinIds.join(",")}&x_cg_demo_api_key=$apiKey");
    final response = await http.get(url, headers: {
      'accept': 'application/json',
    });
    if (response.statusCode == 200) {
      List<dynamic> coins = jsonDecode(response.body);
      for (Map<String, dynamic> coin in coins) {
        // somecoins have null prices for some reason
        coin["current_price"] = coin["current_price"] ?? 0;

        Coin temp = (Coin(
            coinId: coin["id"],
            name: coin["name"],
            imageUrl: coin["image"],
            price: (coin["current_price"] is int)
                ? (coin["current_price"] as int).toDouble()
                : coin["current_price"],
            total:
                coinsM.coins.firstWhere((e) => e.coinID == coin["id"]).total));
        coinsM.deleteCoin(temp, false);
        coinsM.addCoin(temp, false);
        await temp.updateEntry();
      }
      return true;
    } else {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getSingleCoin(String id) async {
    final url = Uri.parse(
        "$baseurl/coins/markets?vs_currency=usd&ids=$id&x_cg_demo_api_key=$apiKey");
    final response = await http.get(url, headers: {
      'accept': 'application/json',
    });
    if (response.statusCode == 200) {
      List<dynamic> coins = jsonDecode(response.body);
      for (Map<String, dynamic> coin in coins) {
        return {
          "name": coin["name"],
          "image": coin["image"],
          "price": (coin["current_price"] is int)
              ? (coin["current_price"] as int).toDouble()
              : coin["current_price"],
          "marketCap": coin["market_cap"],
          "change24": coin["price_change_24h"]
        };
      }
    } else {
      return null;
    }
    return null;
  }

  static Future<Coins?> getPopular() async {
    final url = Uri.parse(
        "$baseurl/coins/markets?vs_currency=usd&per_page=50&x_cg_demo_api_key=$apiKey");
    final response = await http.get(url, headers: {
      'accept': 'application/json',
    });
    Coins temp = Coins(coins: {});
    if (response.statusCode == 200) {
      List<dynamic> coins = jsonDecode(response.body);
      for (Map<String, dynamic> coin in coins) {
        temp.addCoin(
            Coin(
                coinId: coin["id"],
                name: coin["name"],
                price: (coin["current_price"] is int)
                    ? (coin["current_price"] as int).toDouble()
                    : coin["current_price"],
                total: 0.0,
                imageUrl: coin["image"]),
            false);
      }
      return temp;
    } else {
      return null;
    }
  }

  static Future<dynamic> searchCoins(String search) async {
    final url =
        Uri.parse("$baseurl/search?query=$search&x_cg_demo_api_key=$apiKey");
    final response = await http.get(url, headers: {
      'accept': 'application/json',
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> re = jsonDecode(response.body);
      List<dynamic> coins = re["coins"];
      Coins temp = Coins(coins: {});
      for (Map<String, dynamic> coin in coins) {
        temp.addCoin(
            Coin(
                coinId: coin["id"],
                name: coin["name"],
                price: 0.0,
                total: 0.0,
                imageUrl: coin["large"]),
            false);
      }
      return temp;
    } else {
      return false;
    }
  }
}
