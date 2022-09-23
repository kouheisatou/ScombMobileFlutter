import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/db/setting_entity.dart';
import 'package:scomb_mobile/ui/screen/single_page_scomb.dart';

import '../../common/db/my_link_entity.dart';
import '../../common/values.dart';
import '../dialog/syllabus_search_dialog.dart';

const SGSOT_URL =
    "http://sgsot.sic.shibaura-it.ac.jp/redirect.php?user=\${username}&domain=sic.shibaura-it.ac.jp&method=&GID_COMMIT=%A5%ED%A5%B0%A5%A4%A5%F3";
const BUS_ARRIVAL_TIMETABLE = "http://bus.shibaura-it.ac.jp/ts/today_sheet.php";
const GP_GRAPH_PAGE_URL = "https://gp.sic.shibaura-it.ac.jp/";

class LinkListScreen extends StatefulWidget {
  @override
  State<LinkListScreen> createState() => _LinkListScreenState();
}

class _LinkListScreenState extends State<LinkListScreen> {
  List<MyLink> globalLinkList = [
    MyLink.preset(
      "ScombZ",
      SCOMB_HOME_URL,
      Image.asset("resources/scombz_icon.png"),
    ),
    MyLink.preset(
      "学バス時刻表",
      BUS_ARRIVAL_TIMETABLE,
      const Icon(Icons.directions_bus),
    ),
  ];

  List<MyLink> vpnLinkList = [
    MyLink.preset(
      "S*gsot",
      SGSOT_URL,
      Image.asset("resources/sgsot.png"),
      onPressed: (context, linkModel) async {
        var db = await AppDatabase.getDatabase();
        var username =
            (await db.currentSettingDao.getSetting(SettingKeys.USERNAME))
                    ?.settingValue ??
                "";
        var uri =
            Uri.parse(linkModel.url.replaceFirst("\${username}", username));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (builder) {
              return SinglePageScomb(
                uri,
                linkModel.title,
                shouldRemoveHeader: false,
              );
            },
            fullscreenDialog: true,
          ),
        );
      },
    ),
    MyLink.preset(
      "時間割検索システム",
      TIMETABLE_LIST_PAGE_URL,
      Image.asset("resources/official_timetable_icon.png"),
      onPressed: (context, linkItemModel) async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (builder) {
              return SinglePageScomb(
                Uri.parse(linkItemModel.url),
                linkItemModel.title,
                shouldShowAddNewClassButton: true,
                shouldRemoveHeader: false,
              );
            },
            fullscreenDialog: true,
          ),
        );
      },
    ),
    MyLink.preset(
      "シラバス検索システム",
      SYLLABUS_SEARCH_URL,
      const Icon(Icons.school),
      onPressed: (context, linkModel) async {
        showDialog(
          context: context,
          builder: (_) {
            var controller = TextEditingController();
            var focus = FocusNode();
            return AlertDialog(
              contentPadding: const EdgeInsets.all(10),
              titlePadding: const EdgeInsets.only(
                left: 25,
                bottom: 10,
                top: 20,
                right: 10,
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("キャンセル")),
                Focus(
                  focusNode: focus,
                  child: TextButton(
                    onPressed: () async {
                      focus.requestFocus();
                      var syllabusUrl = await showSyllabusSearchResultDialog(
                        context,
                        controller.text,
                        null,
                      );
                      if (syllabusUrl == "" || syllabusUrl == null) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (buildContext) {
                              return SinglePageScomb(
                                Uri.parse(syllabusUrl),
                                controller.text,
                                shouldRemoveHeader: false,
                              );
                            },
                            fullscreenDialog: true),
                      );
                    },
                    child: const Text("検索"),
                  ),
                ),
              ],
              title: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(linkModel.title),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) {
                            return SinglePageScomb(
                              Uri.parse(linkModel.url),
                              linkModel.title,
                              shouldRemoveHeader: false,
                            );
                          },
                          fullscreenDialog: true,
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new),
                  )
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: "授業名"),
                    controller: controller,
                  )
                ],
              ),
            );
          },
        );
      },
    ),
    MyLink.preset(
      "GP分布グラフ検索",
      GP_GRAPH_PAGE_URL,
      const Icon(Icons.bar_chart),
    ),
  ];
  List<MyLink> userLinkList = [];

  @override
  void initState() {
    getAllMyLinkFromDB();
    super.initState();
  }

  Future<void> getAllMyLinkFromDB() async {
    var db = await AppDatabase.getDatabase();
    userLinkList = await db.currentMyLinkDao.getAllLinks();
    setState(() {});
  }

  List<Widget> buildListItems() {
    List<Widget> result = [];

    result.add(
      Padding(
        padding: const EdgeInsets.only(left: 10, top: 20),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey),
            ),
          ),
          child: const Text(
            "学外からアクセス可能なリンク",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
    for (var linkModel in globalLinkList) {
      result.add(buildMyLinkWidget(linkModel));
    }
    result.add(
      Padding(
        padding: const EdgeInsets.only(left: 10, top: 20),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey),
            ),
          ),
          child: const Text(
            "学内ネットからのみアクセス可能なリンク",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
    for (var linkModel in vpnLinkList) {
      result.add(buildMyLinkWidget(linkModel));
    }
    result.add(
      Padding(
        padding: const EdgeInsets.only(left: 10, top: 20),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey),
            ),
          ),
          child: const Text(
            "マイリンク",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
    for (var linkModel in userLinkList) {
      result.add(buildMyLinkWidget(linkModel));
    }
    result.add(
      TextButton(
        onPressed: () async {
          MyLink? dialogResponse = await showLinkEditDialog(context);
          if (dialogResponse == null) return;

          setState(() {
            userLinkList.add(dialogResponse);
          });

          var db = await AppDatabase.getDatabase();
          db.currentMyLinkDao.insertLink(dialogResponse);
        },
        child: const Text("リンクを追加"),
      ),
    );

    return result;
  }

  Widget buildMyLinkWidget(MyLink linkModel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Slidable(
        endActionPane: linkModel.manuallyAdded
            ? ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (value) async {
                      var db = await AppDatabase.getDatabase();
                      await db.currentMyLinkDao.removeLink(linkModel);

                      setState(() {
                        userLinkList.remove(linkModel);
                      });
                    },
                    backgroundColor: Colors.transparent,
                    foregroundColor: Theme.of(context).primaryColor,
                    icon: Icons.delete,
                  ),
                  SlidableAction(
                    onPressed: (value) async {
                      await showLinkEditDialog(
                        context,
                        linkItemModel: linkModel,
                      );
                      setState(() {});

                      var db = await AppDatabase.getDatabase();
                      db.currentMyLinkDao.insertLink(linkModel);
                    },
                    backgroundColor: Colors.transparent,
                    foregroundColor: Theme.of(context).primaryColor,
                    icon: Icons.edit,
                  ),
                ],
              )
            : null,
        child: OutlinedButton(
          onPressed: () async {
            await linkModel.onPressed(context, linkModel);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(width: 40, height: 40, child: linkModel.icon),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Text(
                      linkModel.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_right,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("リンク"),
      ),
      body: ListView(
        children: buildListItems(),
      ),
    );
  }
}

Future<MyLink?> showLinkEditDialog(BuildContext context,
    {MyLink? linkItemModel}) async {
  MyLink? dialogResponse = await showDialog(
      context: context,
      builder: (_) {
        var linkName = linkItemModel?.title ?? "";
        var url = linkItemModel?.url ?? "";
        return AlertDialog(
          title: Text(linkItemModel != null ? "マイリンクを編集" : "マイリンクを作成"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "リンク名"),
                initialValue: linkItemModel?.title ?? "",
                onChanged: (text) {
                  linkName = text;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "URL"),
                initialValue: linkItemModel?.url ?? "",
                onChanged: (text) {
                  url = text;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: const Text("キャンセル"),
            ),
            TextButton(
              onPressed: () {
                if (linkName == "" || url == "") {
                  Fluttertoast.showToast(msg: "リンク名またはURLが空欄です");
                  return;
                }
                if (linkItemModel != null) {
                  linkItemModel.title = linkName;
                  linkItemModel.url = url;
                }
                Navigator.pop(context, MyLink.addManually(linkName, url));
              },
              child: Text(linkItemModel != null ? "更新" : "作成"),
            ),
          ],
        );
      });
  return dialogResponse;
}
