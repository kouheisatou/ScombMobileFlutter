import 'package:flutter/material.dart';

class SelectorDialog<T> extends StatelessWidget {
  SelectorDialog(this.selectionMap, this.onPressed);

  Map<String, T> selectionMap;
  Future<void> Function(String key, T? value) onPressed;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: buildList(context),
    );
  }

  List<Widget> buildList(BuildContext context) {
    List<Widget> listChildren = [
      const Divider(
        height: 1,
      ),
    ];
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
              Navigator.pop(context);
              await onPressed(text, selectionMap[text]);
            },
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(text),
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
