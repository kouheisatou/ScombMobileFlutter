import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/ui/scomb_mobile.dart';

class NetworkScreen extends StatefulWidget {
  NetworkScreen(this.parent, this.title, {Key? key}) : super(key: key);

  ScombMobileState parent;
  String title;
  bool initialized = false;
  bool isLoading = false;

  @override
  State<NetworkScreen> createState() {
    return NetworkScreenState<NetworkScreen>();
  }
}

class NetworkScreenState<T extends NetworkScreen> extends State<T> {
  Future<void> fetchData() async {
    if (widget.initialized) {
      return;
    }

    setState(() {
      widget.isLoading = true;
    });

    try {
      await getFromServerAndSaveToSharedResource();
      widget.initialized = true;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      setState(() {
        widget.isLoading = false;
      });
    }
  }

  Future<void> refreshData() async {
    widget.initialized = false;
    fetchData();
  }

  /// build view here
  Widget innerBuild() {
    return Container();
  }

  /// fetch data and save as shared resource here
  // if fail, throw exception
  Future<void> getFromServerAndSaveToSharedResource() async {}

  NetworkScreenState() {
    // run fetch after build
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: !widget.isLoading
          ? innerBuild()
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
