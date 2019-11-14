import ../../../src/basolato/controller
# html
import ../../resources/toppages/vue
import ../../resources/toppages/react


proc index*(): Response =
  return render(html("toppages/index.html"))

proc react*(): Response =
  let message = "React Installed"
  return render(reactHtml(message))

proc vue*(): Response =
  let message = "Vue Installed"
  return render(vueHtml(message))
