import templates, json
import ../../../src/basolato/view

proc indexHtml*(posts:seq[JsonNode]):string = tmpli html"""
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