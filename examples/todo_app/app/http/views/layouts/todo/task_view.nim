import json
import ../../../../../../../src/basolato/view


proc taskView*(todo:JsonNode, isDisplayUp, isDisplayDown:bool, upSortNum, downSortNum:int):string =
  style "css", style:"""
    <style>
      .columns {
        max-width: 100%;
        margin: auto;
      }
      .task{
        margin: 12px 0px;
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
          <button class="column button" onclick="console.log($(upSortNum))">
            <span class="icon"><i class="fas fa-arrow-up"></i></span>
          </button>
        }
        $if isDisplayDown {
          <button class="column button" onclick="console.log($(downSortNum))">
            <span class="icon"><i class="fas fa-arrow-down"></i></span>
          </button>
        }
      </div>
      <div class="card-content">
        <div class="content">
          <p>$(todo["title"].get)</p>
          <p>created: $(todo["created_name"].get)</p>
          <p>assign: $(todo["assign_name"].get)</p>
          <p>start: $(todo["start_on"].get)</p>
          <p>end_on: $(todo["end_on"].get)</p>
          <p>sort: $(todo["sort"].get)</p>
        </div>
      </div>
    </article>
  """
