import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/db/setting_entity.dart';
import 'package:scomb_mobile/ui/screen/single_page_scomb.dart';

import '../../common/db/link_entity.dart';
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
  List<Link> linkList = [
    Link.withIcon(
      "ScombZ",
      SCOMB_HOME_URL,
      Image.asset("resources/scombz_icon.png"),
    ),
    Link.withIcon(
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
    Link.withIcon("時間割検索システム", TIMETABLE_LIST_PAGE_URL,
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
    }),
    Link.withIcon(
      "学バス時刻表",
      BUS_ARRIVAL_TIMETABLE,
      const Icon(Icons.directions_bus),
    ),
    Link.withIcon(
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
                  left: 25, bottom: 10, top: 20, right: 10),
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
                        ),
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
    Link.withIcon(
      "GP分布グラフ検索",
      GP_GRAPH_PAGE_URL,
      const Icon(Icons.bar_chart),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {},
            icon: const Icon(Icons.add),
          )
        ],
        title: const Text("リンク"),
      ),
      body: ListView.builder(
        itemCount: linkList.length,
        itemBuilder: (BuildContext context, int index) {
          var currentLinkModel = linkList[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              onPressed: () async {
                await currentLinkModel.onPressed(context, currentLinkModel);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                          width: 40, height: 40, child: currentLinkModel.icon),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Text(
                        currentLinkModel.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.blueGrey,
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
