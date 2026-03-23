import ../../../../../models/dto/favorite_button/favorite_button_dto


type FavoriteButtonInArticleViewModel* = object
  articleId*:string
  count*:int
  isFavorited*:bool

proc new*(_:type FavoriteButtonInArticleViewModel, dto:FavoriteButtonDto): FavoriteButtonInArticleViewModel =
  return FavoriteButtonInArticleViewModel(
    articleId: dto.articleId,
    count: dto.favoriteCount,
    isFavorited: dto.isFavorited,
  )
