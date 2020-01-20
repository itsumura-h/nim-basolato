import json
# import ../../../src/basolato/view
import ../../../src/basolato/private
import ../../../src/basolato/session
import ../base


proc editHtmlImpl*(login:Login, id:int, title:string, text:string, errors:JsonNode):string = tmpli html"""
<h2>Edit Post</h2>
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

proc editHtml*(login:Login, id:int, title="", text="", errors=newJObject()):string =
  baseHtml(login, editHtmlImpl(login, id, title, text, errors))