import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:scomb_mobile/common/values.dart';

class TestApp extends StatefulWidget {
  TestApp({Key? key}) : super(key: key);

  @override
  _TestAppState createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: InAppWebViewPage());
  }
}

class InAppWebViewPage extends StatefulWidget {
  const InAppWebViewPage({Key? key}) : super(key: key);

  @override
  _InAppWebViewPageState createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  late InAppWebViewController webView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BasicAuthWebView")),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(SCOMB_LOGIN_PAGE_URL)),
        onWebViewCreated: (InAppWebViewController controller) {
          webView = controller;
        },
        onLoadStart: (controller, url) {},
        onLoadStop: (controller, url) {},
        onReceivedHttpAuthRequest: (controller, challenge) async {
          return HttpAuthResponse(
              username: "USERNAME",
              password: "PASSWORD",
              action: HttpAuthResponseAction.PROCEED);
        },
      ),
    );
  }
}
