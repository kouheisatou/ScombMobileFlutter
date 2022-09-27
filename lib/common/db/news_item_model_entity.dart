import 'package:floor/floor.dart';

@Entity(tableName: "news_item")
class NewsItemModel {
  @primaryKey
  // "data1" in html attr
  String newsId;
  String data2;
  String title;
  String category;
  String domain;
  String publishTime;
  String tags;
  bool unread;

  NewsItemModel(
    this.newsId,
    this.data2,
    this.title,
    this.category,
    this.domain,
    this.publishTime,
    this.tags,
    this.unread,
  );

  @override
  String toString() {
    return "NewsItemModel(newsId=$newsId, data2=$data2, title=$title, category=$category, domain=$domain, publishTime=$publishTime, tags=$tags)";
  }
}
