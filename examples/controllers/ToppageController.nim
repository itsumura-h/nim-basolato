import ../../src/basolato/controller
# html
include ../resources/toppages/index
include ../resources/toppages/vue
include ../resources/toppages/react


proc index*(): Response =
  return render(indexHtml())

proc react*(): Response =
  let message = "React Installed"
  return render(reactHtml(message))

proc vue*(): Response =
  let message = "Vue Installed"
  return render(vueHtml(message))
