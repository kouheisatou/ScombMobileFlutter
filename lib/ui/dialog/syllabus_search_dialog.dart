import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/ui/dialog/selector_dialog.dart';

import '../../common/db/scomb_mobile_database.dart';
import '../../common/db/setting_entity.dart';
import '../../common/scraping/syllabus_scraping.dart';
import '../../common/shared_resource.dart';
import '../../common/utils.dart';
import '../../common/values.dart';

typedef InputUrlManuallyCallback = Future<String?> Function();

Future<String?> showSyllabusSearchResultDialog(
  BuildContext context,
  String? searchString,
  InputUrlManuallyCallback? inputUrlManually,
) async {
  String? syllabusUrl;
  var db = await AppDatabase.getDatabase();

  // recover section setting from db
  var section = (await db.currentSettingDao.getSetting(SettingKeys.Section))
      ?.settingValue;
  if (section == null) {
    Fluttertoast.showToast(msg: "設定で学部を設定してください");
  }

  // encode url query
  var queryString = await convertUrlQueryString(
    searchString?.replaceAll(RegExp("[１-９Ａ-Ｚ1-9]"), "") ?? "",
    encode: "EUC-JP",
  );

  // construct syllabus url
  var syllabusResultUrl = SYLLABUS_SEARCH_URL
      .replaceFirst("\${className}", queryString)
      .replaceFirst("\${admissionYearAndSection}", "$timetableYear%2F$section");

  // syllabus search result
  var results = await fetchAllSyllabusSearchResult(
    syllabusResultUrl,
  );
  if (inputUrlManually != null) {
    results["[ URLを直接入力する ]"] = "";
  }

  // select same name class
  bool noMatch = true;
  results.forEach((key, value) {
    if (key == searchString) {
      syllabusUrl = value;
      noMatch = false;
    }
  });

  // no matched name
  if (noMatch) {
    String? dialogResponse = await showDialog(
      context: context,
      builder: (_) {
        return SelectorDialog<String>(
          results,
          (key, value) async {},
          description: "複数の検索結果が見つかりました",
        );
      },
    );

    if (dialogResponse == null) {
      return null;
    } else if (dialogResponse == "[ URLを直接入力する ]") {
      if (inputUrlManually != null) {
        syllabusUrl = await inputUrlManually();
      }
    } else {
      syllabusUrl = results[dialogResponse] ?? "";
    }
  }

  return syllabusUrl;
}
