import ../../../../models/dto/favorite_button/favorite_button_dto


type FavoriteButtonViewModel* = object
  articleId*:string
  count*:int
  isFavorited*:bool
  willDelete*:bool

proc new*(_:type FavoriteButtonViewModel, dto:FavoriteButtonDto, willDelete=false): FavoriteButtonViewModel =
  ## willDelete is only in /users/{article} favorite articles
  return FavoriteButtonViewModel(
    articleId: dto.articleId,
    count: dto.favoriteCount,
    isFavorited: dto.isFavorited,
    willDelete: willDelete,
  )
