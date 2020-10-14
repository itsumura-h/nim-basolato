import basolato/view
import ../../layouts/application_view

proc impl():string = tmpli html"""
<a href="/">go back</a>
<form method="POST" enctype="multipart/form-data">
  $(csrfToken())
  <p>
    <span>image file named [test.jpg]</span>
    <input type="file" name="img">
  </p>
  <button type="submit">upload</button>
</form>
<form method="POST" action="/sample/file-upload/delete">
  $(csrfToken())
  <button type="submit">delete</button>
</form>

<div>
  <img src="/sample/test.jpg">
  <img src="/sample/image.jpg">
</div>
"""

proc fileUploadView*():string =
  let title = "File upload"
  return applicationView(title, impl())
