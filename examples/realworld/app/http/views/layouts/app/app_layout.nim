import std/asyncdispatch
import basolato/view
import ../head/head_layout
import ../navbar/navbar_layout
import ../footer/footer_layout


proc appLayout*(title:string, body:Component):Future[Component] {.async.} =
  tmpl"""
    <!DOCTYPE html>
    <html lang="en">
    $( headLayout(title) )
    <body>
      $( navbarLayout().await )
      <div id="app-body">
        $(body)
      </div>
      $( footerLayout() )
    </body>
    </html>
  """
