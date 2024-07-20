import ../../../../../../../src/basolato/view
import ../head/head_layout
import ./app_layout_model


proc appLayout*(appLayoutModel:AppLayoutModel, body:Component):Component =
  tmpl"""
    <!DOCTYPE html>
    <html lang="en">
      $(headLayout(appLayoutModel.headLayoutModel))
    <body>
      $(body)
    </body>
    </html>
  """
