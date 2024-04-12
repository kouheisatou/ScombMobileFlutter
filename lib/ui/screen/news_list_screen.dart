import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scomb_mobile/common/scraping/news_scraping.dart';
import 'package:scomb_mobile/common/values.dart';
import 'package:scomb_mobile/ui/screen/network_screen.dart';
import 'package:scomb_mobile/ui/screen/single_page_scomb.dart';

import '../../common/db/news_item_model_entity.dart';
import '../../common/db/scomb_mobile_database.dart';

class NewsScreen extends NetworkScreen {
  NewsScreen(super.title, {Key? key}) : super(key: key);

  List<NewsItemModel> news = [];
  bool newsFetched = false;

  @override
  NetworkScreenState<NewsScreen> createState() => NewsScreenState();
}

class NewsScreenState extends NetworkScreenState<NewsScreen> {
  @override
  Future<void> getDataOffLine() async {}

  @override
  Future<void> getFromServerAndSaveToSharedResource(savedSessionId) async {
    if (widget.newsFetched) return;
    isLoading = true;
    widget.news = await fetchAllNews();
    isLoading = false;
    widget.newsFetched = true;
  }

  @override
  Widget innerBuild() {
    return RefreshIndicator(
      onRefresh: refreshData,
      child: ListView.builder(
        itemCount: widget.news.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              InkWell(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SinglePageScomb(
                        Uri.parse(
                          NEWS_DETAIL_PAGE_URL.replaceAll("\${newsId}", widget.news[index].newsId).replaceAll("\${data2}", widget.news[index].data2),
                        ),
                        widget.news[index].title,
                      ),
                      fullscreenDialog: true,
                    ),
                  );

                  // remove unread badge
                  setState(() {
                    widget.news[index].unread = false;
                  });
                  var db = await AppDatabase.getDatabase();
                  await db.currentNewsItemModelDao.insertNewsModel(widget.news[index]);
                },
                onLongPress: () {
                  print(widget.news[index]);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Opacity(
                    opacity: widget.news[index].unread ? 0.4 : 1,
                    child: ListTile(
                      subtitle: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.news[index].domain,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(widget.news[index].publishTime),
                          ],
                        ),
                      ),
                      title: Text(
                        widget.news[index].title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(
                height: 0.5,
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Future<void> refreshData() async {
    widget.newsFetched = false;
    isLoading = true;
    widget.news = await fetchAllNews();
    isLoading = false;
    widget.newsFetched = true;
    setState(() {});
  }
}
