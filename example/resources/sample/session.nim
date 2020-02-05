import ../../../src/basolato/view

proc sessionHtml*(auth:Auth, sessions:openArray[string]=[]): string = tmpli html("""
<form method="post">
  <input type="text" name="key">
  <input type="text" name="value">
  <button type="submit">send</button>
</form>
<form method="post" action="/sample/session/update">
  <input type="text" name="key">
  <input type="text" name="days" placeholder="days">
  <button type="submit">update expire</button>
</form>
<form method="post" action="/sample/session/delete">
  <input type="text" name="key">
  <button type="submit">delete</button>
</form>
<form method="post" action="/sample/session/delete-all">
  <button type="submit">deleteAll</button>
</form>

<ul>
  $for row in sessions {
    <li>$row</li>
  }
</ul>
""")