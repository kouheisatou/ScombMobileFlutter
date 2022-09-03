import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  LoadingDialog();
  late BuildContext context;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    isLoading = true;
    this.context = context;
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: const [
            Text("読み込み中"),
            SizedBox(width: 20),
            CircularProgressIndicator(),
          ],
        )
      ],
    );
  }

  void close() {
    isLoading = false;
    Navigator.pop(context);
  }
}
