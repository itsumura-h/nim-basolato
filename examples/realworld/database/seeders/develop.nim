import std/asyncdispatch
import std/json
import std/options
import ../../config/env
from ../../config/database import rdb
import ./data/seed_user
import ./data/seed_article
import ./data/seed_comment
import ./data/seed_favorite
import ./data/seed_tag
import ./data/seed_tag_article
import ./data/seed_user_user_map
import allographer/query_builder


proc main() =
  if APP_ENV == AppEnvType.Develop or APP_ENV == AppEnvType.Test:
    user(rdb).waitFor()
    userUserMap(rdb).waitFor()
    article(rdb).waitFor()
    comment(rdb).waitFor()
    favorite(rdb).waitFor()
    tag(rdb).waitFor()
    tagArticle(rdb).waitFor()

    echo rdb.table("user").first().waitFor().get()
    echo rdb.table("article").first().waitFor().get()

main()
