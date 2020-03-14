import json, strformat
import karax / [karaxdsl, vdom]
import ../../../src/basolato/view
import ../base

proc showHtmlImpl(auth:Auth, post:JsonNode):string =
  var vnode = buildHtml(tdiv(class="post")):
    tdiv(class="post-header"):
      if post["published_date"].get().len > 0:
        tdiv(class="date"):
          text(post["published_date"].get)
      if auth.isLogin and auth.get("uid") == post["auther_id"].get:
        a(class="btn btn-default", href= &"""/posts/{post["id"].get}/edit"""):
          span(class="glyphicon glyphicon-pencil")
        form(`method`="POST", action= &"""/posts/{post["id"].get}/delete"""):
          csrfTokenKarax()
          button(type="submit", class="btn btn-default"):
            span(class="glyphicon glyphicon-trash")
    h2: text(post["title"].get)
    p: text(post["text"].get)
  
  return $vnode

proc showHtml*(auth:Auth, post:JsonNode):string =
  baseHtml(auth, showHtmlImpl(auth, post))
