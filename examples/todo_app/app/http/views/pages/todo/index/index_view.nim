import
  std/json,
  std/asyncdispatch,
  ../../../../../../../../src/basolato/view,
  ../../../../../usecases/todo/display_index_usecase,
  ../../../layouts/application_view,
  ../../../layouts/todo/app_bar/app_bar_view,
  ../../../layouts/todo/statuses/statuses_view,
  ./index_view_model


proc impl(viewModel:IndexViewModel):Future[string] {.async.} =
  style "css", style:"""
    <style>
      .columns {
        max-width: 100%;
        margin: auto;
      }
    </style>
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
