import json
import ../../../../../../../../src/basolato/view
import ../../../layouts/application_view
import ./create_view_model


proc impl(viewModel:CreateViewModel):Component =
  let style = styleTmpl(Css, """
    <style>
      .className {
      }
    </style>
  """)

  tmpli html"""
    $(style)
    <section class="bulma-section">
      <p>
        <a href="/todo">back</a>
      </p>
    </section>
    <section class="bulma-section">
      <form method="POST">
        $(csrfToken())
        <h3 class="bulma-title is-3">Create new task</h3>
        <div class="bulma-field">
          <div class="bulma-control">
            <input type="text" name="title" value="$(old(viewModel.params, "title"))" placeholder="title" class="bulma-input">
          </div>
          $if viewModel.errors.hasKey("title"){
            <aside>
              $for error in viewModel.errors["title"]{
                <p class="bulma-help bulma-is-danger">$(error)</p>
              }
            </aside>
          }
        </div>
        <div class="bulma-field">
          <div class="bulma-control">
            <textarea name="content" placeholder="content" class="bulma-textarea bulma-has-fixed-size">$(old(viewModel.params, "content"))</textarea>
          </div>
          $if viewModel.errors.hasKey("title"){
            <aside>
              $for error in viewModel.errors["title"]{
                <p class="bulma-help bulma-is-danger">$(error)</p>
              }
            </aside>
          }
        </div>
        <div class="bulma-field">
          <div class="bulma-control bulma-select">
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
                  value="$(user["id"])"
                  $if old(viewModel.params, "assign_to") == user["id"].getStr{
                    selected
                  }
                >
                  $(user["name"])
                </option>
              }
            </select>
          </div>
          $if viewModel.errors.hasKey("assign_to"){
            <aside>
              $for error in viewModel.errors["assign_to"]{
                <p class="bulma-help bulma-is-danger">$(error)</p>
              }
            </aside>
          }
        </div>
        <div class="bulma-field">
          <label class="bulma-label">start date</label>
          <div class="bulma-control">
            <input type="date" name="start_on" value="$(old(viewModel.params, "start_on"))">
          </div>
          $if viewModel.errors.hasKey("start_on"){
            <aside>
              $for error in viewModel.errors["start_on"]{
                <p class="bulma-help bulma-is-danger">$(error)</p>
              }
            </aside>
          }
        </div>
        <div class="bulma-field">
          <label class="bulma-label">Due date</label>
          <div class="bulma-control">
            <input type="date" name="end_on" value="$(old(viewModel.params, "end_on"))">
          </div>
          $if viewModel.errors.hasKey("end_on"){
            <aside>
              $for error in viewModel.errors["end_on"]{
                <p class="bulma-help bulma-is-danger">$(error)</p>
              }
            </aside>
          }
        </div>
        <div class="bulma-field">
          <div class="bulma-control">
            <button type="submit" class="bulma-button bulma-is-link">submit</button>
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
  return $applicationView(title, impl(viewModel))
