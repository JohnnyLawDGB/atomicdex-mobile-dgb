import 'package:flutter/material.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/screens/feed/news/build_news_item.dart';
import 'package:provider/provider.dart';

class NewsTab extends StatefulWidget {
  @override
  _NewsTabState createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  FeedProvider _feedProvider;
  List<NewsItem> _news;

  @override
  Widget build(BuildContext context) {
    _feedProvider = Provider.of<FeedProvider>(context);
    _news = _feedProvider.getNews();

    if (_news == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_news.isEmpty) {
      return const Center(
          child: Text(
        'Nothing here', // TODO(yurii): localization
        style: TextStyle(fontSize: 13),
      ));
    }

    return Container(
      child: ListView.builder(
          padding: const EdgeInsets.only(top: 12, bottom: 12),
          itemCount: _news.length,
          itemBuilder: (BuildContext context, int i) {
            return Column(
              children: <Widget>[
                BuildNewsItem(_news[i]),
                if (i + 1 < _news.length)
                  Divider(
                    endIndent: 12,
                    indent: 12,
                    color: Theme.of(context).disabledColor,
                  ),
              ],
            );
          }),
    );
  }
}
