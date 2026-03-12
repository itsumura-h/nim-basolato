import std/asyncdispatch
import std/strformat
import ../../http/views/islands/article_preview/article_preview_view_model
import ../../http/views/islands/article_preview/feed_navigation/feed_navigation_view_model
import ../../http/views/islands/article_preview/paginator/paginator_view_model
import ../../http/views/islands/favorite_button/favorite_button_view_model
import ../../models/dto/article_with_author/tag_feed_article_list_query_interface
import ../../models/dto/paginator/tag_feed_article_list_paginator_query_interface
import ../../models/dto/favorite_button/favorite_button_query_interface
import ../../models/vo/article_id
import ../../models/vo/user_id
import ../../di_container


type TagFeedArticleListPresenter* = object
  tagFeedArticleListQuery:ITagFeedArticleListQuery
  paginator:ITagFeedArticleListPaginatorQuery
  favoriteButtonQuery: IFavoriteButtonQuery

proc new*(_:type TagFeedArticleListPresenter):TagFeedArticleListPresenter =
  return TagFeedArticleListPresenter(
    tagFeedArticleListQuery: di.tagFeedArticleListQuery,
    paginator: di.tagFeedPaginatorQuery,
    favoriteButtonQuery: di.favoriteButtonQuery
  )


proc invoke*(self:TagFeedArticleListPresenter, tagName:string, page:int, isLogin:bool, loginUserId:string):Future[ArticlePreviewViewModel] {.async.} =
  const display = 5
  let offset = (page - 1) * display
  let articleWithAuthorDtoList = self.tagFeedArticleListQuery.invoke(tagName, offset, display).await

  var articleList:seq[Article]
  for articleWithAuthorDto in articleWithAuthorDtoList:
    let articleId = ArticleId.new(articleWithAuthorDto.id)

    let favoriteButtonDto =
      if isLogin:
        let loginUserId = UserId.new(loginUserId)
        self.favoriteButtonQuery.invoke(articleId, loginUserId).await
      else:
        self.favoriteButtonQuery.invoke(articleId).await

    let favoriteButtonViewModel = FavoriteButtonViewModel.new(favoriteButtonDto)
    articleList.add(
      Article.new(articleWithAuthorDto, favoriteButtonViewModel)
    )

  let paginatorDto = self.paginator.invoke(tagName, page, display).await
  let paginatorViewModel = PaginatorViewModel.new(paginatorDto, &"/island/home/tag-feed/{tagName}")

  var feedNavbarViewModelList = @[
    FeedNavbarViewModel.new(
      title = "Global Feed",
      isActive = false,
      hxGetUrl = "/island/home/global-feed",
      hxPushUrl = "/"
    ),
    FeedNavbarViewModel.new(
      title = tagName,
      isActive = true,
      hxGetUrl = &"/island/home/tag-feed/{tagName}",
      hxPushUrl = "/"
    ),
  ]

  if isLogin:
    feedNavbarViewModelList.insert(
      FeedNavbarViewModel.new(
        title = "Your Feed",
        isActive = false,
        hxGetUrl = "/island/home/your-feed",
        hxPushUrl = "/your-feed"
      ),
      0
    )

  let viewModel = ArticlePreviewViewModel.new(articleList, paginatorViewModel, feedNavbarViewModelList)
  return viewModel
