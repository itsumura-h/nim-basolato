#? stdtmpl | standard
# import json
# # framework
# import ../../../src/basolato/view
# proc cookieHtml*(auth:Auth, errors=newJObject()): string =
<a href="/">go back</a>
<form method="post">
  ${csrfToken()}
  <input type="text" name="key">
  <input type="text" name="value">
  <button type="submit">send</button>
</form>
<form method="post" action="/sample/cookie/update">
  ${csrfToken()}
  <input type="text" name="key">
  <input type="text" name="days" placeholder="days">
  <button type="submit">update expire</button>
</form>
<form method="post" action="/sample/cookie/delete">
  ${csrfToken()}
  <input type="text" name="key">
  <button type="submit">delete</button>
</form>
<form method="post" action="/sample/cookie/delete-all">
  ${csrfToken()}
  <button type="submit">deleteAll</button>
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
