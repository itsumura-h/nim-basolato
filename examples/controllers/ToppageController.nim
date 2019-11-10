import ../../src/basolato/controller
# html
include ../resources/templates/toppages/index
include ../resources/templates/toppages/vue
include ../resources/templates/toppages/react


proc index*(): Response =
  return render(indexHtml())

proc react*(): Response =
  let message = "React Installed"
  return render(reactHtml(message))

proc vue*(): Response =
  let message = "Vue Installed"
  return render(vueHtml(message))
