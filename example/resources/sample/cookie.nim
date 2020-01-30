import ../../../src/basolato/view

proc cookieHtml*(auth:Auth): string = tmpli html("""
<form method="post">
  <input type="text" name="key">
  <input type="text" name="value">
  <button type="submit">send</button>
</form>
<form method="post" action="/sample/cookie/update">
  <input type="text" name="key">
  <input type="text" name="days" placeholder="days">
  <button type="submit">update expire</button>
</form>
<form method="post" action="/sample/cookie/delete">
  <input type="text" name="key">
  <button type="submit">delete</button>
</form>
<form method="post" action="/sample/cookie/delete-all">
  <button type="submit">deleteAll</button>
</form>

<div id="display"></div>
<script>
  let list = document.cookie.split(';');
  document.getElementById('display').innerHTML = list;
</script>
""")