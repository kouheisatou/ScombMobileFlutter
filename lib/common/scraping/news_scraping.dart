import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:scomb_mobile/common/db/news_item_model_entity.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';

import '../login_exception.dart';
import '../shared_resource.dart';
import '../values.dart';

Future<List<NewsItemModel>> fetchAllNews() async {
  List<NewsItemModel> result = [];

  var dio = Dio();
  dio.options.baseUrl = NEWS_LIST_PAGE_URL;

  Response? response = await dio.get(
    NEWS_LIST_PAGE_URL,
    options: Options(
      headers: {
        "Cookie": "$SESSION_COOKIE_ID=$sessionId",
      },
    ),
  );

  var document = parse(response.data);
  var currentUrl = "https://${response.realUri.host}${response.realUri.path}";

  if (currentUrl == SCOMB_LOGGED_OUT_PAGE_URL) {
    throw LoginException("セッションIDの有効期限切れ");
  }

  for (var element in document.getElementsByClassName(NEWS_LIST_ITEM_CSS_NM)) {
    try {
      var linkText =
          element.getElementsByClassName(NEWS_LIST_ITEM_TITLE_CSS_NM)[0];
      String title = linkText.text;
      String data1 = linkText.attributes[NEWS_ID_ATTR_NM]!;
      String data2 = linkText.attributes[NEWS_CATEGORY_ATTR_NM]!;
      String category =
          element.getElementsByClassName(NEWS_CATEGORY_CSS_NM)[0].text;
      String domain =
          element.getElementsByClassName(NEWS_DOMAIN_CSS_NM)[0].text;
      String publishTime = element
          .getElementsByClassName(NEWS_PUBLISH_TIME_CSS_NM)[0]
          .children[0]
          .text;

      String tags = "";
      element.getElementsByClassName(NEWS_TAG_CSS_NM).forEach(
        (tag) {
          if (!tag.classes.contains(NEWS_TAG_HIDDEN_CSS_NM)) {
            if (!tags.contains(tag.text)) {
              tags += "${tag.text},";
            }
          }
        },
      );

      var db = await AppDatabase.getDatabase();
      NewsItemModel? oldNews = await db.currentNewsItemModelDao.getNews(data1);

      bool unread = tags.contains("未読");
      if (oldNews != null) {
        unread = oldNews.unread;
      }

      NewsItemModel news = NewsItemModel(
        data1,
        data2,
        title,
        category,
        domain,
        publishTime,
        tags,
        unread,
      );
      print(news);
      result.add(news);

      await db.currentNewsItemModelDao.insertNewsModel(news);
    } catch (e, stackTrace) {
      print(e);
    }
  }

  return result;
}
