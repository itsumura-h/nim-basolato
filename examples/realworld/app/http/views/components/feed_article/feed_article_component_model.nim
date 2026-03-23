import std/times
import basolato/view


type FeedArticleComponentModel* = object
  articleId*:string
  title*:string
  description*:string
  createdAt*:string
  authorId*:string
  authorName*:string
  authorImage*:string
  popularCount*:int
  isLoginUserLiked*:bool
  csrfToken*: CsrfToken
  tagList*:seq[string]

proc new*(
  _:type FeedArticleComponentModel,
  articleId:string,
  title:string,
  description:string,
  createdAt:DateTime,
  authorId:string,
  authorName:string,
  authorImage:string,
  popularCount:int,
  isLoginUserLiked:bool,
  csrfToken:CsrfToken,
  tagList:seq[string]
):FeedArticleComponentModel = 
  return FeedArticleComponentModel(
    articleId:articleId,
    title:title,
    description:description,
    createdAt:createdAt.format("yyyy MMMM d"),
    authorId:authorId,
    authorName:authorName,
    authorImage:authorImage,
    popularCount:popularCount,
    isLoginUserLiked:isLoginUserLiked,
    csrfToken:csrfToken,
    tagList:tagList
  )
