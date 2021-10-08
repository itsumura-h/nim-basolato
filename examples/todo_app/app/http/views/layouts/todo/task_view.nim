import json
import ../../../../../../../src/basolato/view


proc taskView*(todo:JsonNode, isDisplayUp, isDisplayDown:bool, upId:string,
      upSortNum:int, downId:string, downSortNum:int):string =
  style "css", style:"""
    <style>
      .columns {
        max-width: 100%;
        margin: auto;
      }
      .task {
        margin: 12px 0px;
      }
      .form {
        padding: 0;
      }
      .button {
        width: 100%;
        height: 100%;
      }
    </style>
  """

  script ["idName"], script:"""
    <script>
    </script>
  """

  tmpli html"""
    $(style)
    <article class="card $(style.element("task"))">
      <div class="card-header columns $(style.element("columns"))">
        $if isDisplayUp {
          <form method="POST" action="/todo/change-sort" class="column $(style.element("form"))">
            $(csrfToken())
            <button class="button $(style.element("button"))">
              <span class="icon"><i class="fas fa-arrow-up"></i></span>
            </button>
            <input type="hidden" name="id" value="$(todo["id"].get)">
            <input type="hidden" name="next_id" value="$(upId)">
          </form>
        }
        $if isDisplayDown {
          <form method="POST" action="/todo/change-sort" class="column $(style.element("form"))">
            $(csrfToken())
            <button class="button $(style.element("button"))">
              <span class="icon"><i class="fas fa-arrow-down"></i></span>
            </button>
            <input type="hidden" name="id" value="$(todo["id"].get)">
            <input type="hidden" name="next_id" value="$(downId)">
          </form>
        }
      </div>
      <div class="card-content">
        <div class="content">
          <p>$(todo["title"].get)</p>
          <p>created: $(todo["created_name"].get)</p>
          <p>assign: $(todo["assign_name"].get)</p>
          <p>start: $(todo["start_on"].get)</p>
          <p>end_on: $(todo["end_on"].get)</p>
        </div>
      </div>
    </article>
  """
