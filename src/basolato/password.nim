when defined(httpbeast):
  import ./beta/password
elif defined(httpx):
  import ./beta/password
else:
  import ./std/password

export password
