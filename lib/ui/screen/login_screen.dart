import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/db/setting_entity.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/ui/scomb_mobile.dart';

import '../../common/shared_resource.dart';
import '../../common/values.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen(this.parent, {Key? key}) : super(key: key);

  ScombMobileState parent;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  InAppWebViewController? webView;
  bool loggingIn = false;
  int requestSendCount = 0;
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> setUserAndPass() async {
    var db = await AppDatabase.getDatabase();
    var usernameSetting =
        await db.currentSettingDao.getSetting(SettingKeys.USERNAME);
    var passwordSetting =
        await db.currentSettingDao.getSetting(SettingKeys.PASSWORD);
    var savedSessionID =
        await db.currentSettingDao.getSetting(SettingKeys.SESSION_ID);

    _userController.text = usernameSetting?.settingValue ?? "";
    _passwordController.text = passwordSetting?.settingValue ?? "";

    if (usernameSetting != null &&
        passwordSetting != null &&
        savedSessionID != null) {
      // auto start login process
      startLogin();
    }
  }

  @override
  void initState() {
    setUserAndPass();
    super.initState();
  }

  void startLogin() {
    print(
        "login : user=${_userController.text}, pass=${genHiddenText(_passwordController.text)}");
    CookieManager cookieManager = CookieManager.instance();
    cookieManager.deleteAllCookies();
    webView?.loadUrl(
      urlRequest: URLRequest(url: Uri.parse(SCOMB_LOGIN_PAGE_URL)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          ),
          TextField(
            decoration: const InputDecoration(labelText: "パスワード"),
            obscureText: true,
            controller: _passwordController,
          ),
          ElevatedButton(
            onPressed: loggingIn ? null : startLogin,
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
                  if (code == -2) {
                    Fluttertoast.showToast(msg: "オフライン");
                  } else if (code == -999) {
                    Fluttertoast.showToast(msg: "ログイン失敗");
                  } else {
                    Fluttertoast.showToast(msg: "ERROR : $message ($code)");
                  }
                  widget.parent.setBottomNavIndex(0);
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    loggingIn = true;
                  });
                },
                onLoadStop: (controller, url) async {
                  CookieManager cookieManager = CookieManager.instance();
                  Cookie? cookie = await cookieManager.getCookie(
                    url: Uri.parse(SCOMBZ_DOMAIN),
                    name: SESSION_COOKIE_ID,
                  );

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
                      db.currentSettingDao.insertSetting(Setting(
                        SettingKeys.PASSWORD,
                        _passwordController.text,
                      ));
                      db.currentSettingDao.insertSetting(Setting(
                        SettingKeys.USERNAME,
                        _userController.text,
                      ));

                      // set bottom navigation timetable
                      widget.parent.setBottomNavIndex(0);
                    }
                  }
                },
                onReceivedHttpAuthRequest: (controller, challenge) async {
                  // login failed
                  if (requestSendCount > 0) {
                    webView?.stopLoading();
                    setState(() {
                      loggingIn = false;
                    });
                  }
                  requestSendCount++;
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
