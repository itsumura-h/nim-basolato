import basolato/view
import ./form_success_message_view_model


proc formSuccessMessageView*(viewModel:FormSuccessMessageViewModel): Component =
  tmpl"""
    $if viewModel.message.len > 0{
      <div class="alert alert-success">
        <ul>
          <li>$(viewModel.message)</li>
        </ul>
      </div>
    }
  """
