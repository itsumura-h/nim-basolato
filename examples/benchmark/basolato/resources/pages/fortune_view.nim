import basolato/view
import ../../app/domain/models/fortune/fortune_entity

proc impl(title:string, data:seq[Fortune]):string = tmpli html"""
<!DOCTYPE html>
<html>

<head>
  <title>$title</title>
</head>

<body>
  <table>
    <tr>
      <th>id</th>
      <th>message</th>
    </tr>
    $for row in data{
      <tr>
        <td>$(row.id)</td>
        <td>$(row.message)</td>
      </tr>
    }
  </table>
</body>

</html>
"""

proc fortuneView*(data=newSeq[Fortune]()):string =
  let title = "Fortunes"
  return impl(title, data)
