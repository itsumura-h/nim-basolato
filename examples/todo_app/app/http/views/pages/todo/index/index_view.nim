import json, asyncdispatch
import ../../../../../../../../src/basolato/view
import ./index_view_model
import ../../../../../usecases/todo/display_index_usecase
import ../../../layouts/application_view
import ../../../layouts/todo/app_bar/app_bar_view
import ../../../layouts/todo/statuses/statuses_view
# import ../../../layouts/todo/status/status_view_model
# import ../../../layouts/todo/create_task_modal_view


proc impl(viewModel:IndexViewModel):Future[string] {.async.} =
  style "css", style:"""
    <style>
      .columns {
        max-width: 100%;
        margin: auto;
      }
    </style>
  """

  script ["idName"], script:"""
    <script>
    </script>
  """

  tmpli html"""
    $<style>
    <main>
      <header>
        $<appBarView(viewModel.appBarViewModel).await>
      </header>
      <section class="bulma-section">
        $if viewModel.isAdmin{
          <p><a href="/todo/create" class="bulma-button">
            <i class="fas fa-plus"></i>
            Create new task
          </a></p>
        }
      </section>
      $<statusesView(viewModel.statuses)>
    </main>
  """

proc indexView*(loginUser:JsonNode):Future[string] {.async.} =
  let title = ""
  let viewModel = IndexViewModel.new(loginUser).await
  return applicationView(title, impl(viewModel).await)
  # return applicationView(title, "")
