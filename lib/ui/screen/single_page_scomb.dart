import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/ui/screen/network_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/shared_resource.dart';
import '../../common/values.dart';

class SinglePageScomb extends NetworkScreen {
  SinglePageScomb(this.initUrl, String title, {this.javascript}) : super(title);

  Uri initUrl;
  String? javascript;

  @override
  NetworkScreenState<SinglePageScomb> createState() => SinglePageScombState();
}

class SinglePageScombState extends NetworkScreenState<SinglePageScomb> {
  late Uri currentUrl = widget.initUrl;
  bool error = false;
  InAppWebViewController? webView;

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
      body: InAppWebView(
        onWebViewCreated: (controller) {
          webView = controller;
          getFromServerAndSaveToSharedResource("");
        },
        onLoadError: (controller, url, code, msg) {
          Fluttertoast.showToast(msg: "ロードエラー\n学内ネットからのみアクセス可能なページの可能性があります");
          if (!error) {
            controller.loadUrl(urlRequest: URLRequest(url: widget.initUrl));
            print("error_code : $code");
            print("error_msg : $msg");
            error = true;
          }
        },
        onLoadStop: (controller, currentUrl) async {
          this.currentUrl = currentUrl ?? widget.initUrl;
          await controller.evaluateJavascript(
            source: "document.getElementById('$HEADER_ELEMENT_ID').remove();",
          );
          await controller.evaluateJavascript(
            source: "document.getElementById('$FOOTER_ELEMENT_ID').remove();",
          );
          if (widget.javascript != null) {
            await controller.evaluateJavascript(
              source: widget.javascript!,
            );
          }
        },
      ),
    );
  }

  @override
  Future<void> getDataOffLine() async {}

  @override
  Future<void> getFromServerAndSaveToSharedResource(
      String savedSessionId) async {
    webView?.loadUrl(
      urlRequest: URLRequest(
        url: widget.initUrl,
        headers: {
          "Cookie": "$SESSION_COOKIE_ID=$sessionId",
        },
      ),
    );
  }

  @override
  Future<void> refreshData() async {}

  @override
  Widget innerBuild() {
    return const Text("");
  }
}
