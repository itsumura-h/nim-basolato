import std/json

type FortuneTable* = object
  ## Fortune
  id*: int
  message*: string


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


type User_user_mapTable* = object
  ## user_user_map
  user_id*: string
  follower_id*: string


type User_article_mapTable* = object
  ## user_article_map
  user_id*: string
  article_id*: string


type TagTable* = object
  ## tag
  id*: string
  name*: string


type Tag_article_mapTable* = object
  ## tag_article_map
  tag_id*: string
  article_id*: string


type WorldTable* = object
  ## World
  id*: int
  randomnumber*: int


type CommentTable* = object
  ## comment
  id*: int
  body*: string
  article_id*: string
  author_id*: string
  created_at*: string
  updated_at*: string
