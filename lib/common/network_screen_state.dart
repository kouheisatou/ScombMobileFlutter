import 'package:scomb_mobile/ui/scomb_mobile.dart';

abstract class NetworkScreenState {
  bool initialized = false;
  late ScombMobileState parent;
  bool isLoading = false;

  void fetchData();
  void refreshData();
}
