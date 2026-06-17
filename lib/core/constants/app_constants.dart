/// 应用常量
class AppConstants {
  AppConstants._();

  /// App 名称
  static const appName = '时令水果';

  /// 数据缓存 key 前缀
  static const cachePrefix = 'cache_';

  /// Feed 缓存 key
  static const feedCacheKey = '${cachePrefix}feed';

  /// 帖子详情缓存 prefix
  static const postCachePrefix = '${cachePrefix}post_';
}