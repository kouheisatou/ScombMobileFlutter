import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../values.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  String sessionId = "not init yet";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sessionId),
      ),
      body: Visibility(
        visible: true,
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(SCOMB_LOGIN_PAGE_URL)),
          onLoadStart: (controller, url) {
            if (url != null) {
              sessionId = url.path;
            }
          },
          onLoadStop: (controller, url) {
            if (url != null) {
              sessionId = url.path;
            }
          },
          onReceivedHttpAuthRequest: (controller, challenge) async {
            return HttpAuthResponse(
                username: "USERNAME",
                password: "PASSWORD",
                action: HttpAuthResponseAction.PROCEED);
          },
        ),
      ),
    );
  }
}
