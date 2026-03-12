import basolato/view
import ../../../islands/form_success_message/form_success_message_view
import ./form_message_view_model


proc formMessageView*(viewModel:FormMessageViewModel):Component =
  tmpl"""
    <div id="settings-form-message"
      $if viewModel.oobSwap{
        hx-swap-oob="true"
      }
    >
      $(formSuccessMessageView(viewModel.formSuccessMessageViewModel))
    </div>
  """
