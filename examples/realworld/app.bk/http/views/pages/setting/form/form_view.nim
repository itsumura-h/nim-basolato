import basolato/view
import ./form_view_model


proc formView*(viewModel:FormViewModel):Component =
  tmpl"""
    <form
      action="/settings"
      method="POST"
      hx-post="/island/settings"
      id="settings-form"
      
      $if viewModel.oobSwap{
        hx-swap-oob="true"
      }
    >
      $context.csrfToken()
      <fieldset>
        <fieldset class="form-group">
          <input class="form-control" type="text" placeholder="URL of profile picture" value="$(viewModel.user.image)" name="image_url">
        </fieldset>
        <fieldset class="form-group">
          <input class="form-control form-control-lg" type="text" placeholder="Your Name" value="$(viewModel.user.name)" name="name">
        </fieldset>
        <fieldset class="form-group">
          <textarea class="form-control form-control-lg" rows="8" placeholder="Short bio about you" name="bio">$(viewModel.user.bio)</textarea>
        </fieldset>
        <fieldset class="form-group">
          <input class="form-control form-control-lg" type="email" placeholder="Email" value="$(viewModel.user.email)" name="email">
        </fieldset>
        <fieldset class="form-group">
          <input class="form-control form-control-lg" type="password" placeholder="Password" name="password">
        </fieldset>
        <button class="btn btn-lg btn-primary pull-xs-right" hx-post="/island/settings">
          Update Settings
        </button>
      </fieldset>
    </form>
  """
