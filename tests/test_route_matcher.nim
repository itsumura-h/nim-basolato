discard """
  cmd: "nim c -r $file"
"""
# nim c -r -d:test ./test_route_matcher.nim

import std/asyncdispatch
import std/httpcore
import std/unittest
import ../src/basolato/core/params
import ../src/basolato/core/response
import ../src/basolato/core/route
import ../src/basolato/core/security/context

proc ok(_:Context):Future[Response] {.async.} =
  return render("ok")

suite("route matcher"):
  test("static route match"):
    let routes = Routes.merge(@[
      Route.get("/health", ok),
    ])

    let matched = routes.matchRoute(HttpGet, "/health")
    check not matched.route.isNil
    check matched.route.path == "/health"
    check matched.pathParams.isNil

  test("typed dynamic route match"):
    let routes = Routes.merge(@[
      Route.get("/users/{id:int}", ok),
      Route.get("/users/{name:str}", ok),
    ])

    let intMatched = routes.matchRoute(HttpGet, "/users/42")
    check not intMatched.route.isNil
    check intMatched.pathParams.getStr("id") == "42"

    let strMatched = routes.matchRoute(HttpGet, "/users/alice")
    check not strMatched.route.isNil
    check strMatched.pathParams.getStr("name") == "alice"

    # query string should not affect path matching
    let intWithQuery = routes.matchRoute(HttpGet, "/users/42?name=john")
    check not intWithQuery.route.isNil
    check intWithQuery.pathParams.getStr("id") == "42"

    let strWithQuery = routes.matchRoute(HttpGet, "/users/alice?age=20")
    check not strWithQuery.route.isNil
    check strWithQuery.pathParams.getStr("name") == "alice"

  test("typed dynamic route mismatch"):
    let routes = Routes.merge(@[
      Route.get("/{id:int}", ok),
      Route.get("/{name:str}", ok),
    ])

    let rootPath = routes.matchRoute(HttpGet, "/")
    check rootPath.route.isNil

    let intMultiSegment = routes.matchRoute(HttpGet, "/1/abc")
    check intMultiSegment.route.isNil

    let strMultiSegment = routes.matchRoute(HttpGet, "/john/1")
    check strMultiSegment.route.isNil

  test("static route has higher priority than dynamic route"):
    let routes = Routes.merge(@[
      Route.get("/users/new", ok),
      Route.get("/users/{id:int}", ok),
    ])

    let staticMatched = routes.matchRoute(HttpGet, "/users/new")
    check not staticMatched.route.isNil
    check staticMatched.route.path == "/users/new"
    check staticMatched.pathParams.isNil

    let dynamicMatched = routes.matchRoute(HttpGet, "/users/10")
    check not dynamicMatched.route.isNil
    check dynamicMatched.pathParams.getStr("id") == "10"

  test("head and options supplement is preserved"):
    let routes = Routes.merge(@[
      Route.get("/articles", ok),
      Route.post("/articles", ok),
      Route.post("/articles/{id:int}", ok),
    ])

    let headMatched = routes.matchRoute(HttpHead, "/articles")
    check not headMatched.route.isNil

    let optionsStaticMatched = routes.matchRoute(HttpOptions, "/articles")
    check not optionsStaticMatched.route.isNil

    let optionsDynamicMatched = routes.matchRoute(HttpOptions, "/articles/12")
    check not optionsDynamicMatched.route.isNil
    check optionsDynamicMatched.pathParams.getStr("id") == "12"

  test("group prefix route match"):
    let groupedRoutes = Route.group("/api", @[
      Route.get("/users/{id:int}", ok),
      Route.get("/users/new", ok),
    ])
    let routes = Routes.merge(@[groupedRoutes])

    let staticMatched = routes.matchRoute(HttpGet, "/api/users/new")
    check not staticMatched.route.isNil

    let dynamicMatched = routes.matchRoute(HttpGet, "/api/users/101")
    check not dynamicMatched.route.isNil
    check dynamicMatched.pathParams.getStr("id") == "101"
