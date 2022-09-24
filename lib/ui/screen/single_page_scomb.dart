import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/scraping/syllabus_scraping.dart';
import 'package:scomb_mobile/common/timetable_model.dart';
import 'package:scomb_mobile/ui/dialog/selector_dialog.dart';
import 'package:scomb_mobile/ui/screen/login_screen.dart';
import 'package:scomb_mobile/ui/screen/timetable/my_timetable_list_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/shared_resource.dart';
import '../../common/values.dart';

class SinglePageScomb extends StatefulWidget {
  SinglePageScomb(
    this.initUrl,
    this.title, {
    Key? key,
    this.javascript,
    this.shouldShowAddNewClassButton = false,
    this.shouldRemoveHeader = true,
    this.timetable,
  }) : super(key: key);

  Uri initUrl;
  String title;
  String? javascript;
  bool shouldShowAddNewClassButton;
  bool shouldRemoveHeader;
  TimetableModel? timetable;

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
    var addNewClassButtonAvailable =
        (currentUrl.host == "timetable.sic.shibaura-it.ac.jp" &&
            currentUrl.path.contains("detail") &&
            errorMsg == null);

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
                    if (widget.initUrl.toString() == "") {
                      errorMsg = "URLが設定されていません";
                    }
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
                          "[ロードエラー]\n\n\n・学内ネットからのみアクセス可能なページの可能性があります。\n\n・URLが間違えている可能性があります。";
                      loading = false;
                    });
                  },
                  onLoadStart: (controller, currentUrl) {
                    print(currentUrl.toString());
                  },
                  onLoadStop: (controller, currentUrl) async {
                    // only school local network error handling
                    String? html = await controller.evaluateJavascript(
                      source:
                          "window.document.getElementsByTagName('html')[0].outerHTML;",
                    );
                    if (html?.contains("アクセスしたデータは現在参照できません。") == true) {
                      errorMsg = "学内ネットからのみアクセス可能なページです";
                      loading = false;
                    }

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
                            urlRequest: URLRequest(
                              url: widget.initUrl,
                              headers: {
                                "Cookie": "$SESSION_COOKIE_ID=$sessionId"
                              },
                            ),
                          );
                        } catch (e) {
                          print(e);
                        }
                      }
                    }

                    this.currentUrl = currentUrl ?? widget.initUrl;
                    if (widget.shouldRemoveHeader) {
                      print(
                          "shouldRemoveHeader : ${widget.shouldRemoveHeader}");
                      await controller.evaluateJavascript(
                        source:
                            "document.getElementById('$HEADER_ELEMENT_ID').remove();",
                      );
                      await controller.evaluateJavascript(
                        source:
                            "document.getElementById('$FOOTER_ELEMENT_ID').remove();",
                      );
                    }
                    if (widget.javascript != null) {
                      await controller.evaluateJavascript(
                        source: widget.javascript!,
                      );
                    }
                    setState(() {
                      loading = false;
                    });
                  },
                  onReceivedHttpAuthRequest: (controller, challenge) async {
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
                        urlRequest: URLRequest(
                          url: widget.initUrl,
                          headers: {"Cookie": "$SESSION_COOKIE_ID=$sessionId"},
                        ),
                      );
                    } catch (e) {
                      print(e);
                    }
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
                          widget.initUrl.toString() != ""
                              ? OutlinedButton(
                                  onPressed: () {
                                    errorMsg = null;
                                    try {
                                      webView.loadUrl(
                                        urlRequest:
                                            URLRequest(url: widget.initUrl),
                                      );
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                  child: const Text("初期ページに戻る"),
                                )
                              : OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("ブラウザを閉じる"),
                                )
                        ],
                      ),
                    ),
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
                  Visibility(
                    visible: widget.shouldShowAddNewClassButton,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkResponse(
                        onTap: addNewClassButtonAvailable
                            ? () async {
                                var addDestinationTimetable = widget.timetable;
                                // show add destination timetable select dialog
                                if (addDestinationTimetable == null) {
                                  var allTimetables = await getAllTimetables(
                                      onFetchFinished: (result) {});
                                  var dialogResponse = await showDialog(
                                    context: context,
                                    builder: (_) {
                                      return SelectorDialog<TimetableModel?>(
                                        allTimetables,
                                        (key, value) async {
                                          addDestinationTimetable =
                                              allTimetables[key];
                                          if (addDestinationTimetable == null) {
                                            return;
                                          }
                                        },
                                        description: "追加先の時間割を選択してください",
                                      );
                                    },
                                  );
                                  if (dialogResponse == null) {
                                    return;
                                  }
                                }

                                // create new cell from html
                                var newCell = await fetchClassDetail(
                                  currentUrl.toString(),
                                  addDestinationTimetable!,
                                );
                                print(newCell);
                                if (newCell == null) return;

                                // override confirmation
                                bool? shouldReplace = true;
                                if (addDestinationTimetable!
                                            .timetable[newCell.period]
                                        [newCell.dayOfWeek] !=
                                    null) {
                                  shouldReplace = await showDialog(
                                    context: context,
                                    builder: (_) {
                                      return AlertDialog(
                                        title: const Text("授業置き換え"),
                                        content: Text(
                                            "${DAY_OF_WEEK_MAP[newCell.dayOfWeek]}${PERIOD_MAP[newCell.period]} には既に ${addDestinationTimetable?.timetable[newCell.period][newCell.dayOfWeek]?.name} が登録されています。置き換えますか？"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, false);
                                              return;
                                            },
                                            child: const Text("キャンセル"),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context, true);
                                            },
                                            child: const Text("置き換え"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }

                                // add to local db
                                if (shouldReplace == true) {
                                  await addDestinationTimetable!
                                      .addCell(newCell);

                                  Fluttertoast.showToast(
                                    msg:
                                        "${DAY_OF_WEEK_MAP[newCell.dayOfWeek]}${PERIOD_MAP[newCell.period]} に ${newCell.name} を登録しました。",
                                  );
                                }
                              }
                            : () {
                                Fluttertoast.showToast(
                                  msg: "授業詳細ページでのみ利用できます",
                                );
                              },
                        child: Column(
                          children: [
                            Icon(
                              Icons.add,
                              color: addNewClassButtonAvailable
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                            Text(
                              "履修計画に登録",
                              style: TextStyle(
                                fontSize: 10,
                                color: addNewClassButtonAvailable
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
