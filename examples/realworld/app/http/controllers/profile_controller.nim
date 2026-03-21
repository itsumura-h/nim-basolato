import std/asyncdispatch
import basolato/controller
import ../views/pages/profile/profile_page
import ../../usecases/follow_usecase


proc show*(context:Context):Future[Response] {.async.} =
  let view = profilePageView(context).await
  return render(view)


proc favoriteShow*(context:Context):Future[Response] {.async.} =
  let view = profilePageView(context).await
  return render(view)


proc followFromProfile*(context:Context):Future[Response] {.async.} =
  let userId = context.params.getStr("userId")
  let loginUserId = context.get("user_id").await

  let usecase = FollowUsecase.new()
  await usecase.invoke(loginUserId, userId)

  return redirect("/profile/" & userId)
