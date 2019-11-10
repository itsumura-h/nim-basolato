import templates
import json

proc show_html*(user: JsonNode): string = tmpli html"""
<h1>ManageUsers show</h1>
<p><a href="../">戻る</a></p>
<table border="1">
  $for key, value in user {
    <tr>
      <td>$(key)</td>
      <td>$(value.str)</td>
    </tr>
  }
</table>
"""