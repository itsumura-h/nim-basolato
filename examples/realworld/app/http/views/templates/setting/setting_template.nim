import std/asyncdispatch
import basolato/view
import ./setting_template_model


proc settingTemplate*(model: SettingTemplateModel): Component =
  tmpl"""
    <div class="settings-page">
      <div class="container page">
        <div class="row">
          <div class="col-md-6 offset-md-3 col-xs-12">
            <h1 class="text-xs-center">Your Settings</h1>

            <ul class="error-messages">
              $for error in model.errors{
                <li>$(error)</li>
              }
            </ul>

            <form method="post" action="/settings">
              $(model.csrfToken)
              <fieldset>
                <fieldset class="form-group">
                  <input
                    class="form-control"
                    type="text"
                    placeholder="URL of profile picture"
                    name="image"
                    value="$( model.image )"
                  />
                </fieldset>
                <fieldset class="form-group">
                  <input
                    class="form-control form-control-lg"
                    type="text"
                    placeholder="Your Name"
                    name="name"
                    value="$( model.name )"
                  />
                </fieldset>
                <fieldset class="form-group">
                  <textarea
                    class="form-control form-control-lg"
                    rows="8"
                    placeholder="Short bio about you"
                    name="bio"
                  >$( model.bio )</textarea>
                </fieldset>
                <fieldset class="form-group">
                  <input
                    class="form-control form-control-lg"
                    type="text"
                    placeholder="Email"
                    name="email"
                    value="$( model.email )"
                  />
                </fieldset>
                <fieldset class="form-group">
                  <input
                    class="form-control form-control-lg"
                    type="password"
                    placeholder="New Password"
                    name="password"
                  />
                </fieldset>
                <button class="btn btn-lg btn-primary pull-xs-right">Update Settings</button>
              </fieldset>
            </form>
            <hr />
            <form method="post" action="/logout">
              $(model.csrfToken)
              <button class="btn btn-outline-danger">Or click here to logout.</button>
            </form>
          </div>
        </div>
      </div>
    </div>
  """


proc settingTemplate*(context: Context): Future[Component] {.async.} =
  let model = await SettingTemplateModel.new(context)
  return settingTemplate(model)
