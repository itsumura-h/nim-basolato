import basolato/routing

import config/custom_headers
import basolato/sample/controllers/SampleController

routes:
  get "/":
    route(SampleController.index())

runForever()
