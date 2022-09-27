import 'package:floor/floor.dart';

@Entity(tableName: "news")
class NewsItemModel {
  @PrimaryKey(autoGenerate: true)
  int? id;
  bool isAlreadyRead = false;
  bool isNew = false;
  bool isImportant = false;
  String domain;
  int publishTime;
  String category;

  NewsItemModel(
    this.id,
    this.isAlreadyRead,
    this.isNew,
    this.isImportant,
    this.domain,
    this.publishTime,
    this.category,
  );
}
