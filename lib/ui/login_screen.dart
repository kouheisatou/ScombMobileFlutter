import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/db/setting_entity.dart';
import 'package:scomb_mobile/ui/scomb_mobile.dart';

import '../common/values.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen(this.parent, {Key? key}) : super(key: key);

  ScombMobileState parent;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  InAppWebViewController? webView;
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    setUserAndPass();
    super.initState();
  }

  Future<void> setUserAndPass() async {
    var db = await AppDatabase.getDatabase();
    var usernameSetting =
        await db.currentSettingDao.getSetting(SettingKeys.USERNAME);
    var passwordSetting =
        await db.currentSettingDao.getSetting(SettingKeys.PASSWORD);

    _userController.text = usernameSetting?.settingValue ?? "";
    _passwordController.text = passwordSetting?.settingValue ?? "";
  }

  @override
  Widget build(BuildContext context) {
    setUserAndPass();
    return Scaffold(
      appBar: AppBar(
        title: const Text("ログイン"),
      ),
      body: Column(
        children: [
          TextField(
            autofocus: true,
            decoration: const InputDecoration(labelText: "学籍番号"),
            controller: _userController,
            onChanged: (text) async {
              var db = await AppDatabase.getDatabase();
              db.currentSettingDao
                  .insertSetting(Setting(SettingKeys.USERNAME, text));
            },
          ),
          TextField(
            decoration: const InputDecoration(labelText: "パスワード"),
            obscureText: true,
            controller: _passwordController,
            onChanged: (text) async {
              var db = await AppDatabase.getDatabase();
              db.currentSettingDao
                  .insertSetting(Setting(SettingKeys.PASSWORD, text));
            },
          ),
          ElevatedButton(
            onPressed: () {
              print(
                  "login : user=${_userController.text}, pass=${_passwordController.text}");
              CookieManager cookieManager = CookieManager.instance();
              cookieManager.deleteAllCookies();
              webView?.loadUrl(
                urlRequest: URLRequest(url: Uri.parse(SCOMB_LOGIN_PAGE_URL)),
              );
            },
            child: const Text("ログイン"),
          ),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              height: 0,
              // visible: true,
              child: InAppWebView(
                onWebViewCreated: (InAppWebViewController controller) {
                  webView = controller;
                },
                onLoadError: (controller, url, code, message) {
                  Fluttertoast.showToast(msg: "ERROR : $message");
                  widget.parent.setBottomNavIndex(0);
                },
                onLoadStop: (controller, url) async {
                  CookieManager cookieManager = CookieManager.instance();
                  Cookie? cookie = await cookieManager.getCookie(
                    url: Uri.parse(SCOMBZ_DOMAIN),
                    name: SESSION_COOKIE_ID,
                  );

                  var currentUrl = "https://${url?.host}${url?.path}";
                  // login failed
                  if (currentUrl == SCOMB_LOGGED_OUT_PAGE_URL) {
                    initState();
                  }

                  // two step auth page
                  if (cookie == null) {
                    // skip twp step auth
                    await webView?.evaluateJavascript(
                      source:
                          "document.getElementById('$TWO_STEP_VERIFICATION_LOGIN_BUTTON_ID').click();",
                    );
                  } else {
                    sessionId = cookie.value;

                    // login succeeded
                    if (sessionId != null) {
                      print("session_id=$sessionId");

                      // save session_id to db
                      var db = await AppDatabase.getDatabase();
                      db.currentSettingDao.insertSetting(
                          Setting(SettingKeys.SESSION_ID, sessionId!));

                      // set bottom navigation timetable
                      widget.parent.setBottomNavIndex(0);
                    }
                    // login failed
                    else {
                      initState();
                    }
                  }
                },
                onReceivedHttpAuthRequest: (controller, challenge) async {
                  return HttpAuthResponse(
                    username: _userController.text,
                    password: _passwordController.text,
                    action: HttpAuthResponseAction.PROCEED,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
