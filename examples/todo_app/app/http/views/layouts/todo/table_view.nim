import json
import ../../../../../../../src/basolato/view

let style = block:
  var css = newCss()
  css.set("table", "", """
    width: 100%;
  """)
  css.set("table", "td", """
    text-align: center;
  """)
  css

proc tableView*(todos=newSeq[JsonNode]()):string = tmpli html"""
$(style.define())
<div class="container">
  $if todos.len > 0 {
    <table class="table is-striped $(style.get("table"))">
      <tr>
        <th>title</th><th>status</th><th>delete</th>
      </tr>
      $for todo in todos {
        <tr>
          <td><a href="/$(todo["id"].get)">$(todo["title"].get)</a></td>
          <td>
            $if todo["is_finished"].getBool {
              <form method="POST" action="/change-status/$(todo["id"].get)">
                $(csrfToken())
                <button type="submit" name="status" value="false" class="button is-success is-light is-outlined">Finished</button>
              </form>
            }
            $else{
              <form method="POST" action="/change-status/$(todo["id"].get)">
                $(csrfToken())
                <button type="submit" name="status" value="true" class="button is-danger is-light is-outlined">Not finished</button>
              </form>
            }
          </td>
          <td>
            <form method="POST" action="/delete/$(todo["id"].get)">
              $(csrfToken())
              <button type="submit" class="delete is-large">delete</button>
            </form>
          </td>
        </tr>
      }
    </table>
  }
  $else{
    <p>todo not found</p>
  }
</div>
"""
