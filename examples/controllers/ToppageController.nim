# html
include ../resources/templates/toppages/index
include ../resources/templates/toppages/vue
include ../resources/templates/toppages/react

type ToppageController = ref object of RootObj
export ToppageController

proc index*(this: ToppageController): string =
  return indexHtml()

proc react*(this: ToppageController): string =
  let message = "React Installed"
  return reactHtml(message)

proc vue*(this: ToppageController): string =
  let message = "Vue Installed"
  return vueHtml(message)