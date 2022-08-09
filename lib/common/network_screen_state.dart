import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scomb_mobile/ui/scomb_mobile.dart';

abstract class NetworkScreenState<T extends StatefulWidget> extends State<T>
    implements LoadingScreen {
  @override
  bool initialized = false;
  @override
  bool isLoading = false;
  late ScombMobileState parent;
  late String title;

  void fetchData();
  void refreshData();
  Widget innerBuild();

  NetworkScreenState(this.parent, this.title) {
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: !isLoading ? innerBuild() : const CircularProgressIndicator(),
    );
  }
}

abstract class LoadingScreen {
  bool initialized = false;
  bool isLoading = false;
}
