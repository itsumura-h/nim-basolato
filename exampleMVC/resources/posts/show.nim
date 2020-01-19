import json
# import ../../../src/basolato/view
import ../../../src/basolato/private
import ../../../src/basolato/session
import ../base

proc showHtmlImpl(login:Login, post:JsonNode):string = tmpli html"""
<div class="post">
    $if post["published_date"].get().len > 0 {
      <div class="date">
        $(post["published_date"].get)
      </div>
    }
    $if login.isLogin {
      <a class="btn btn-default" href="/posts/$(post["id"].get)/edit"><span class="glyphicon glyphicon-pencil"></span></a>
    }
    <h2>$(post["title"].get)</h2>
    <p>$(post["text"].get)</p>
</div>
"""

proc showHtml*(login:Login, post:JsonNode):string =
  baseHtml(login, showHtmlImpl(login, post))
