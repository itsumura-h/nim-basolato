import json, strformat
# 3rd party
import karax / [karaxdsl, vdom]
# framework
import ../../../src/basolato/view
import ../base
proc indexHtmlImpl(posts:seq[JsonNode]):string =
  var vnode = buildHtml(tdiv):
    for post in posts:
      tdiv(class="post"):
        tdiv(class="date"):
          p: text(&"""published: {post["published_date"].get}""")
        h2:
          a(href= &"""/posts/{post["id"].get}"""): text(post["title"].get)
        p: text(post["text"].get)
  return $vnode

proc indexHtml*(auth:Auth, posts:seq[JsonNode]): string =
  baseHtml(auth, indexHtmlImpl(posts))
