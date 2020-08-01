import json
import ../../../../src/basolato/controller

proc root*(request:Request):Response =
  let params = request.params
  return render("<h1>root</h1>")

proc rootPost*(request:Request):Response =
  let params = request.body
  return render(%*params)

proc root500*():Response =
  return render(Http500, "500")


proc json*():Response =
  let r = %*{"message": "json response"}
  return render(r)

proc json500*():Response =
  let r = %*{"message": "json 500 response"}
  return render(Http500, r)



# type RootController* = ref object of BaseController


# proc root*(this:RootController):Response =
#   return this.render("root")

# proc rootPost*(this:RootController):Response =
#   let params = this.getRequest().body
#   return this.render(%*params)

# proc root500*(this:RootController):Response =
#   return this.render(Http500, "500")


# proc json*(this:RootController):Response =
#   let r = %*{"message": "json response"}
#   return this.render(r)

# proc json500*(this:RootController):Response =
#   let r = %*{"message": "json 500 response"}
#   return this.render(Http500, r)
