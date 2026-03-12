import ./consts
# ==================== write ====================
import ./models/aggregates/user/user_repository_interface
import ./data_stores/repositories/user/user_repository
import ./data_stores/repositories/user/mock_user_repository

# ==================== read ====================
import ./models/dto/user/user_dao_interface
import ./data_stores/dao/user/user_dao
import ./data_stores/dao/user/mock_user_dao
# global feed list
import ./models/dto/article_list/global_feed_article_list_dao_interface
import ./data_stores/dao/article_list/global_feed_article_list/global_feed_article_list_dao
import ./data_stores/dao/article_list/global_feed_article_list/mock_global_feed_article_list_dao
# global feed count
import ./models/dto/article_list/global_feed_article_count_dao_interface
import ./data_stores/dao/article_list/global_feed_article_count/global_feed_article_count_dao
import ./data_stores/dao/article_list/global_feed_article_count/mock_global_feed_article_count_dao
# your feed list
import ./models/dto/article_list/your_feed_article_list_dao_interface
import ./data_stores/dao/article_list/your_feed_article_list/your_feed_article_list_dao
import ./data_stores/dao/article_list/your_feed_article_list/mock_your_feed_article_list_dao
# your feed count
import ./models/dto/article_list/your_feed_article_count_dao_interface
import ./data_stores/dao/article_list/your_feed_article_count/your_feed_article_count_dao
import ./data_stores/dao/article_list/your_feed_article_count/mock_your_feed_article_count_dao
# tag feed list
import ./models/dto/article_list/tag_feed_article_list_dao_interface
import ./data_stores/dao/article_list/tag_feed_article_list/tag_feed_article_list_dao
import ./data_stores/dao/article_list/tag_feed_article_list/mock_tag_feed_article_list_dao
# tag feed count
import ./models/dto/article_list/tag_feed_article_count_dao_interface
import ./data_stores/dao/article_list/tag_feed_article_count/tag_feed_article_count_dao
import ./data_stores/dao/article_list/tag_feed_article_count/mock_tag_feed_article_count_dao
# tag list
import ./models/dto/tag/tag_dao_interface
import ./data_stores/dao/tag/tag_dao
import ./data_stores/dao/tag/mock_tag_dao
# article detail
import ./models/dto/article_detail/article_detail_dao_interface
import ./data_stores/dao/article_detail/article_detail_dao
import ./data_stores/dao/article_detail/mock_article_detail_dao
# comment
import ./models/dto/comment/comment_dao_interface
import ./data_stores/dao/comment/comment_dao
import ./data_stores/dao/comment/mock_comment_dao
# user article list
import ./models/dto/article_list/user_article_list_dao_interface
import ./data_stores/dao/article_list/user_article_list/user_article_list_dao
import ./data_stores/dao/article_list/user_article_list/mock_user_article_list_dao
# user article count
import ./models/dto/article_list/user_article_count_dao_interface
import ./data_stores/dao/article_list/user_article_count/user_article_count_dao
import ./data_stores/dao/article_list/user_article_count/mock_user_article_count_dao
# user favorite article list
import ./data_stores/dao/article_list/user_favorite_article_list/user_favorite_article_list_dao
import ./data_stores/dao/article_list/user_favorite_article_list/mock_user_favorite_article_list_dao
# user favorite article count
import ./data_stores/dao/article_list/user_favorite_article_count/user_favorite_article_count_dao
import ./data_stores/dao/article_list/user_favorite_article_count/mock_user_favorite_article_count_dao


type DiContainer* = object
# ==================== write ====================
  userRepository*: IUserRepository
# ==================== read ====================
  userDao*: IUserDao
  globalFeedArticleListDao*: IGlobalFeedArticleListDao
  globalFeedArticleCountDao*: IGlobalFeedArticleCountDao
  yourFeedArticleListDao*: IYourFeedArticleListDao
  yourFeedArticleCountDao*: IYourFeedArticleCountDao
  tagFeedArticleListDao*: ITagFeedArticleListDao
  tagFeedArticleCountDao*: ITagFeedArticleCountDao
  tagDao*: ITagDao
  articleDetailDao*: IArticleDetailDao
  commentDao*: ICommentDao
  userArticleListDao*: IUserArticleListDao
  userArticleCountDao*: IUserArticleCountDao
  userFavoriteArticleListDao*: IUserArticleListDao
  userFavoriteArticleCountDao*: IUserArticleCountDao

proc new(_:type DiContainer):DiContainer =
  if APP_ENV == "test":
    return DiContainer(
      # ==================== write ====================
      userRepository: MockUserRepository.new(),
      # ==================== read ====================
      userDao: MockUserDao.new(),
      globalFeedArticleListDao: MockGlobalFeedArticleListDao.new(),
      globalFeedArticleCountDao: MockGlobalFeedArticleCountDao.new(),
      yourFeedArticleListDao: MockYourFeedArticleListDao.new(),
      yourFeedArticleCountDao: MockYourFeedArticleCountDao.new(),
      tagFeedArticleListDao: MockTagFeedArticleListDao.new(),
      tagFeedArticleCountDao: MockTagFeedArticleCountDao.new(),
      tagDao: MockTagDao.new(),
      articleDetailDao: MockArticleDetailDao.new(),
      commentDao: MockCommentDao.new(),
      userArticleListDao: MockUserArticleListDao.new(),
      userArticleCountDao: MockUserArticleCountDao.new(),
      userFavoriteArticleListDao: MockUserFavoriteArticleListDao.new(),
      userFavoriteArticleCountDao: MockUserFavoriteArticleCountDao.new(),
    )
  else:
    return DiContainer(
      # ==================== write ====================
      userRepository: UserRepository.new(),
      # ==================== read ====================
      userDao: UserDao.new(),
      globalFeedArticleListDao: GlobalFeedArticleListDao.new(),
      globalFeedArticleCountDao: GlobalFeedArticleCountDao.new(),
      yourFeedArticleListDao: YourFeedArticleListDao.new(),
      yourFeedArticleCountDao: YourFeedArticleCountDao.new(),
      tagFeedArticleListDao: TagFeedArticleListDao.new(),
      tagFeedArticleCountDao: TagFeedArticleCountDao.new(),
      tagDao: TagDao.new(),
      articleDetailDao: ArticleDetailDao.new(),
      commentDao: CommentDao.new(),
      userArticleListDao: UserArticleListDao.new(),
      userArticleCountDao: UserArticleCountDao.new(),
      userFavoriteArticleListDao: UserFavoriteArticleListDao.new(),
      userFavoriteArticleCountDao: UserFavoriteArticleCountDao.new(),
    )

let di* = DiContainer.new()
