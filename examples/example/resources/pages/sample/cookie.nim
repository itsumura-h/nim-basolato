import json
import ../../../../../src/basolato/view
import ../../layouts/application_view

proc impl(auth:Auth):string = tmpli html"""
<a href="/">go back</a>
<form method="post">
  $(csrfToken())
  <input type="text" name="key" placeholder="key">
  <input type="text" name="value" placeholder="value">
  <button type="submit">send</button>
</form>
<form method="post" action="/sample/cookie/update">
  $(csrfToken())
  <input type="text" name="key" placeholder="key">
  <input type="text" name="days" placeholder="days">
  <button type="submit">update expire</button>
</form>
<form method="post" action="/sample/cookie/delete">
  $(csrfToken())
  <input type="text" name="key" placeholder="key">
  <button type="submit">delete</button>
</form>
<form method="post" action="/sample/cookie/delete-all">
  $(csrfToken())
  <button type="submit">delete all</button>
</form>

<div id="display"></div>
<script>
  let cookies = document.cookie.split(';');
  let ul = document.createElement('ul');
  for (let i in cookies) {
    let cookieVal = cookies[i];
    let cookie = document.createElement('li');
    cookie.innerHTML = cookieVal;
    ul.appendChild(cookie);
  }
  document.getElementById('display').appendChild(ul);
</script>
"""

proc cookieView*(auth:Auth):string =
  let title = "Cookie"
  return applicationView(title, impl(auth))
