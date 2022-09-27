import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/scraping/news_scraping.dart';
import 'package:scomb_mobile/ui/screen/network_screen.dart';

import '../../common/db/news_item_model_entity.dart';

class NewsScreen extends NetworkScreen {
  NewsScreen(super.title, {Key? key}) : super(key: key);

  List<NewsItemModel> news = [];

  @override
  NetworkScreenState<NewsScreen> createState() => NewsScreenState();
}

class NewsScreenState extends NetworkScreenState<NewsScreen> {
  @override
  Future<void> getDataOffLine() {
    // TODO: implement getDataOffLine
    throw UnimplementedError();
  }

  @override
  Future<void> getFromServerAndSaveToSharedResource(
      String savedSessionId) async {
    widget.news = await fetchAllNews();
  }

  @override
  Widget innerBuild() {
    return ListView(
      children: [
        Text(widget.news.toString()),
      ],
    );
  }

  @override
  Future<void> refreshData() async {
    widget.news = await fetchAllNews();
  }
}
