import 'package:floor/floor.dart';

import 'my_link_entity.dart';

@dao
abstract class MyLinkDao {
  @insert
  Future<void> insertLink(MyLink linkModel);

  @delete
  Future<void> removeLink(MyLink linkModel);

  @Query("SELECT * FROM my_links")
  Future<List<MyLink>> getAllLinks();
}
