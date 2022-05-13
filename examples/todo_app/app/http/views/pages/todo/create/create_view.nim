import json
import ../../../../../../../../src/basolato/view
import ../../../layouts/application_view
import ./create_view_model


proc impl(viewModel:CreateViewModel):string =
  style "css", style:"""
    <style>
      .className {
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
    <section class="section">
      <form method="POST">
        $(csrfToken())
        <h3 class="title is-3">Create new task</h3>
        <div class="field">
          <div class="control">
            <input type="text" name="title" value="$(old(viewModel.params, "title"))" placeholder="title" class="input">
          </div>
          $if viewModel.errors.hasKey("title"){
            <aside>
              $for error in viewModel.errors["title"]{
                <p class="help is-danger">$(error.get)</p>
              }
            </aside>
          }
        </div>
        <div class="field">
          <div class="control">
            <textarea name="content" placeholder="content" class="textarea has-fixed-size">$(old(viewModel.params, "content"))</textarea>
          </div>
          $if viewModel.errors.hasKey("title"){
            <aside>
              $for error in viewModel.errors["title"]{
                <p class="help is-danger">$(error.get)</p>
              }
            </aside>
          }
        </div>
        <div class="field">
          <div class="control select">
            <select name="assign_to">
              <option disabled style='display:none;'
                $if old(viewModel.params, "assign_to").len == 0{
                  selected
                }
              >
                assign to...
              </option>
              $for user in viewModel.users{
                <option
                  value="$(user["id"].get)"
                  $if old(viewModel.params, "assign_to") == user["id"].get{
                    selected
                  }
                >
                  $(user["name"].get)
                </option>
              }
            </select>
          </div>
          $if viewModel.errors.hasKey("assign_to"){
            <aside>
              $for error in viewModel.errors["assign_to"]{
                <p class="help is-danger">$(error.get)</p>
              }
            </aside>
          }
        </div>
        <div class="field">
          <label class="label">start date</label>
          <div class="control">
            <input type="date" name="start_on" value="$(old(viewModel.params, "start_on"))">
          </div>
          $if viewModel.errors.hasKey("start_on"){
            <aside>
              $for error in viewModel.errors["start_on"]{
                <p class="help is-danger">$(error.get)</p>
              }
            </aside>
          }
        </div>
        <div class="field">
          <label class="label">Due date</label>
          <div class="control">
            <input type="date" name="end_on" value="$(old(viewModel.params, "end_on"))">
          </div>
          $if viewModel.errors.hasKey("end_on"){
            <aside>
              $for error in viewModel.errors["end_on"]{
                <p class="help is-danger">$(error.get)</p>
              }
            </aside>
          }
        </div>
        <div class="field">
          <div class="control">
            <button type="submit" class="button is-link">submit</button>
          </div>
        </div>
      </form>
    </section>
  """

proc createView*(params, errors, data:JsonNode):string =
  let title = ""
  let viewModel = CreateViewModel.new(
    params,
    errors,
    data["statuses"].getElems,
    data["users"].getElems
  )
  return applicationView(title, impl(viewModel))
