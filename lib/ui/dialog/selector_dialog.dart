import 'package:flutter/material.dart';

class SelectorDialog<T> extends StatelessWidget {
  SelectorDialog(this.selectionMap, this.onPressed,
      {this.description, this.selectedKey});

  String? description;

  Map<String, T> selectionMap;
  String? selectedKey;
  Future<void> Function(String key, T? value) onPressed;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      titleTextStyle: const TextStyle(color: Colors.grey),
      title: description != null
          ? Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1, color: Colors.grey),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 30,
                  right: 20,
                  left: 20,
                  top: 10,
                ),
                child: Text(
                  description!,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : null,
      children: buildList(context),
    );
  }

  List<Widget> buildList(BuildContext context) {
    List<Widget> listChildren = [];

    listChildren.add(
      const Divider(
        height: 1,
      ),
    );
    selectionMap.forEach((key, value) {
      listChildren.add(buildRow(key, context));
    });

    return listChildren;
  }

  Widget buildRow(String text, BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: InkWell(
            onTap: () async {
              Navigator.pop(context, text);
              await onPressed(text, selectionMap[text]);
            },
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  text,
                  style: TextStyle(
                    fontWeight: (selectedKey == text)
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
        const Divider(
          height: 1,
        )
      ],
    );
  }
}
