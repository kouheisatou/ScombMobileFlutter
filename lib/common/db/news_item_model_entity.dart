import 'package:floor/floor.dart';

@Entity(tableName: "news")
class NewsItemModel {
  @primaryKey
  // "data1" in html attr
  String newsId;

  String data2;

  String title;
  String category;
  String domain;
  String publishTime;
  Set<String> tags;

  NewsItemModel(
    this.newsId,
    this.data2,
    this.title,
    this.category,
    this.domain,
    this.publishTime,
    this.tags,
  );
  @override
  String toString() {
    return "NewsItemModel($newsId, $data2, $title, $category, $domain, $publishTime, $tags)";
  }
}
