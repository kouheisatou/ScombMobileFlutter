import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../common/values.dart';

class SinglePageScomb extends StatelessWidget {
  SinglePageScomb(this.url, this.title, {Key? key}) : super(key: key);

  String url = "";
  String title = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse(url),
          headers: {
            "Cookie": "$SESSION_COOKIE_ID=$sessionId",
          },
        ),
        onLoadStop: (controller, currentUrl) async {
          await controller.evaluateJavascript(
            source: "document.getElementById('$HEADER_ELEMENT_ID').remove();",
          );
          await controller.evaluateJavascript(
            source: "document.getElementById('$FOOTER_ELEMENT_ID').remove();",
          );

          // on load diff page
          // if ("${currentUrl?.host}${currentUrl?.path}" != url) {
          //   if (await canLaunchUrl(Uri.parse(url))) {
          //     await launchUrl(Uri.parse(url));
          //   }
          // }
        },
      ),
    );
  }
}
