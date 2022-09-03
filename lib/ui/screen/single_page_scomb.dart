import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/ui/dialog/loading_dialog.dart';
import 'package:scomb_mobile/ui/screen/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/shared_resource.dart';
import '../../common/values.dart';

class SinglePageScomb extends StatelessWidget {
  SinglePageScomb(this.initUrl, this.title, {Key? key, this.javascript})
      : super(key: key);

  Uri initUrl;
  String title;
  String? javascript;
  late Uri currentUrl = initUrl;
  bool error = false;

  var loadingDialog = LoadingDialog();

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              if (await canLaunchUrl(currentUrl)) {
                await launchUrl(
                  currentUrl,
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            icon: const Icon(Icons.open_in_new),
          )
        ],
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: InAppWebView(
        onWebViewCreated: (controller) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) {
              return loadingDialog;
            },
          );
        },
        initialUrlRequest: URLRequest(
          url: initUrl,
          headers: {"Cookie": "$SESSION_COOKIE_ID=$sessionId"},
        ),
        onLoadError: (controller, url, code, msg) {
          Fluttertoast.showToast(msg: "ロードエラー\n学内ネットからのみアクセス可能なページの可能性があります");
          if (!error) {
            controller.loadUrl(urlRequest: URLRequest(url: initUrl));
            print("error_code : $code");
            print("error_msg : $msg");
            error = true;
          }
        },
        onLoadStop: (controller, currentUrl) async {
          if (currentUrl != null) {
            var currentUrlString =
                "https://${currentUrl.host}${currentUrl.path}";
            if (currentUrlString == SCOMB_LOGGED_OUT_PAGE_URL) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) {
                    return LoginScreen();
                  },
                  fullscreenDialog: true,
                ),
              );
              controller.loadUrl(urlRequest: URLRequest(url: initUrl));
            }
          }

          this.currentUrl = currentUrl ?? initUrl;
          await controller.evaluateJavascript(
            source: "document.getElementById('$HEADER_ELEMENT_ID').remove();",
          );
          await controller.evaluateJavascript(
            source: "document.getElementById('$FOOTER_ELEMENT_ID').remove();",
          );
          if (javascript != null) {
            await controller.evaluateJavascript(
              source: javascript!,
            );
          }
          if (loadingDialog.isLoading) {
            loadingDialog.close();
          }
        },
      ),
    );
  }
}
