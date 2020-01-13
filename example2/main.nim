import basolato/routing

import middleware/custom_headers
import basolato/sample/controllers/SampleController

routes:
  error Http404:
    http404Route

  error Exception:
    exceptionRoute

  get "/":
    route(SampleController.index())

runForever()
