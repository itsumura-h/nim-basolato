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

proc tableView*(posts=newSeq[JsonNode]()):string = tmpli html"""
$(style.define())
<div class="container">
  $if posts.len > 0 {
    <table class="table is-striped $(style.get("table"))">
      <tr>
        <th>title</th><th>status</th><th>delete</th>
      </tr>
      $for post in posts {
        <tr>
          <td><a href="/$(post["id"].get)">$(post["title"].get)</a></td>
          <td>
            $if post["is_finished"].getBool {
              <form method="POST" action="/change-status/$(post["id"].get)">
                $(csrfToken())
                <button type="submit" name="status" value="false" class="button is-success is-light is-outlined">Finished</button>
              </form>
            }
            $else{
              <form method="POST" action="/change-status/$(post["id"].get)">
                $(csrfToken())
                <button type="submit" name="status" value="true" class="button is-danger is-light is-outlined">Not finished</button>
              </form>
            }
          </td>
          <td>
            <form method="POST" action="/delete/$(post["id"].get)">
              $(csrfToken())
              <button type="submit" class="delete is-large">delete</button>
            </form>
          </td>
        </tr>
      }
    </table>
  }
  $else{
    <p>post not found</p>
  }
</div>
"""
