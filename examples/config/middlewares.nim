import jester
import ../../src/shihotsuchi/controller


proc checkLogin*(request: Request):Response =
  try:
    let loginId = request.headers["X-login-id"]
    echo loginId
    echo "========== " & loginId & " =========="
  except:
    return render(Http403, "========== Can't get login_id ==========")

proc check1*():Response =
  echo "========== check1 =========="

proc check2*():Response =
  echo "========== check2 =========="