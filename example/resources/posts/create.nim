import templates
import ../../../src/basolato/view

proc createHtml*(): string = tmpli html"""
<h2>New Post</h2>
<form method="post">
  $(csrf_token())
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