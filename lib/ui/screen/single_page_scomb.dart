import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/shared_resource.dart';
import '../../common/values.dart';

class SinglePageScomb extends StatelessWidget {
  SinglePageScomb(this.initUrl, this.title, {this.javascript});

  Uri initUrl;
  late Uri currentUrl = initUrl;
  String title = "";
  String? javascript;

  @override
  Widget build(BuildContext context) {
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
        initialUrlRequest: URLRequest(
          url: initUrl,
          headers: {
            "Cookie": "$SESSION_COOKIE_ID=$sessionId",
          },
        ),
        onLoadError: (controller, url, code, msg) {
          Fluttertoast.showToast(msg: "ロードエラー\n学内ネットからのみアクセス可能なページの可能性があります");
          controller.loadUrl(urlRequest: URLRequest(url: initUrl));
        },
        onLoadStop: (controller, currentUrl) async {
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
        },
      ),
    );
  }
}
