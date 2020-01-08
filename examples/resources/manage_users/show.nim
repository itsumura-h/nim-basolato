import templates
import json

proc show_html*(user: JsonNode): string = tmpli html"""
<h1>ManageUsers show</h1>
<p><a href="/ManageUsers">戻る</a></p>
<table border="1">
  $for key, value in user.pairs {
    <tr>
      <td>$(key)</td>
      <td>$(value)</td>
    </tr>
  }
</table>
"""