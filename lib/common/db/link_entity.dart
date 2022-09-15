import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../ui/screen/single_page_scomb.dart';

typedef LinkButtonClickCallback = Future<void> Function(
  BuildContext context,
  Link linkItemModel,
);

@Entity(tableName: "links")
class Link {
  Link(this.title, this.url) {
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

  Link.withIcon(
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

  @primaryKey
  String title;
  String url;
  @ignore
  late Widget icon;
  @ignore
  late LinkButtonClickCallback onPressed;
  @ignore
  late bool manuallyAdded;
}
