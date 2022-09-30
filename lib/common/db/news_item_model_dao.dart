import 'package:floor/floor.dart';
import 'package:scomb_mobile/common/db/news_item_model_entity.dart';

@dao
abstract class NewsItemModelDao {
  @insert
  Future<void> insertNewsModel(NewsItemModel news);

  @Query("SELECT * FROM news_item WHERE newsId = :newsId LIMIT 1")
  Future<NewsItemModel?> getNews(String newsId);

  @Query("SELECT * FROM news_item")
  Future<List<NewsItemModel>> getAllNews();
}
