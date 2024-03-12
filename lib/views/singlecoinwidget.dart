import 'package:flutter/material.dart';
import 'package:simple_cyrptocoin_portfolio/utils/http.dart';
import 'package:simple_cyrptocoin_portfolio/views/loadingscreen.dart';
import 'package:simple_cyrptocoin_portfolio/views/networkimage.dart';
import 'package:provider/provider.dart';

import 'failmessagewidget.dart';

class CoinLoader extends StatelessWidget {
  final String coinId;
  const CoinLoader({super.key, required this.coinId});

  Future<Map<String, dynamic>?> _loadData() async {
    return await HTTPHelper.getSingleCoin(coinId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureProvider<Map<String, dynamic>?>(
        create: (_) => _loadData(),
        initialData: const {},
        child: const CoinPage());
  }
}

class CoinPage extends StatelessWidget {
  const CoinPage({super.key});

  Row singleCoinWidget(BuildContext context, Map<String, dynamic> coin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.sizeOf(context).width * .2,
          child: NetworkImageWidget(imageUrl: coin["image"]),
        ),
        const SizedBox(
          width: 10,
        ),
        SizedBox(
          width: MediaQuery.sizeOf(context).width * .7,
          child: Center(
              child: Text(
            "Name: ${coin["name"]}\nPrice USD: \$${coin["price"]}\nMarketCap: \$${coin["marketCap"]}\n24 Hour Change: \$${coin["change24"]}",
            style: const TextStyle(fontSize: 20),
          )),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? singleCoin =
        Provider.of<Map<String, dynamic>?>(context);
    if (singleCoin == null) {
      return Scaffold(
        appBar: AppBar(title: const Center(child: Text("Single Coin View"))),
        body: const FailMessageWidget(),
      );
    } else if (singleCoin.isEmpty) {
      return const LoadingScreen();
    } else {
      return Scaffold(
        appBar: AppBar(
            title: Center(child: Text("Detailed ${singleCoin["name"]}"))),
        body: Center(
          child: ListView(
              padding: const EdgeInsets.all(10),
              shrinkWrap: true,
              children: List.generate(1, (index) {
                return Center(
                  child: singleCoinWidget(context, singleCoin),
                );
              })),
        ),
      );
    }
  }
}
