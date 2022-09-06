import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  String? errorMsg;
  bool loading = false;
  late InAppWebViewController webView;

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  onWebViewCreated: (controller) {
                    webView = controller;
                    setState(() {
                      loading = true;
                    });
                  },
                  initialUrlRequest: URLRequest(
                    url: widget.initUrl,
                    headers: {"Cookie": "$SESSION_COOKIE_ID=$sessionId"},
                  ),
                  onLoadError: (controller, url, code, msg) {
                    setState(() {
                      errorMsg =
                          "[ロードエラー]\n\n\n・学内ネットからのみアクセス可能なページの可能性があります。\n\n・カスタマイズしたシラバスのURLが間違えている可能性があります。";
                      loading = false;
                    });
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
                        try {
                          controller.loadUrl(
                            urlRequest: URLRequest(url: widget.initUrl),
                          );
                        } catch (e) {
                          print(e);
                        }
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
                  visible: (errorMsg != null || loading),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white,
                  ),
                ),
                Visibility(
                  visible: loading,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                Visibility(
                  visible: errorMsg != null,
                  child: Center(
                    child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(errorMsg ?? ""),
                            const Divider(
                              height: 20,
                              color: Colors.transparent,
                            ),
                            OutlinedButton(
                              onPressed: () {
                                errorMsg = null;
                                try {
                                  webView.loadUrl(
                                    urlRequest: URLRequest(url: widget.initUrl),
                                  );
                                } catch (e) {
                                  print(e);
                                }
                              },
                              child: const Text("初期ページに戻る"),
                            )
                          ],
                        )),
                  ),
                )
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      errorMsg = null;
                      var canGoBack = await webView.canGoBack();
                      if (canGoBack) {
                        await webView.goBack();
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  IconButton(
                    onPressed: () async {
                      errorMsg = null;
                      var canGoForward = await webView.canGoForward();
                      if (canGoForward) {
                        await webView.goForward();
                      }
                    },
                    icon: const Icon(Icons.arrow_forward),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkResponse(
                      borderRadius: BorderRadius.circular(1000),
                      onTap: () async {
                        final data = ClipboardData(text: currentUrl.toString());
                        await Clipboard.setData(data);
                        Fluttertoast.showToast(msg: "URLをクリップボードにコピーしました");
                      },
                      child: Column(
                        children: const [
                          Icon(Icons.copy),
                          Text(
                            "URLをコピー",
                            style: TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkResponse(
                      onTap: () async {
                        if (await canLaunchUrl(currentUrl)) {
                          await launchUrl(
                            currentUrl,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: Column(
                        children: const [
                          Icon(Icons.open_in_new),
                          Text(
                            "ブラウザで開く",
                            style: TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              )
            ],
          )
        ],
      ),
    );
  }
}
