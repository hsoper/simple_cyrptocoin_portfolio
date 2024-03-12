import 'package:flutter/material.dart';
import 'package:simple_cyrptocoin_portfolio/models/coin.dart';
import 'package:simple_cyrptocoin_portfolio/models/coins.dart';
import 'package:simple_cyrptocoin_portfolio/utils/http.dart';
import 'package:simple_cyrptocoin_portfolio/views/loadingscreen.dart';
import 'package:simple_cyrptocoin_portfolio/views/singlecoinwidget.dart';
import 'package:provider/provider.dart';
import 'failmessagewidget.dart';
import 'networkimage.dart';

class SearchCoinsLoader extends StatelessWidget {
  final Coins userCoins;
  final String search;
  const SearchCoinsLoader(
      {super.key, required this.userCoins, required this.search});

  Future<Coins?> _loadData() async {
    return await HTTPHelper.searchCoins(search);
  }

  @override
  Widget build(BuildContext context) {
    return FutureProvider<Coins?>(
        create: (_) => _loadData(),
        initialData: null,
        child: SearchPage(
          userCoins: userCoins,
          search: search,
        ));
  }
}

class SearchPage extends StatefulWidget {
  final Coins userCoins;
  final String search;
  const SearchPage({super.key, required this.userCoins, required this.search});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  InkWell searchCoinWidget(BuildContext context, Coin coin) {
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
                "Name: ${coin.name}",
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
    Coins? searchResults = Provider.of<Coins?>(context);
    if (searchResults == null) {
      return const LoadingScreen();
    } else if (searchResults.coins.isEmpty) {
      return Scaffold(
          appBar: AppBar(
              title:
                  Center(child: Text("Search results for ${widget.search}"))),
          body: Center(
            child: Title(
                color: Colors.black,
                child: const Text("No results. Go back to homepage.")),
          ));
    } else if (searchResults is bool) {
      return Scaffold(
        appBar: AppBar(
            title: Center(child: Text("Search results for ${widget.search}"))),
        body: const FailMessageWidget(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
            title: Center(child: Text("Search results for ${widget.search}"))),
        body: ListView(
          padding: const EdgeInsets.all(10),
          children: List.generate(searchResults.coins.length, (index) {
            return searchCoinWidget(
                context, searchResults.coins.elementAt(index));
          }),
        ),
      );
    }
  }
}
