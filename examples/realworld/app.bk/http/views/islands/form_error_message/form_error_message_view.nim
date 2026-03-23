import basolato/view
import ./form_error_message_view_model


proc formErrorMessageView*(viewModel:FormErrorMessageViewModel):Component =
  tmpl"""
    $if viewModel.errors.len > 0{
      <div class="alert alert-danger">
        <ul>
          $for error in viewModel.errors{
            <li>$(error)</li>
          }
        </ul>
      </div>
    }$else{
      <div>asdasd</div>
    }
  """
