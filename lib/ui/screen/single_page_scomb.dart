import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/ui/screen/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/shared_resource.dart';
import '../../common/values.dart';

class SinglePageScomb extends StatefulWidget {
  SinglePageScomb(this.initUrl, this.title, {Key? key, this.javascript})
      : super(key: key);

  Uri initUrl;
  String title;
  String? javascript;

  @override
  State<SinglePageScomb> createState() => _SinglePageScombState();
}

class _SinglePageScombState extends State<SinglePageScomb> {
  late Uri currentUrl = widget.initUrl;

  bool error = false;
  bool loading = false;

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
          widget.title,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            onWebViewCreated: (controller) {
              setState(() {
                loading = true;
              });
            },
            initialUrlRequest: URLRequest(
              url: widget.initUrl,
              headers: {"Cookie": "$SESSION_COOKIE_ID=$sessionId"},
            ),
            onLoadError: (controller, url, code, msg) {
              Fluttertoast.showToast(
                  msg: "ロードエラー\n学内ネットからのみアクセス可能なページの可能性があります");
              if (!error) {
                controller.loadUrl(urlRequest: URLRequest(url: widget.initUrl));
                print("error_code : $code");
                print("error_msg : $msg");
                error = true;
              }
              setState(() {
                loading = false;
              });
            },
            onLoadStart: (controller, uri) {
              setState(() {
                loading = true;
              });
            },
            onLoadStop: (controller, currentUrl) async {
              error = false;
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
                  controller.loadUrl(
                      urlRequest: URLRequest(url: widget.initUrl));
                }
              }

              this.currentUrl = currentUrl ?? widget.initUrl;
              await controller.evaluateJavascript(
                source:
                    "document.getElementById('$HEADER_ELEMENT_ID').remove();",
              );
              await controller.evaluateJavascript(
                source:
                    "document.getElementById('$FOOTER_ELEMENT_ID').remove();",
              );
              if (widget.javascript != null) {
                await controller.evaluateJavascript(
                  source: widget.javascript!,
                );
              }
              setState(() {
                loading = false;
              });
            },
          ),
          Visibility(
            visible: loading,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
