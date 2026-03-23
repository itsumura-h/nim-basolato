import basolato/view
import ./app_layout_model
import ../head/head_layout
import ../navbar/navbar_layout
import ../footer/footer_layout

proc appLayout*(appLayoutModel: AppLayoutModel): Component =
  tmpl"""
    <!DOCTYPE html>
    <html lang="en">
    $( headLayout(appLayoutModel.headLayoutModel) )
    <body>
      $( navbarLayout(appLayoutModel.navbarLayoutModel) )
      <div id="app-body">
        $(appLayoutModel.body)
      </div>
      $( footerLayout() )
    </body>
    </html>
  """
