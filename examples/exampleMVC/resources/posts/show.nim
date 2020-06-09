import json
# framework
import ../../../src/basolato/view
import ../base

proc showHtmlImpl(auth:Auth, post:JsonNode):string = tmpli html"""
<div class="post">
  <div class="post-header">
    $if post["published_date"].get().len > 0 {
      <div class="date">
        $(post["published_date"].get)
      </div>
    }
    $if auth.isLogin and auth.get("uid") == post["auther_id"].get {
      <a class="btn btn-default" href="/posts/$(post["id"].get)/edit"><span class="glyphicon glyphicon-pencil"></span></a>
      <form method="POST" action="/posts/$(post["id"].get)/delete">
        $(csrfToken())
        <button type="submit" class="btn btn-default"><span class="glyphicon glyphicon-trash" /></button>
      </form>
    }
  </div>
  <h2>$(post["title"].get)</h2>
  <p>$(post["text"].get)</p>
</div>
"""

proc showHtml*(auth:Auth, post:JsonNode):string =
  baseHtml(auth, showHtmlImpl(auth, post))
