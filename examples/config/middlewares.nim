import jester


template checkLogin*(request: Request) =
  try:
    let loginId = request.headers["X-login-id"]
    echo loginId
    echo "========== " & loginId & " =========="
  except:
    resp Http403, "Can't get login_id"
    # echo "========== Can't get login_id =========="


template middleware*(request: Request) =
  # discard
  checkLogin(request)
