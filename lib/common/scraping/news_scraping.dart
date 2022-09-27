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

  document.getElementsByClassName("contents-display-flex").forEach((element) {
    print(element.text);
  });

  return result;
}
