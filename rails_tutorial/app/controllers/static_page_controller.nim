from strutils import parseInt
# framework
import ../../../src/basolato/controller
# view
import ../../resources/static_pages/home
import ../../resources/static_pages/help
import ../../resources/static_pages/about
import ../../resources/static_pages/contact


type StaticPageController* = ref object of Controller

proc newStaticPageController*(request:Request):StaticPageController =
  return StaticPageController.newController(request)


proc home*(this:StaticPageController):Response =
  return render(this.view.homeHtml())

proc help*(this:StaticPageController):Response =
  return render(this.view.helpHtml())

proc about*(this:StaticPageController):Response =
  return render(this.view.aboutHtml())

proc contact*(this:StaticPageController):Response =
  return render(this.view.contactHtml())



proc index*(this:StaticPageController):Response =
  return render("index")

proc show*(this:StaticPageController, id:string):Response =
  block:
    let id = id.parseInt
    return render("show")

proc create*(this:StaticPageController):Response =
  return render("create")

proc store*(this:StaticPageController):Response =
  return render("store")

proc edit*(this:StaticPageController, id:string):Response =
  block:
    let id = id.parseInt
    return render("edit")

proc update*(this:StaticPageController, id:string):Response =
  block:
    let id = id.parseInt
    return render("update")

proc destroy*(this:StaticPageController, id:string):Response =
  block:
    let id = id.parseInt
    return render("destroy")
