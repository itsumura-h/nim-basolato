import json
# framework
import ../../../src/basolato/view
import ../base

proc createHtmlImpl(login:Login, title:string, text:string, errors:JsonNode): string = tmpli html"""
<h2>New Post</h2>
<form method="post">
  $(csrfToken(login))
  <div>
    <p>Title</p>
    $if errors.hasKey("title") {
      <p><li>$(errors["title"].getStr)</li></p>
    }
    <p><input type="text" value="$title" name="title"></p>
  </div>
  <div>
    <p>Text</p> 
    $if errors.hasKey("text") {
      <p><li>$(errors["text"].getStr)</li></p>
    }
    <textarea name="text">$text</textarea>
  </div>
  <button type="submit">create</button>
</form>
"""

proc createHtml*(login:Login, title="", text="", errors=newJObject()): string =
  baseHtml(login, createHtmlImpl(login, title, text, errors))
