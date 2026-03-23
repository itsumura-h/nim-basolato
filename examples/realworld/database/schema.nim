type UserTable* = object
  ## user
  id*: string
  name*: string
  email*: string
  email_verified_at*: string
  password*: string
  bio*: string
  image*: string
  created_at*: string
  updated_at*: string


type ArticleTable* = object
  ## article
  id*: string
  title*: string
  description*: string
  body*: string
  author_id*: string
  created_at*: string
  updated_at*: string


type UserUserMapTable* = object
  ## user_user_map
  user_id*: string
  follower_id*: string


type UserArticleMapTable* = object
  ## user_article_map
  user_id*: string
  article_id*: string


type TagTable* = object
  ## tag
  id*: string
  name*: string


type TagArticleMapTable* = object
  ## tag_article_map
  tag_id*: string
  article_id*: string


type CommentTable* = object
  ## comment
  id*: int
  body*: string
  article_id*: string
  author_id*: string
  created_at*: string
  updated_at*: string
