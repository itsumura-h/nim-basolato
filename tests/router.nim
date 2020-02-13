import asyncdispatch, httpcore, re, tables
# framework
import ../src/basolato/routing
import ../src/basolato/middleware

import controller

routes:
  get "/renderStr": route(newTestController(request).renderStr())