import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/portfolio/activate/build_item_coin.dart';
import 'package:komodo_dex/screens/portfolio/activate/build_type_header.dart';
import 'package:komodo_dex/screens/portfolio/activate/search_filter.dart';
import 'package:komodo_dex/screens/portfolio/loading_coin.dart';
import 'package:komodo_dex/widgets/custom_simple_dialog.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'build_selected_coins.dart';

class SelectCoinsPage extends StatefulWidget {
  const SelectCoinsPage({this.coinsToActivate});

  final Function(List<Coin>) coinsToActivate;

  @override
  _SelectCoinsPageState createState() => _SelectCoinsPageState();
}

class _SelectCoinsPageState extends State<SelectCoinsPage> {
  bool _isDone = false;
  StreamSubscription<bool> _listenerClosePage;
  StreamSubscription<List<CoinToActivate>> _listenerCoinsActivated;
  List<Coin> _currentCoins = <Coin>[];
  List<Widget> _listViewItems = <Widget>[];
  List<CoinToActivate> _coinsToActivate = [];

  @override
  void initState() {
    coinsBloc.setCloseViewSelectCoin(false);
    _listenerClosePage =
        coinsBloc.outCloseViewSelectCoin.listen((dynamic onData) {
      if (onData != null && onData == true && mounted) {
        Navigator.of(context).pop();
      }
    });
    coinsBloc.initCoinBeforeActivation().then((_) {
      _initCoinList();
    });

    _listenerCoinsActivated = coinsBloc.outCoinBeforeActivation.listen((data) {
      setState(() {
        _coinsToActivate = data.where((element) => element.isActive).toList();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _listenerClosePage.cancel();
    _listenerCoinsActivated.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LockScreen(
      context: context,
      child: Scaffold(
          appBar: AppBar(
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            title: SearchFieldFilterCoin(
              clear: () => _initCoinList(),
              onFilterCoins: (List<Coin> coinsFiltered) {
                setState(() {
                  _currentCoins = coinsFiltered;
                  _listViewItems = _buildListView();
                });
              },
            ),
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(Icons.close),
                  splashRadius: 24,
                  onPressed: () => Navigator.of(context).pop(),
                );
              },
            ),
            titleSpacing: 0,
          ),
          body: StreamBuilder<CoinToActivate>(
              initialData: coinsBloc.currentActiveCoin,
              stream: coinsBloc.outcurrentActiveCoin,
              builder: (BuildContext context,
                  AsyncSnapshot<CoinToActivate> snapshot) {
                if (snapshot.data != null) {
                  return LoadingCoin();
                } else {
                  return _isDone
                      ? LoadingCoin()
                      : Column(
                          children: [
                            if (_coinsToActivate.isNotEmpty)
                              BuildSelectedCoins(_coinsToActivate),
                            Expanded(
                              child: Scrollbar(
                                child: ListView.builder(
                                  itemCount: _listViewItems.length,
                                  itemBuilder: (BuildContext context, int i) =>
                                      _listViewItems[i],
                                ),
                              ),
                            ),
                            _buildDoneButton(),
                          ],
                        );
                }
              })),
    );
  }

  void _initCoinList() {
    setState(() {
      for (CoinToActivate coinToActivate in coinsBloc.coinBeforeActivation) {
        _currentCoins
            .removeWhere((Coin coin) => coin.abbr == coinToActivate.coin.abbr);
        _currentCoins.add(coinToActivate.coin);
      }
      _listViewItems = _buildListView();
    });
  }

  List<Widget> _buildListView() {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          AppLocalizations.of(context).selectCoinInfo,
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Theme.of(context).colorScheme.onBackground),
        ),
      ),
      const SizedBox(
        height: 8,
      ),
      ..._buildCoinListItems(),
    ];
  }

  List<Widget> _buildCoinListItems() {
    if (_currentCoins.isEmpty) {
      return [
        Center(
          child: Text(
            AppLocalizations.of(context).noCoinFound,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        )
      ];
    }

    final List<Widget> list = <Widget>[];
    final Map<String, List<Coin>> coinsMap = <String, List<Coin>>{};

    for (Coin c in _currentCoins) {
      if (c.testCoin) continue;
      if (!coinsMap.containsKey(c.type.name)) {
        coinsMap.putIfAbsent(c.type.name, () => [c]);
      } else {
        coinsMap[c.type.name].add(c);
      }
    }

    final List<String> sortedTypes = coinsMap.keys.toList()
      ..sort((String a, String b) => b.compareTo(a));

    for (String type in sortedTypes) {
      list.add(BuildTypeHeader(
        type: type,
      ));
      for (Coin coin in coinsMap[type]) {
        list.add(BuildItemCoin(
          key: Key('coin-activate-${coin.abbr}'),
          coin: coin,
        ));
      }
    }

    final List<Coin> testCoins = _currentCoins
        .where((Coin c) =>
            (c.testCoin && settingsBloc.enableTestCoins) ||
            appConfig.defaultTestCoins.contains(c.abbr))
        .toList();
    if (testCoins.isNotEmpty) {
      list.add(BuildTypeHeader(
        type: null,
      ));

      for (Coin testCoin in testCoins) {
        list.add(BuildItemCoin(
          key: Key('coin-activate-${testCoin.abbr}'),
          coin: testCoin,
        ));
      }
    }

    return list;
  }

  Widget _buildDoneButton() {
    return SizedBox(
      height: 60,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StreamBuilder<List<CoinToActivate>>(
              initialData: coinsBloc.coinBeforeActivation,
              stream: coinsBloc.outCoinBeforeActivation,
              builder: (BuildContext context,
                  AsyncSnapshot<List<CoinToActivate>> snapshot) {
                bool isButtonActive = false;
                if (snapshot.hasData) {
                  for (CoinToActivate coinToActivate in snapshot.data) {
                    if (coinToActivate.isActive) {
                      isButtonActive = true;
                    }
                  }
                }
                return PrimaryButton(
                  key: const Key('done-activate-coins'),
                  text: AppLocalizations.of(context).done,
                  isLoading: _isDone,
                  onPressed: isButtonActive ? _pressDoneButton : null,
                );
              }),
        ),
      ),
    );
  }

  void _pressDoneButton() {
    final numCoinsEnabled = coinsBloc.coinBalance.length;
    final numCoinsTryingEnable =
        coinsBloc.coinBeforeActivation.where((c) => c.isActive).toList().length;
    final maxCoinPerPlatform = Platform.isAndroid
        ? appConfig.maxCoinsEnabledAndroid
        : appConfig.maxCoinEnabledIOS;
    if (numCoinsEnabled + numCoinsTryingEnable > maxCoinPerPlatform) {
      dialogBloc.closeDialog(context);
      dialogBloc.dialog = showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return CustomSimpleDialog(
            title:
                Text(AppLocalizations.of(context).enablingTooManyAssetsTitle),
            children: [
              Text(AppLocalizations.of(context).enablingTooManyAssetsSpan1 +
                  numCoinsEnabled.toString() +
                  AppLocalizations.of(context).enablingTooManyAssetsSpan2 +
                  numCoinsTryingEnable.toString() +
                  AppLocalizations.of(context).enablingTooManyAssetsSpan3 +
                  maxCoinPerPlatform.toString() +
                  AppLocalizations.of(context).enablingTooManyAssetsSpan4),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => dialogBloc.closeDialog(context),
                    child: Text(AppLocalizations.of(context).warningOkBtn),
                  ),
                ],
              ),
            ],
          );
        },
      ).then((dynamic _) => dialogBloc.dialog = null);
    } else {
      setState(() => _isDone = true);
      coinsBloc.activateCoinsSelected();
    }
  }
}
