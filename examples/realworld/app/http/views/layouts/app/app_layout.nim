import std/asyncdispatch
import basolato/view
import ./app_layout_model
import ../head/head_layout
import ../navbar/navbar_layout
import ../footer/footer_layout

proc appLayout*(appLayoutModel: AppLayoutModel, body: Component): Component =
  tmpl"""
    <!DOCTYPE html>
    <html lang="en">
    $( headLayout(appLayoutModel.headLayoutModel) )
    <body>
      $( navbarLayout(appLayoutModel.navbarLayoutModel) )
      <div id="app-body">
        $(body)
      </div>
      $( footerLayout() )
    </body>
    </html>
  """


proc appLayout*(context: Context, title: string, body: Component): Future[Component] {.async.} =
  let model = await AppLayoutModel.new(context, title)
  return appLayout(model, body)
