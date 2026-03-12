import std/asyncdispatch
from ../../config/database import rdb
import ./seed_user
import ./seed_article
import ./seed_comment
import ./seed_favorite
import ./seed_tag
import ./seed_tag_article
import ./seed_user_user_map


proc main() =
  user(rdb).waitFor()
  userUserMap(rdb).waitFor()
  article(rdb).waitFor()
  comment(rdb).waitFor()
  favorite(rdb).waitFor()
  tag(rdb).waitFor()
  tagArticle(rdb).waitFor()


main()
