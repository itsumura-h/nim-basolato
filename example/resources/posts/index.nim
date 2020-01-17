import json
import ../../../src/basolato/view
import base

proc implIndexHtml(posts:seq[JsonNode]):string = tmpli html"""
$for post in posts {
  <div class="post">
      <div class="date">
        <p>published: $(post["published_date"].get)</p>
      </div>
    <h2><a href="/WebBlog/$(post["id"].get)">$(post["title"].get)</a></h2>
    <p>$(post["text"].get)</p>
  </div>  
}
"""

proc indexHtml*(posts:seq[JsonNode]): string =
  baseHtml(implIndexHtml(posts))
