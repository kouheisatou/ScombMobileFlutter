import 'package:scomb_mobile/common/db/class_cell.dart';

import 'db/task.dart';

const SCOMBZ_DOMAIN = "https://scombz.shibaura-it.ac.jp";
const SCOMB_LOGIN_PAGE_URL =
    "https://scombz.shibaura-it.ac.jp/saml/login?idp=http://adfs.sic.shibaura-it.ac.jp/adfs/services/trust";
const SCOMB_HOME_URL = "https://scombz.shibaura-it.ac.jp/portal/home";
const SCOMB_LOGGED_OUT_PAGE_URL = "https://scombz.shibaura-it.ac.jp/login";
const SCOMB_TIMETABLE_URL = "https://scombz.shibaura-it.ac.jp/lms/timetable";
const CLASS_PAGE_URL = "https://scombz.shibaura-it.ac.jp/lms/course?idnumber=";
const TASK_LIST_PAGE_URL = "https://scombz.shibaura-it.ac.jp/lms/task";
const SURVEY_LIST_PAGE_URL =
    "https://scombz.shibaura-it.ac.jp/portal/surveys/list";
const SURVEY_PAGE_URL = "https://scombz.shibaura-it.ac.jp/portal/surveys/take";

// ScombのCookieとして保存されているセッションIDのキー
const SESSION_COOKIE_ID = "SESSION";

// Scombに2段階認証が未設定でログインしようとすると出る"2要素認証は無効になっています。"確認画面の"次へ"ボタンのhtmlのid
const TWO_STEP_VERIFICATION_LOGIN_BUTTON_ID = "continueButton";

// サイトのヘッダー要素ID
const HEADER_ELEMENT_ID = "page_head";
// サイトのフッター要素ID
const FOOTER_ELEMENT_ID = "page_foot";

// --------時間割CSS----------
// 時間割のテーブル1行のCSSクラス名
const TIMETABLE_ROW_CSS_CLASS_NM = "div-table-data-row";
// 時間割の1マスのCSSクラス名
const TIMETABLE_CELL_CSS_CLASS_NM = "div-table-cell";
// 時間割のマス内のトップボタンCSSクラス名
const TIMETABLE_CELL_HEADER_CSS_CLASS_NM = "timetable-course-top-btn";
// 時間割のマス内の詳細情報CSSクラス名
const TIMETABLE_CELL_DETAIL_CSS_CLASS_NM = "div-table-cell-detail";
// 教室名のattributeキー
const TIMETABLE_ROOM_ATTR_KEY = "title";

// --------課題一覧ページCSS---------
// 課題1行分のCSS
const TASK_LIST_CSS_CLASS_NM = "result_list_line";
// 課題行の科目名列のCSS
const TASK_LIST_CLASS_CULUMN_CSS_NM = "tasklist-course";
// 課題行の課題タイプ列のCSS
const TASK_LIST_TYPE_CULUMN_CSS_NM = "tasklist-contents";
// 課題行の課題タイトル列のCSS
const TASK_LIST_TITLE_CULUMN_CSS_NM = "tasklist-title";
// 課題行の締切列のCSS
const TASK_LIST_DEADLINE_CULUMN_CSS_NM = "tasklist-deadline";

// --------アンケート一覧ページCSS---------
// アンケート1行分のCSS
const SURVEY_ROW_CSS_NM = "result-list";

class Term {
  static int FIRST = 10;
  static int SECOND = 20;
}

class DayOfWeek {
  static int MONDAY = 0;
  static int TUESDAY = 1;
  static int WEDNESDEY = 2;
  static int THURSDAY = 3;
  static int FRIDAY = 4;
  static int SATURDAY = 5;
  static int SUNDAY = 6;
}

enum TaskType { Task, Test, Survey, Others }

// shared resource
String? sessionId;
String? userName;
List<List<ClassCell?>>? timetable;
List<Task>? taskList;
