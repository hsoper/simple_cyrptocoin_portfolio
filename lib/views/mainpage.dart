import 'package:flutter/material.dart';
import 'package:simple_cyrptocoin_portfolio/models/coin.dart';
import 'package:simple_cyrptocoin_portfolio/models/coins.dart';
import 'package:simple_cyrptocoin_portfolio/utils/dbhelper.dart';
import 'package:simple_cyrptocoin_portfolio/utils/session.dart';
import 'package:simple_cyrptocoin_portfolio/views/loadingscreen.dart';
import 'package:simple_cyrptocoin_portfolio/views/networkimage.dart';
import 'package:simple_cyrptocoin_portfolio/views/popular.dart';
import 'package:simple_cyrptocoin_portfolio/views/searchpage.dart';
import 'package:provider/provider.dart';
import 'package:simple_cyrptocoin_portfolio/utils/http.dart';

class MainPageLoader extends StatelessWidget {
  const MainPageLoader({super.key});

  Future<(Coins, DateTime)> _loadData() async {
    final coins = await DBHelper().query("user_totals");
    var coinsTemp = coins.map((e) => Coin(
        coinId: e["coin_id"],
        name: e["coin_name"],
        price: e["price"],
        total: e["total"],
        imageUrl: e["image_url"]));
    if (await SessionManager.isLate()) {
      await SessionManager.setLastUpdate();
    }
    DateTime time = await SessionManager.getLastUpdate();
    return (Coins(coins: coinsTemp.toSet()), time);
  }

  @override
  Widget build(BuildContext context) {
    return FutureProvider<(Coins, DateTime)?>(
        create: (_) => _loadData(), initialData: null, child: const MainPage());
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TextEditingController search = TextEditingController();
  Coins? coinsModel;
  DateTime? lastUpdate;

  late (Coins, DateTime)? temp;

  void reload() {
    super.setState(() {});
  }

  void changeAmount(Coin coin, double total) {
    super.setState(() {
      coin.setTotal(total);
    });
  }

  Future<bool> refreshCoinPrices(Coins coins) async {
    return await HTTPHelper.getCoinPrices(coins);
  }

  Future<void> _changeAmount(BuildContext context, Coin coin) async {
    TextEditingController amount = TextEditingController.fromValue(
        TextEditingValue(text: coin.total.toString()));
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('${coin.name} coins held'),
            content: TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Coin Held"),
            ),
            actions: [
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('Save'),
                onPressed: () {
                  double? temp = double.tryParse(amount.text.toString());
                  if (temp == null) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Center(
                      child: Text("Invalid input, only numbers please."),
                    )));
                    return;
                  }
                  changeAmount(coin, temp);
                  coin.updateEntry();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Future<void> _searchBar(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Search Coins'),
            content: TextField(
              controller: search,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Search"),
            ),
            actions: [
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('Search'),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Dismissible coinWidget(BuildContext context, Coin coin) {
    return Dismissible(
        onDismissed: (direction) async {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 1),
              content: Text("Removed ${coin.name} from your Coins")));
          await coinsModel!.deleteCoin(coin, true);
        },
        key: UniqueKey(),
        child: InkWell(
          hoverColor: Colors.blue[200],
          onTap: () async {
            await _changeAmount(context, coin);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.values.last,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width * .1,
                child: NetworkImageWidget(imageUrl: coin.imageUrl),
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: MediaQuery.sizeOf(context).width * .2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coin.name,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "Price USD: \$${coin.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 15, fontStyle: FontStyle.italic),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.sizeOf(context).width * .4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Holdings: ${coin.total} ${coin.coinID}",
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      "USD Amount: \$${coin.amount.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 15, fontStyle: FontStyle.italic),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    temp = Provider.of<(Coins, DateTime)?>(context);
    if (temp == null) {
      return const LoadingScreen();
    } else {
      coinsModel ??= temp!.$1;
      lastUpdate ??= temp!.$2;
    }
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
          color: Colors.blue[300],
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("Last update on ${SessionManager.formatDateTime(lastUpdate!)}")
          ])),
      appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () async {
                  if (coinsModel!.coins.isEmpty) {
                    snackbarShow(context, "You have no coins to refresh!");
                    return;
                  }
                  if (DateTime.now().difference(lastUpdate!).inSeconds < 60) {
                    snackbarShow(context,
                        "The api is updated every 60 seconds. So if you refresh now no new data will be pulled.");
                    return;
                  }
                  await reloadPage(context, false);
                },
                icon: const Icon(Icons.refresh))
          ],
          title: const Center(
            child: Text("Your CryptoCoins"),
          )),
      drawer: Drawer(
          child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "CryptoApp",
                  style: TextStyle(color: Colors.white, fontSize: 32),
                ),
                Text("Options Menu", style: TextStyle(color: Colors.white))
              ],
            )),
          ),
          ListTile(
            leading: const Icon(Icons.leaderboard),
            title: const Text("Top 50 Coins"),
            onTap: () async {
              int prev = coinsModel!.coins.length;
              Navigator.of(context).pop();
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return PopularCoinsLoader(userCoins: coinsModel!);
                },
              ));
              if (prev != coinsModel!.coins.length) {
                reload();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text("Search Coins"),
            onTap: () async {
              Navigator.of(context).pop();
              int prev = coinsModel!.coins.length;
              await _searchBar(context);
              if (!context.mounted || search.text == "") return;
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return SearchCoinsLoader(
                      userCoins: coinsModel!, search: search.text);
                },
              ));
              search.clear();
              if (prev != coinsModel!.coins.length && context.mounted) {
                await reloadPage(context, true);
              }
            },
          )
        ],
      )),
      body: ListView(
          padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
          children:
              List.from(coinsModel!.coins.map((e) => coinWidget(context, e)))),
    );
  }

  void snackbarShow(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Center(
      child: Text(message),
    )));
  }

  Future<void> reloadPage(BuildContext context, bool cameFromOtherPage) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const LoadingScreen();
      },
    ));
    bool temp = await refreshCoinPrices(coinsModel!);
    if (temp) {
      await SessionManager.setLastUpdate();
      lastUpdate = await SessionManager.getLastUpdate();
      if (!context.mounted) return;
      Navigator.pop(context);
      reload();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Center(
        child: Text(cameFromOtherPage ? "Added Coins" : "Updated Coin Prices."),
      )));
    } else {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Center(
        child: Text("Something went wrong. Please try again in a minute."),
      )));
    }
  }
}
