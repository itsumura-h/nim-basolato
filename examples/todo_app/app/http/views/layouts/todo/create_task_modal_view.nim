import json, asyncdispatch
import ../../../../../../../src/basolato/view


proc createTaskModalView*(idName, toggleFuncName:string, users:JsonNode):Future[string] {.async.} =
  style "css", style:"""
    <style>
      .className {Future[string] {.async.}
      }
    </style>
  """

  script ["idName"], script:"""
    <script>
    </script>
  """

  tmpli html"""
    $(style)
    $(script)
    <div class="modal" id="$(idName)">
      <div onclick="$(toggleFuncName)" class="modal-background"></div>
      <div class="modal-content">
        <form method="POST" class="box">
          $(csrfToken())
          <h3 class="title is-3">Create new task</h3>
          <div class="field">
            <div class="control">
              <input type="text" name="title" placeholder="title" class="input">
            </div>
          </div>
          <div class="field">
            <div class="control">
              <textarea name="content" placeholder="content" class="textarea has-fixed-size"></textarea>
            </div>
          </div>
          <div class="field">
            <div class="control select">
              <select name="assign_to">
                <option disabled selected style='display:none;'>assign to...</option>
                $for user in users{
                  <option value="$(user["id"].get)">$(user["name"].get)</option>
                }
              </select>
            </div>
          </div>
          <div class="field">
            <div class="control">
              <input type="date" placeholder="start date">
            </div>
          </div>
          <div class="field">
            <div class="control">
              <input type="date" placeholder="Due date">
            </div>
          </div>
          <div class="field">
            <div class="control">
              <button type="submit" class="button is-link">submit</button>
            </div>
          </div>
        </form>
      </div>
      <button onclick="$(toggleFuncName)" class="modal-close is-large" aria-label="close"></button>
    </div>
  """
