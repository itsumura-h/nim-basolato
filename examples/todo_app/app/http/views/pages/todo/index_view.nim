import json, asyncdispatch
import ../../../../../../../src/basolato/view
import ../../layouts/application_view
import ../../layouts/todo/app_bar_view
import ../../layouts/todo/status_view
import ../../layouts/todo/create_task_modal_view


proc impl(loginUser, data:JsonNode):Future[string] {.async.} =
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
          appBarView(loginUser["name"].getStr).await
        )
      </header>
      <section class="section">
        $if loginUser["auth"].getInt > 1{
          <p><a href="/todo/create" class="button">
            <i class="fas fa-plus"></i>
            Create new task
          </a></p>
        }
        <article class="columns $(style.element("columns"))">
          $for status in data["master"]["status"]{
            $(
              statusView(status, data).await
            )
          }
        </article>
      </section>
      $(
        createTaskModalView(
          script.element("createNewModal"),
          "toggleCreateTaskModal()",
          data["master"]["users"]
        )
        .await
      )
    </main>
  """

proc indexView*(loginUser, data:JsonNode):Future[string] {.async.} =
  let title = ""
  return applicationView(title, impl(loginUser, data).await)
