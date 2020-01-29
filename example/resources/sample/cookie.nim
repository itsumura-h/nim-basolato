import ../../../src/basolato/view

proc cookieHtml*(auth:Auth): string = tmpli html("""
<form method="post">
  <input type="text" name="key">
  <input type="text" name="value">
  <button type="submit">送信</button>
</form>
<form method="post" action="/sample/cookie/delete">
  <button type="submit">削除</button>
</form>
<div id="display"></div>
<script>
  let list = document.cookie.split(';');
  document.getElementById('display').innerHTML = list;
</script>
""")