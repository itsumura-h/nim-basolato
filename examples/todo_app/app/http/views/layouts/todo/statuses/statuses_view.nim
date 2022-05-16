import
  std/asyncdispatch,
  std/json,
  std/sequtils,
  ../../../../../../../../src/basolato/view,
  ./statuses_view_model,
  ./status/status_view


proc statusesView*(viewModel:StatusesViewModel):string =
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
    $<script>  
    <section class="bulma-section">
      <article class="bulma-columns $(style.element("columns"))">
        $for key, status in viewModel.statuses.pairs{
          $<statusView(status)>        
        }
      </article>
    </section>
  """
