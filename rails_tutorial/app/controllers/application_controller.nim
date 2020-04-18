from strutils import parseInt
# framework
import ../../../src/basolato/controller


type ApplicationController* = ref object of Controller

proc newApplicationController*(request:Request):ApplicationController =
  return ApplicationController.newController(request)


proc hello*(this:ApplicationController):Response =
  return render("hello")




proc index*(this:ApplicationController):Response =
  return render("index")

proc show*(this:ApplicationController, id:string):Response =
  block:
    let id = id.parseInt
    return render("show")

proc create*(this:ApplicationController):Response =
  return render("create")

proc store*(this:ApplicationController):Response =
  return render("store")

proc edit*(this:ApplicationController, id:string):Response =
  block:
    let id = id.parseInt
    return render("edit")

proc update*(this:ApplicationController, id:string):Response =
  block:
    let id = id.parseInt
    return render("update")

proc destroy*(this:ApplicationController, id:string):Response =
  block:
    let id = id.parseInt
    return render("destroy")
