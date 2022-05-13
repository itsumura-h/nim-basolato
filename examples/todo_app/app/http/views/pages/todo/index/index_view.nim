import json, asyncdispatch
import ../../../../../../../../src/basolato/view
import ./index_view_model
import ../../../../../usecases/todo/display_index_usecase
import ../../../layouts/application_view
import ../../../layouts/todo/app_bar/app_bar_view
import ../../../layouts/todo/status/status_view
import ../../../layouts/todo/status/status_view_model
import ../../../layouts/todo/create_task_modal_view


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
    $(style)
    <main>
      <header>
        $(
          appBarView(viewModel.appBarViewModel).await
        )
      </header>
      <section class="section">
        $if viewModel.isAdmin{
          <p><a href="/todo/create" class="button">
            <i class="fas fa-plus"></i>
            Create new task
          </a></p>
        }
        <article class="columns $(style.element("columns"))">
          $for status in viewModel.statuses{
            $if status.name == "todo"{
              $(statusView(status, viewModel.todo).await)
            }
            $elif status.name == "doing"{
              $(statusView(status, viewModel.doing).await)
            }
            $elif status.name == "done"{
              $(statusView(status, viewModel.done).await)
            }
          }
        </article>
      </section>
      $(
        createTaskModalView(
          script.element("createNewModal"),
          "toggleCreateTaskModal()",
          viewModel.users
        ).await
      )
    </main>
  """

proc indexView*(loginUser:JsonNode):Future[string] {.async.} =
  let title = ""
  let viewModel = IndexViewModel.new(loginUser).await
  return applicationView(title, impl(viewModel).await)
