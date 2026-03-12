import basolato/view
import ../../layouts/app/app_view_model
import ../../layouts/app/app_view
import ./form_message/form_message_view
import ./form/form_view
import ./setting_view_model


proc impl(viewModel:SettingViewModel):Component =
  tmpl"""
    <div class="settings-page">
      <div class="container page">
        <div class="row">
          <div class="col-md-6 offset-md-3 col-xs-12">
            <h1 class="text-xs-center">Your Settings</h1>

            $(formMessageView(viewModel.fromMessageViewModel))

            $(formView(viewModel.formViewModel))

            <hr />
            <form hx-post="/island/logout" method="post">
              $(csrfToken())
              <button type="submit" class="btn btn-outline-danger">
                Or click here to logout.
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
  """

proc settingView*(appViewModel:AppViewModel, viewModel:SettingViewModel):Component =
  return appView(appViewModel, impl(viewModel)) 

proc islandSettingView*(viewModel:SettingViewModel):Component =
  return impl(viewModel)
