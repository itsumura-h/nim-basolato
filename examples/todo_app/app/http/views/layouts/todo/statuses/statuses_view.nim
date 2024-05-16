import
  std/asyncdispatch,
  std/json,
  std/sequtils,
  ../../../../../../../../src/basolato/view,
  ./statuses_view_model,
  ./status/status_view


proc statusesView*(viewModel:StatusesViewModel):Component =
  let style = styleTmpl(Css, """
    <style>
      .columns {
        max-width: 100%;
        margin: auto;
      }
    </style>
  """)

  tmpl"""
    $(style)
    <section class="bulma-section">
      <article class="bulma-columns $(style.element("columns"))">
        $for key, status in viewModel.statuses.pairs{
          $(statusView(status))        
        }
      </article>
    </section>
  """
