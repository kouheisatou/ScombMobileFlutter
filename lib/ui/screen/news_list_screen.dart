import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/scraping/news_scraping.dart';
import 'package:scomb_mobile/common/values.dart';
import 'package:scomb_mobile/ui/screen/network_screen.dart';
import 'package:scomb_mobile/ui/screen/single_page_scomb.dart';

import '../../common/db/news_item_model_entity.dart';

class NewsScreen extends NetworkScreen {
  NewsScreen(super.title, {Key? key}) : super(key: key);

  List<NewsItemModel> news = [];

  @override
  NetworkScreenState<NewsScreen> createState() => NewsScreenState();
}

class NewsScreenState extends NetworkScreenState<NewsScreen> {
  @override
  Future<void> getDataOffLine() async {}

  @override
  Future<void> getFromServerAndSaveToSharedResource(savedSessionId) async {
    isLoading = true;
    widget.news = await fetchAllNews();
    isLoading = false;
  }

  @override
  Widget innerBuild() {
    return RefreshIndicator(
      onRefresh: refreshData,
      child: ListView.separated(
        itemCount: widget.news.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SinglePageScomb(
                    Uri.parse(NEWS_LIST_PAGE_URL),
                    widget.news[index].title,
                    javascript:
                        "detailPortalInfo('${widget.news[index].newsId}', '${widget.news[index].data2}')",
                  ),
                  fullscreenDialog: true,
                ),
              );
            },
            title: Text(widget.news[index].title),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(widget.news[index].category),
                Text(widget.news[index].domain),
                Text(widget.news[index].publishTime),
                Text(widget.news[index].tags.toString()),
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
      ),
    );
  }

  @override
  Future<void> refreshData() async {
    isLoading = true;
    widget.news = await fetchAllNews();
    isLoading = false;
  }
}
