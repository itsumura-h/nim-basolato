when defined(httpbeast):
  import ./beta/middleware
else:
  import ./std/middleware

export middleware
