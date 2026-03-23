import std/json
import basolato/controller
import basolato/request_validation
import ../../errors
import ../../presenters/setting/setting_presenter
import ../../presenters/setting/setting_with_success_message_presenter
import ../views/pages/setting/setting_view

import ../../usecases/update_user_usecase
import ../../presenters/form_error_message/form_error_message_presenter
import ../views/islands/form_error_message/form_error_message_view_model
import ../views/islands/form_error_message/form_error_message_view


proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let userId = context.get("id").await
  let settingPresenter = SettingPresenter.new()
  let settingViewModel = settingPresenter.invoke(userId).await
  let view = islandSettingView(settingViewModel)
  return render(view)


proc update*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  v.required("image_url", "URL of profile picture")
  v.required("name")
  v.required("email")
  # v.required("password")
  v.email("email")
  if v.hasErrors:
    let formErrorMessagePresenter = FormErrorMessagePresenter.new()
    let viewModel = formErrorMessagePresenter.invoke(%v.errors)
    let view = formErrorMessageView(viewModel)
    let header = {
      "HX-Reswap": "innerHTML show:top",
      "HX-Retarget": "#settings-form-message"
    }.newHttpHeaders()
    return render(view, header)

  let userId = context.get("id").await
  let image = params.getStr("image_url")
  let name = params.getStr("name")
  let bio = params.getStr("bio")
  let email = params.getStr("email")
  let password = params.getStr("password")
  
  try:
    let usecase = UpdateUserUsecase.new()
    usecase.invoke(userId, name, email, password, bio, image).await
    let presenter = SettingWithSuccessMessagePresenter.new()
    let viewModel = presenter.invoke(userId).await
    let view = islandSettingView(viewModel)
    return render(view)
  except IdNotFoundError:
    let viewModel = FormErrorMessageViewModel.new(@[getCurrentExceptionMsg()])
    let view = formErrorMessageView(viewModel)
    let header = {
      "HX-Reswap": "innerHTML show:top",
      "HX-Retarget": "#settings-form-message"
    }.newHttpHeaders()
    return render(view, header)
  except DomainError:
    let viewModel = FormErrorMessageViewModel.new(@[getCurrentExceptionMsg()])
    let view = formErrorMessageView(viewModel)
    let header = {
      "HX-Reswap": "innerHTML show:top",
      "HX-Retarget": "#settings-form-message"
    }.newHttpHeaders()
    return render(view, header)
  except:
    return render(Http500, getCurrentExceptionMsg())
