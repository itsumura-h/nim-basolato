import tables, json
from strutils import join
# framework
import basolato/middleware


proc customHeader*():Headers =
  let arr = [
    ("Middleware-Header-arr-Key1", "Middleware-Header-Val1"),
    ("Middleware-Header-arr-Key2", ["val1", "val2", "val3"].join(", "))
  ].toHeaders()

  let arr2 = {
    "Middleware-Header-arr2-Key1": "Middleware-Header-Val1",
    "Middleware-Header-arr2-Key2": ["val1", "val2", "val3"].join(", ")
  }.toHeaders()

  let table = {
    "Middleware-Header-table-Key1": "Middleware-Header-Val1",
    "Middleware-Header-table-Key2": ["val1", "val2", "val3"].join(", ")
  }.toTable().toHeaders()

  let jsonArr = %*{
    "Middleware-Header-json-Key1": "Middleware-Header-Val1",
    "Middleware-Header-json-Key2": ["val1", "val2", "val3"].join(", ")
  }
  let jsonArrHeader = jsonArr.toHeaders()

  return arr & arr2 & table & jsonArrHeader

proc corsHeader*(): Headers =
  var allowedMethods = @[
    "OPTIONS",
    "GET",
    "POST",
    "PUT",
    "DELETE"
  ]

  var allowedHeaders = @[
    "X-login-id",
    "X-login-token"
  ]

  return {
    "Cache-Control": "no-cache",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": allowedMethods.join(", "),
    "Access-Control-Allow-Headers": allowedHeaders.join(", ")
  }.toHeaders()


proc secureHeader*(): Headers =
  return [
    ("Strict-Transport-Security", ["max-age=63072000", "includeSubdomains"].join(", ")),
    ("X-Frame-Options", "SAMEORIGIN"),
    ("X-XSS-Protection", ["1", "mode=block"].join(", ")),
    ("X-Content-Type-Options", "nosniff"),
    ("Referrer-Policy", ["no-referrer", "strict-origin-when-cross-origin"].join(", ")),
    ("Cache-control", ["no-cache", "no-store", "must-revalidate"].join(", ")),
    ("Pragma", "no-cache"),
  ].toHeaders()
