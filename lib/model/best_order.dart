import 'package:komodo_dex/model/get_best_orders.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:rational/rational.dart';

import 'package:komodo_dex/model/error_string.dart';

class BestOrders {
  BestOrders({this.result, this.error, this.request});

  factory BestOrders.fromJson(Map<String, dynamic> json) {
    final BestOrders bestOrders = BestOrders(request: json['request']);
    if (json['result'] == null) return bestOrders;

    final MarketAction action = bestOrders.request.action;

    json['result'].forEach((String ticker, dynamic items) {
      bestOrders.result ??= {};
      final List<BestOrder> list = [];
      for (dynamic item in items) {
        item['action'] = action;
        item['other_coin'] =
            action == MarketAction.SELL ? bestOrders.request.coin : ticker;
        list.add(BestOrder.fromJson(item));
      }
      bestOrders.result[ticker] = list;
    });

    return bestOrders;
  }

  Map<String, List<BestOrder>> result;
  ErrorString error;
  GetBestOrders request;
}

class BestOrder {
  BestOrder({
    this.price,
    this.coin,
    this.otherCoin,
    this.action,
  });

  factory BestOrder.fromJson(Map<String, dynamic> json) {
    return BestOrder(
      price: fract2rat(json['price_fraction']),
      coin: json['coin'],
      otherCoin: json['other_coin'],
      action: json['action'],
    );
  }

  Rational price;
  String coin;
  String otherCoin;
  MarketAction action;
}
