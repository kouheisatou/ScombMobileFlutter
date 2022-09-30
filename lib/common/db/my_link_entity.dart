import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../ui/screen/single_page_scomb.dart';

typedef LinkButtonClickCallback = Future<void> Function(
  BuildContext context,
  MyLink linkItemModel,
);

@Entity(tableName: "my_links")
class MyLink {
  MyLink(this.id, this.title, this.url) {
    icon = const Icon(Icons.link);
    onPressed = (context, linkItemModel) async {
      var uri = Uri.parse(linkItemModel.url);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (builder) {
            return SinglePageScomb(
              uri,
              linkItemModel.title,
              shouldRemoveHeader: false,
            );
          },
          fullscreenDialog: true,
        ),
      );
    };
    manuallyAdded = true;
  }

  MyLink.addManually(this.title, this.url) {
    icon = const Icon(Icons.link);
    onPressed = (context, linkItemModel) async {
      var uri = Uri.parse(linkItemModel.url);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (builder) {
            return SinglePageScomb(
              uri,
              linkItemModel.title,
              shouldRemoveHeader: false,
            );
          },
          fullscreenDialog: true,
        ),
      );
    };
    manuallyAdded = true;
  }

  MyLink.preset(
    this.title,
    this.url,
    this.icon, {
    LinkButtonClickCallback? onPressed,
  }) {
    if (onPressed != null) {
      this.onPressed = onPressed;
    } else {
      this.onPressed = (context, linkItemModel) async {
        var uri = Uri.parse(linkItemModel.url);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (builder) {
              return SinglePageScomb(
                uri,
                linkItemModel.title,
                shouldRemoveHeader: false,
              );
            },
            fullscreenDialog: true,
          ),
        );
      };
    }
    manuallyAdded = false;
  }

  @PrimaryKey(autoGenerate: true)
  int? id;
  String title;
  String url;
  @ignore
  late Widget icon;
  @ignore
  late LinkButtonClickCallback onPressed;
  @ignore
  late bool manuallyAdded;

  dynamic toJson() => {
        "id": id,
        "title": title,
        "url": url,
      };
}
