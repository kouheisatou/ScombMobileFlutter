import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/shared_resource.dart';
import '../../common/values.dart';

class SinglePageScomb extends StatelessWidget {
  SinglePageScomb(this.url, this.title, {Key? key}) : super(key: key);

  String url = "";
  String title = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            icon: const Icon(Icons.open_in_browser),
          )
        ],
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
        ),
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
        },
      ),
    );
  }
}
