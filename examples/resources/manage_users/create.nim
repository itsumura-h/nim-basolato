import templates

proc create_html*(): string = tmpli html"""
<h1>ManageUsers create</h1>
<p><a href="../">戻る</a></p>
<form action="/ManageUsers/" method="POST">
  <table border="1">
    <tr>
      <td>name</td>
      <td><input type="text" name="name"></td>
    </tr>
    <tr>
      <td>email</td>
      <td><input type="text" name="email"></td>
    </tr>
    <tr>
      <td>birth_date</td>
      <td><input type="text" name="birth_date"></td>
    </tr>
    <tr>
      <td><button type="submit">送信</button></td>
      <td></td>
    </tr>
  </table>
</form>
"""