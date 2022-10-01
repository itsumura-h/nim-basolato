when defined(httpbeast):
  import ./beta/middleware
elif defined(httpx):
  import ./beta/middleware
else:
  import ./std/middleware

export middleware
