import ../../../../../../src/basolato/view
import head_view


proc applicationView*(title:string, body:Component):Component =
  tmpli html"""
    <!DOCTYPE html>
    <html lang="en">
      $(headView(title))
    <body>
      <script src="/js/alpine.min.js"></script>
      $(body)
    </body>
    </html>
  """
