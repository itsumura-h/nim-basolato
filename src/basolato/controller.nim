when defined(httpbeast):
  import ./beta/controller
else:
  import ./std/controller

export controller
