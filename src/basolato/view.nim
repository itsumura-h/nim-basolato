when defined(httpbeast):
  import ./beta/view
elif defined(httpx):
  import ./beta/view
else:
  import ./std/view

export view
