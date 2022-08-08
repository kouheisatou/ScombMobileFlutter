import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../values.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  String sessionId = "not init yet";
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
            child: Text("ログイン"),
          ),
          Expanded(
            child: Visibility(
              visible: false,
              child: InAppWebView(
                onWebViewCreated: (InAppWebViewController controller) {
                  webView = controller;
                },
                onLoadStart: (controller, url) {},
                onLoadStop: (controller, url) async {
                  CookieManager cookieManager = CookieManager.instance();
                  Cookie? cookie = await cookieManager.getCookie(
                    url: Uri.parse(SCOMBZ_DOMAIN),
                    name: SESSION_COOKIE_ID,
                  );
                  sessionId = cookie?.value;
                  print(sessionId);
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
