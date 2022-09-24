import std/asyncdispatch
import ../../../../../../../src/basolato/view
import ../../../../models/fortune

proc fortuneView*(rows:seq[Fortune]):Future[Component] {.async.} = tmpli html"""
<!DOCTYPE html>
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
        <td>$(row.id)</td>
        <td>$(row.message)</td>
      </tr>
    }
  </table>
</body>

</html>
"""
