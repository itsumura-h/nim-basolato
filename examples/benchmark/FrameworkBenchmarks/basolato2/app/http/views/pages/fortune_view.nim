import
  std/asyncdispatch,
  std/json,
  basolato2/view


proc impl(title:string, rows:seq[JsonNode]):Future[Component] {.async.} =
  tmpli html"""
<!DOCTYPE html>
<html>

<head>
  <title>$(title)</title>
</head>

<body>
  <table>
    <tr>
      <th>id</th>
      <th>message</th>
    </tr>
    $for row in rows{
      <tr>
        <td>$(row["id"])</td>
        <td>$(row["message"])</td>
      </tr>
    }
  </table>
</body>

</html>
  """

proc fortuneView*(rows=newSeq[JsonNode]()):Future[string] {.async.} =
  let title = "Fortunes"
  return $impl(title, rows).await
