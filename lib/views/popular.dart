import 'package:flutter/material.dart';
import 'package:simple_cyrptocoin_portfolio/models/coin.dart';
import 'package:simple_cyrptocoin_portfolio/models/coins.dart';
import 'package:simple_cyrptocoin_portfolio/utils/http.dart';
import 'package:simple_cyrptocoin_portfolio/views/loadingscreen.dart';
import 'package:simple_cyrptocoin_portfolio/views/networkimage.dart';
import 'package:simple_cyrptocoin_portfolio/views/singlecoinwidget.dart';
import 'package:provider/provider.dart';

import 'failmessagewidget.dart';

class PopularCoinsLoader extends StatelessWidget {
  final Coins userCoins;
  const PopularCoinsLoader({super.key, required this.userCoins});

  Future<Coins?> _loadData() async {
    return await HTTPHelper.getPopular();
  }

  @override
  Widget build(BuildContext context) {
    return FutureProvider<Coins?>(
        create: (_) => _loadData(),
        initialData: Coins(coins: {}),
        child: PopularPage(
          userCoins: userCoins,
        ));
  }
}

class PopularPage extends StatefulWidget {
  final Coins userCoins;
  const PopularPage({super.key, required this.userCoins});

  @override
  State<PopularPage> createState() => _PopularPageState();
}

class _PopularPageState extends State<PopularPage> {
  InkWell popularCoinWidget(BuildContext context, Coin coin) {
    return InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return CoinLoader(coinId: coin.coinID);
            },
          ));
        },
        hoverColor: Colors.blue[200],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width * .1,
              child: NetworkImageWidget(imageUrl: coin.imageUrl),
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * .7,
              child: Center(
                  child: Text(
                "Name: ${coin.name} - Price USD: \$${coin.price}",
                style: const TextStyle(fontSize: 20),
              )),
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * .1,
              child: widget.userCoins.coins.contains(coin)
                  ? IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                                content: Center(
                          child: Text(
                              "You already added this coin to your coins."),
                        )));
                      },
                      icon: const Icon(Icons.check))
                  : IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Center(
                          child: Text("Added ${coin.name} to your Coins"),
                        )));
                        addCoin(coin);
                      },
                      icon: const Icon(Icons.add)),
            )
          ],
        ));
  }

  void addCoin(Coin coin) {
    super.setState(() {
      widget.userCoins.addCoin(coin, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    Coins? popularCoins = Provider.of<Coins?>(context);
    if (popularCoins == null) {
      return Scaffold(
        appBar: AppBar(
            title: const Center(child: Text("Top 50 Coins on CoinGecko"))),
        body: const FailMessageWidget(),
      );
    } else if (popularCoins.coins.isEmpty) {
      return const LoadingScreen();
    } else {
      return Scaffold(
        appBar: AppBar(
            title: const Center(child: Text("Top 50 Coins on CoinGecko"))),
        body: ListView(
          padding: const EdgeInsets.all(10),
          children: List.generate(popularCoins.coins.length, (index) {
            return popularCoinWidget(
                context, popularCoins.coins.elementAt(index));
          }),
        ),
      );
    }
  }
}
