import json
import basolato/view
import ../layouts/application_view

style "css", style:"""
.className {
}
"""

proc impl(rows:seq[JsonNode]):string = tmpli html"""
<!doctype html>
  <html>
  <head>
    <title>Fortunes</title>
  </head>
  <body>
    <table>
      <tr>
        <th>id</th>
        <th>message</th>
        </tr>
      $for row in rows{
        <tr>
          <td>$(row["id"].get)</td>
          <td>$(row["message"].get)</td>
        </tr>
      }
  </table>
  </body>
</html>
"""

proc fortuneView*(rows=newSeq[JsonNode]()):string =
  return impl(rows)
