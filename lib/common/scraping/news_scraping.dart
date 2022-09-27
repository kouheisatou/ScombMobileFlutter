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
      var linkText = element.getElementsByClassName("link-txt")[0];
      String title = linkText.text;
      String data1 = linkText.attributes["data1"]!;
      String data2 = linkText.attributes["data2"]!;
      String category = element
          .getElementsByClassName("portal-information-list-type")[0]
          .text;
      String domain = element
          .getElementsByClassName("portal-information-list-division")[0]
          .text;
      String publishTime = element
          .getElementsByClassName("portal-information-list-date")[0]
          .children[0]
          .text;

      Set<String> tags = {};
      element.getElementsByClassName("portal-information-priority").forEach(
        (tag) {
          if (!tag.classes.contains("contents-hidden")) {
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
