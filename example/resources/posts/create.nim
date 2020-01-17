import ../../../src/basolato/view
import base

proc implCreateHtml(): string = tmpli html"""
<h2>New Post</h2>
<form method="post">
  $(csrfToken())
  <div>
    <p>Title</p>
    <p><input type="text" name="title"></p>
  </div>
  <div>
    <p>Text</p> 
    <textarea name="text"></textarea>
  </div>
  <button type="submit">create</button>
</form>
"""

proc createHtml*(): string =
  baseHtml(implCreateHtml())
