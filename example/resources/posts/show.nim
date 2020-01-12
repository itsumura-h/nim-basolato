import templates, json

proc showHtml*(post:JsonNode):string = tmpli html"""
<p><a href="/MVCPosts">Back</a></p>
<h1>show</h1>
<h2>$(post["id"].getInt) | $(post["title"].getStr)</h2>
<p>By $(post["user"].getStr)</p>

<div>
  $(post["post"].getStr)
</div>
<hr>
<a href="/MVCPosts/$(post["id"].getInt)/edit">Edit</a>
"""
