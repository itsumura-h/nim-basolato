import json
import ../../../../src/basolato/view
import ../layouts/application

proc impl(todos:seq[JsonNode]):string = tmpli html"""
<a href="/logout">logout</a>
<form method="POST">
  $(csrfToken())
  <input type="text" name="todo">
  <button type="submit">add</button>
</form>
<p><a</p>

  $if todos.len > 0{
      <table>
        $for todo in todos{
          <tr>
            <td>$(todo["todo"].get)</td>
            <td>
              <a href="/$(todo["id"].get)">detail</a>
            </td>
            <td>
              <form method="post" action="/$(todo["id"].get)/delete">
                $(csrfToken())
                <button type="submit">delete</button>
              </form>
            </td>
          </tr>
        }
      </table>
    </form>
  }
</form>
"""

proc todoView*(this:View, todos:seq[JsonNode]):string =
  let title = "todo"
  return this.applicationView(title, impl(todos))
