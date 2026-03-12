import ./env
# ==================== write ====================
# user
import ./models/aggregates/user/user_repository_interface
import ./data_stores/repositories/user/user_repository
import ./data_stores/repositories/user/mock_user_repository
# article
import ./models/aggregates/article/article_repository_interface
import ./data_stores/repositories/article/mock_article_repository
import ./data_stores/repositories/article/article_repository
# follow relationship
import ./models/aggregates/follow_relationship/follow_relationship_repository_interface
import ./data_stores/repositories/follow_relationship/follow_relationship_repository
import ./data_stores/repositories/follow_relationship/mock_follow_relationship_repository
# favorite
import ./models/aggregates/favorite/favorite_repository_interface
import ./data_stores/repositories/favorite/favorite_repository
import ./data_stores/repositories/favorite/mock_favorite_repository
==================== read ====================
import ./models/dto/user/user_query_interface
import ./data_stores/queries/user/user_query
import ./data_stores/queries/user/mock_user_query
#
import ./models/dto/article_with_author/global_feed_article_list_query_interface
import ./data_stores/queries/article_with_author/global_feed/global_feed_article_list_query
import ./data_stores/queries/article_with_author/global_feed/mock_global_feed_article_list_query
#
import ./models/dto/paginator/global_feed_article_list_paginator_query_interface
import ./data_stores/queries/paginator/global_feed/global_feed_paginator_query
import ./data_stores/queries/paginator/global_feed/mock_global_feed_paginator_query
#
import ./models/dto/article_with_author/your_feed_article_list_query_interface
import ./data_stores/queries/article_with_author/your_feed/your_feed_article_list_query
import ./data_stores/queries/article_with_author/your_feed/mock_your_feed_article_list_query
#
import ./models/dto/paginator/your_feed_article_list_paginator_query_interface
import ./data_stores/queries/paginator/your_feed/your_feed_paginator_query
import ./data_stores/queries/paginator/your_feed/mock_your_feed_paginator_query
#
import ./models/dto/article_with_author/user_article_list_query_interface
import ./data_stores/queries/article_with_author/user/user_article_list_query
import ./data_stores/queries/article_with_author/user/mock_user_article_list_query
#
import ./models/dto/paginator/user_article_list_paginator_query_interface
import ./data_stores/queries/paginator/user/user_paginator_query
import ./data_stores/queries/paginator/user/mock_user_paginator_query
#
import ./models/dto/article_with_author/tag_feed_article_list_query_interface
import ./data_stores/queries/article_with_author/tag_feed/tag_feed_article_list_query
import ./data_stores/queries/article_with_author/tag_feed/mock_tag_feed_article_list_query
#
import ./models/dto/article_detail/article_detail_query_interface
import ./data_stores/queries/article_detail/article_detail_query
import ./data_stores/queries/article_detail/mock_article_detail_query
#
import ./models/dto/paginator/tag_feed_article_list_paginator_query_interface
import ./data_stores/queries/paginator/tag_feed/tag_feed_paginator_query
import ./data_stores/queries/paginator/tag_feed/mock_tag_feed_paginator_query
#
import ./models/dto/tag/tag_list_query_interface
import ./data_stores/queries/tag/popular_tag_list_query
import ./data_stores/queries/tag/mock_popular_tag_list_query
#
import ./models/dto/favorite_button/favorite_button_query_interface
import ./data_stores/queries/favorite_button/favorite_button_query
import ./data_stores/queries/favorite_button/mock_favorite_button_query
#
import ./models/dto/follow_button/follow_button_query_interface
import ./data_stores/queries/follow_button/follow_button_query
import ./data_stores/queries/follow_button/mock_follow_button_query
#
import ./models/dto/comment/comment_list_query_interface
# import ./data_stores/queries/comment_list/comment_list_query
import ./data_stores/queries/comment_list/comment_list_query
import ./data_stores/queries/comment_list/mock_comment_list_query


type DiContainer* = object
  # ==================== write ====================
  userRepository*: IUserRepository
  articleRepository*: IArticleRepository
  followRelationshipRepository*: IFollowRelationshipRepository
  favoriteRepository*: IFavoriteRepository
# ==================== read ====================
  userQuery*: IUserQuery
  globalFeedArticleListQuery*: IGlobalFeedArticleListQuery
  globalFeedPaginatorQuery*: IGlobalFeedArticleListPaginatorQuery
  yourFeedArticleListQuery*: IYourFeedArticleListQuery
  yourFeedPaginatorQuery*: IYourFeedArticleListPaginatorQuery
  tagFeedArticleListQuery*: ITagFeedArticleListQuery
  tagFeedPaginatorQuery*: ITagFeedArticleListPaginatorQuery
  articleDetailQuery*: IArticleDetailQuery
  userArticleListQuery*: IUserArticleListQuery
  userArticleListPaginatorQuery*: IUserArticleListPaginatorQuery
  favoriteButtonQuery*: IFavoriteButtonQuery
  tagListQuery*: ITagListQuery
  followButtonQuery*:IFollowButtonQuery
  commentListQuery*:ICommentListQuery


proc new(_:type DiContainer):DiContainer =
  if APP_ENV == "test":
    return DiContainer(
      # ==================== write ====================
      userRepository: MockUserRepository.new(),
      articleRepository: MockArticleRepository.new(),
      followRelationshipRepository: MockFollowRelationshipRepository.new(),
      favoriteRepository: MockFavoriteRepository.new(),
      # ==================== read ====================
      userQuery: MockUserQuery.new(),
      globalFeedArticleListQuery: MockGlobalFeedArticleListQuery.new(),
      globalFeedPaginatorQuery: MockGlobalFeedPaginatorQuery.new(),
      yourFeedArticleListQuery: MockYourFeedArticleListQuery.new(),
      yourFeedPaginatorQuery: MockYourFeedPaginatorQuery.new(),
      tagFeedArticleListQuery: MockTagFeedArticleListQuery.new(),
      tagFeedPaginatorQuery: MockTagFeedPaginatorQuery.new(),
      articleDetailQuery: MockArticleDetailQuery.new(),
      userArticleListQuery: MockUserArticleListQuery.new(),
      userArticleListPaginatorQuery: MockUserPaginatorQuery.new(),
      favoriteButtonQuery: MockFavoriteButtonQuery.new(),
      tagListQuery: MockPopularTagListQuery.new(),
      followButtonQuery: MockFollowButtonQuery.new(),
      commentListQuery: MockCommentListQuery.new(),
    )
  else:
    return DiContainer(
      # ==================== write ====================
      userRepository: UserRepository.new(),
      articleRepository: MockArticleRepository.new(),
      articleRepository: ArticleRepository.new(),
      ArticleInFeedQuery: MockArticleInFeedQuery.new(),
      followRelationshipRepository: FollowRelationshipRepository.new(),
      followRelationshipRepository: MockFollowRelationshipRepository.new(),
      favoriteRepository: FavoriteRepository.new(),
      favoriteRepository: MockFavoriteRepository.new(),
      # ==================== read ====================
      userQuery: UserQuery.new(),
      globalFeedArticleListQuery: GlobalFeedArticleListQuery.new(),
      globalFeedPaginatorQuery: GlobalFeedPaginatorQuery.new(),
      yourFeedArticleListQuery: YourFeedArticleListQuery.new(),
      yourFeedPaginatorQuery: YourFeedPaginatorQuery.new(),
      tagFeedArticleListQuery: TagFeedArticleListQuery.new(),
      tagFeedPaginatorQuery: TagFeedPaginatorQuery.new(),
      articleDetailQuery: ArticleDetailQuery.new(),
      userArticleListQuery: UserArticleListQuery.new(),
      userArticleListPaginatorQuery: UserPaginatorQuery.new(),
      favoriteButtonQuery: FavoriteButtonQuery.new(),
      tagListQuery: PopularTagListQuery.new(),
      followButtonQuery: FollowButtonQuery.new(),
      commentListQuery: CommentListQuery.new(),
    )

let di* = DiContainer.new()
