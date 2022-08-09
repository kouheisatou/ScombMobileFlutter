import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/ui/scomb_mobile.dart';

import '../../common/values.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen(this.parent, {Key? key}) : super(key: key);

  ScombMobileState parent;
  String username = "";
  String password = "";
  InAppWebViewController? webView;

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
            onChanged: (text) {
              username = text;
            },
          ),
          TextField(
            decoration: const InputDecoration(labelText: "パスワード"),
            obscureText: true,
            onChanged: (text) {
              password = text;
            },
          ),
          ElevatedButton(
            onPressed: () {
              print("login : user=$username, pass=$password");
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
                  parent.setIndex(0);
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
                  }
                  // login succeeded
                  else {
                    sessionId = cookie.value;
                    print("session_id=$sessionId");
                    // set bottom navigation timetable
                    parent.setIndex(0);
                    parent.fetchData();
                  }
                },
                onReceivedHttpAuthRequest: (controller, challenge) async {
                  return HttpAuthResponse(
                    username: username,
                    password: password,
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
