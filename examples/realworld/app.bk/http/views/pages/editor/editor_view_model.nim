import std/options
import std/strutils
import std/sequtils
import ../../../../usecases/get_article_in_editor/get_article_in_editor_dto


type Tag* = object
  id*: string
  name*: string

proc new*(_:type Tag, id: string, name: string): Tag =
  return Tag(id:id, name:name)


type Article* = object
  id*:string
  title*: string
  description*: string
  body*: string
  tags*:string

proc new*(_:type Article, id, title, description, body, tags: string): Article =
  return Article(id:id, title:title, description:description, body:body, tags:tags)


type EditorViewModel* = object
  article*:Option[Article]

proc new*(_:type EditorViewModel): EditorViewModel =
  let article = none(Article)
  return EditorViewModel(article:article)


proc new*(_:type EditorViewModel, articleDto: ArticleInEditorDto): EditorViewModel =
  let tags = articleDto.tags.map(
    proc(tag: TagDto):string =
      return tag.name
  )
  let tagStr = tags.join(" ")

  let article = Article.new(
    id = articleDto.articleId,
    title = articleDto.title,
    description = articleDto.description,
    body = articleDto.body,
    tags = tagStr
  )

  return EditorViewModel(article:article.some())


proc fromRequest*(_:type EditorViewModel, id, title, description, body, tags: string): EditorViewModel =
  let article = Article.new(
    id = id,
    title = title,
    description = description,
    body = body,
    tags = tags
  )

  return EditorViewModel(article:article.some())
