import std/asyncdispatch
import std/json
import std/strformat
import basolato/controller
import ../views/pages/profile/profile_page
import ../../usecases/follow_usecase


proc show*(context:Context):Future[Response] {.async.} =
  let view = profilePage().await
  return render(view)


proc favoriteShow*(context:Context):Future[Response] {.async.} =
  let view = profilePage().await
  return render(view)


proc follow*(context:Context):Future[Response] {.async.} =
  let userId = context.params.getStr("userId")
  let loginUserId = context.session.get("userId").await

  let usecase = FollowUsecase.new()
  await usecase.invoke(loginUserId, userId)

  return redirect(&"/profile/{userId}")
