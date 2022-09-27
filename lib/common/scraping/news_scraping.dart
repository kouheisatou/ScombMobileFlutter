import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:scomb_mobile/common/db/news_item_model_entity.dart';

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

  document.getElementsByClassName(NEWS_LIST_ITEM_CSS_NM).forEach((element) {
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

      Set<String> tags = {};
      element.getElementsByClassName(NEWS_TAG_CSS_NM).forEach(
        (tag) {
          if (!tag.classes.contains(NEWS_TAG_HIDDEN_CSS_NM)) {
            tags.add(tag.text);
          }
        },
      );

      NewsItemModel news = NewsItemModel(
        data1,
        data2,
        title,
        category,
        domain,
        publishTime,
        tags,
      );
      print(news);
      result.add(news);
    } catch (e, stackTrace) {
      print(e);
    }
  });

  return result;
}
