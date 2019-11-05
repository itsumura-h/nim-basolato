import json
import jester
import ../../src/shihotsuchi/controller

# type RootController* = ref object of BaseController


# proc root*(this:RootController):Response =
#   return this.render("root")

# proc root500*(this:RootController):Response =
#   return this.render(Http500, "500")


# proc json*(this:RootController):Response =
#   let r = %*{"message": "json response"}
#   return this.render(r)

# proc json500*(this:RootController):Response =
#   let r = %*{"message": "json 500 response"}
#   return this.render(Http500, r)


proc root*():Response =
  return render("root")

proc root500*():Response =
  return render(Http500, "500")


proc json*():Response =
  let r = %*{"message": "json response"}
  return render(r)

proc json500*():Response =
  let r = %*{"message": "json 500 response"}
  return render(Http500, r)
  