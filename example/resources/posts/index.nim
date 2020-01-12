import templates, json
import ../../../src/basolato/view

proc indexHtml*(posts:seq[JsonNode]):string = tmpli html"""
<p><a href="/">toppage</a></p>
<h1>index</h1>
<table border=1>
  <tr>
    <th>id</th><th>title</th><th>user</th><th>detail</th>
  </tr>
  $for post in posts {
    <tr>
      <td>$(post["id"].get)</td>
      <td>$(post["title"].get)</td>
      <td>$(post["user"].get)</td>
      <td><a href="/MVCPosts/$(post["id"].get)">detail</a></td>
    </tr>
  }
</table>
"""
