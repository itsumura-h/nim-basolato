import json
# import ../../../src/basolato/view
import ../../../src/basolato/private
import ../base

proc indexHtmlImpl(posts:seq[JsonNode]):string = tmpli html"""
$for post in posts {
  <div class="post">
      <div class="date">
        <p>published: $(post["published_date"].get)</p>
      </div>
    <h2><a href="/posts/$(post["id"].get)">$(post["title"].get)</a></h2>
    <p>$(post["text"].get)</p>
  </div>  
}
"""

proc indexHtml*(login:Login, posts:seq[JsonNode]): string =
  baseHtml(login, indexHtmlImpl(posts))
