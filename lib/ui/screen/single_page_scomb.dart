import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/db/setting_entity.dart';
import 'package:scomb_mobile/common/password_encripter.dart';
import 'package:scomb_mobile/common/scraping/syllabus_scraping.dart';
import 'package:scomb_mobile/common/timetable_model.dart';
import 'package:scomb_mobile/ui/dialog/selector_dialog.dart';
import 'package:scomb_mobile/ui/screen/login_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/db/class_cell_dao.dart';
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
    var addNewClassButtonAvailable = (currentUrl.host == "timetable.sic.shibaura-it.ac.jp" && currentUrl.path.contains("detail") && errorMsg == null);

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
                      errorMsg = "URL??????????????????????????????";
                    }
                    webView = controller;
                    setState(() {
                      loading = true;
                    });
                  },
                  initialUrlRequest: URLRequest(url: widget.initUrl),
                  onLoadError: (controller, url, code, msg) {
                    setState(() {
                      if (code == -1003) {
                        errorMsg = "[??????????????????]\n\n\n??????????????????????????????????????????????????????????????????????????????????????????\n\n???URL????????????????????????????????????????????????";
                      } else if (code == 102) {
                      } else {
                        errorMsg = "$code : $msg";
                      }
                      loading = false;
                    });
                  },
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      useOnDownloadStart: true,
                      useOnLoadResource: true,
                    ),
                  ),
                  onDownloadStartRequest: (controller, url) async {
                    download(
                      url.url,
                      url.suggestedFilename ?? "null",
                    );
                    webView.reload();
                  },
                  onLoadStart: (controller, currentUrl) {
                    print(currentUrl.toString());
                  },
                  onLoadStop: (controller, currentUrl) async {
                    // save cookie
                    CookieManager cookieManager = CookieManager.instance();
                    Cookie? cookie = await cookieManager.getCookie(
                      url: Uri.parse(SCOMBZ_DOMAIN),
                      name: SESSION_COOKIE_ID,
                    );
                    sessionId = cookie?.value;

                    if (sessionId != null) {
                      (await AppDatabase.getDatabase()).currentSettingDao.insertSetting(
                            Setting(
                              SettingKeys.SESSION_ID,
                              encryptAES(sessionId!),
                            ),
                          );
                    }

                    // only school local network error handling
                    String? html = await controller.evaluateJavascript(
                      source: "window.document.getElementsByTagName('html')[0].outerHTML;",
                    );
                    if (html?.contains("????????????????????????????????????????????????????????????") == true) {
                      errorMsg = "???????????????????????????????????????????????????????????????";
                      loading = false;
                    }

                    if (currentUrl != null) {
                      var currentUrlString = "https://${currentUrl.host}${currentUrl.path}";
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
                              headers: sessionId != null ? {"Cookie": "$SESSION_COOKIE_ID=$sessionId"} : null,
                            ),
                          );
                        } catch (e) {
                          print(e);
                        }
                      }
                    }

                    this.currentUrl = currentUrl ?? widget.initUrl;
                    if (widget.shouldRemoveHeader) {
                      await controller.evaluateJavascript(
                        source: "document.getElementById('$HEADER_ELEMENT_ID').remove();",
                      );
                      await controller.evaluateJavascript(
                        source: "document.getElementById('$FOOTER_ELEMENT_ID').remove();",
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
                                        urlRequest: URLRequest(
                                          url: widget.initUrl,
                                        ),
                                      );
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                  child: const Text("????????????????????????"),
                                )
                              : OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("????????????????????????"),
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
                      await webView.reload();
                    },
                    icon: const Icon(Icons.refresh),
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
                                  var allTimetables = await getAllTimetables(onFetchFinished: (result) {});
                                  var dialogResponse = await showDialog(
                                    context: context,
                                    builder: (_) {
                                      return SelectorDialog<TimetableModel?>(
                                        allTimetables,
                                        (key, value) async {
                                          addDestinationTimetable = allTimetables[key];
                                          if (addDestinationTimetable == null) {
                                            return;
                                          }
                                        },
                                        description: "????????????????????????????????????????????????",
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
                                if (addDestinationTimetable!.cells[newCell.period][newCell.dayOfWeek] != null) {
                                  shouldReplace = await showDialog(
                                    context: context,
                                    builder: (_) {
                                      return AlertDialog(
                                        title: const Text("??????????????????"),
                                        content: Text("${DAY_OF_WEEK_MAP[newCell.dayOfWeek]}${PERIOD_MAP[newCell.period]} ???????????? ${addDestinationTimetable?.cells[newCell.period][newCell.dayOfWeek]?.name} ??????????????????????????????????????????????????????"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, false);
                                              return;
                                            },
                                            child: const Text("???????????????"),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context, true);
                                            },
                                            child: const Text("????????????"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }

                                // add to local db
                                if (shouldReplace == true) {
                                  await addDestinationTimetable!.addCell(newCell);

                                  Fluttertoast.showToast(
                                    msg: "${DAY_OF_WEEK_MAP[newCell.dayOfWeek]}${PERIOD_MAP[newCell.period]} ??? ${newCell.name} ????????????????????????",
                                  );
                                }
                              }
                            : () {
                                Fluttertoast.showToast(
                                  msg: "????????????????????????????????????????????????",
                                );
                              },
                        child: Column(
                          children: [
                            Icon(
                              Icons.add,
                              color: addNewClassButtonAvailable ? Colors.black : Colors.grey,
                            ),
                            Text(
                              "?????????????????????",
                              style: TextStyle(
                                fontSize: 10,
                                color: addNewClassButtonAvailable ? Colors.black : Colors.grey,
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
                        Fluttertoast.showToast(msg: "URL????????????????????????????????????????????????");
                      },
                      child: Column(
                        children: const [
                          Icon(Icons.copy),
                          Text(
                            "URL????????????",
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
                            "?????????????????????",
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

  Future<void> download(
    Uri url,
    String downloadFileName,
  ) async {
    // final box = context.findRenderObject() as RenderBox;
    print("download $url");
    Fluttertoast.showToast(msg: "???????????????????????????????????????");

    var dir = Directory("${(await getApplicationDocumentsDirectory()).path}/temp/");
    if (await dir.exists()) {
      dir.deleteSync(recursive: true);
    }
    dir.createSync(recursive: true);
    var filepath = "${dir.path}/$downloadFileName";

    try {
      var response = await http.get(
        url,
        headers: {
          "Cookie": "$SESSION_COOKIE_ID=$sessionId",
        },
      );

      await File(filepath).writeAsBytes(response.bodyBytes);

      await Share.shareFiles(
        [filepath],
        subject: downloadFileName,
        // sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 300, 300),
        // sharePositionOrigin: Rect.fromPoints(const Offset(0, 0), Offset(box.size.width, box.size.height)),
      );
    } catch (e) {
      print(e);
    }
  }
}
