import basolato/view
import ../../app/models

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

proc fortuneView*(this:View, data=newSeq[Fortune]()):string =
  let title = "Fortunes"
  return impl(title, data)
