import std/json
import std/asyncdispatch
import ../../../../../../../src/basolato/view
import ../../presenters/validation/validation_page_viewmodel


proc validationTemplate*(vm: ValidationPageViewModel): Component


proc validationPage*():Future[Component] {.async.} =
  let context = context()
  let (params, errors) = context.getParamsWithErrorsObject().await
  
  let vm = ValidationPageViewModel.new(params, errors)
  return validationTemplate(vm)


proc validationTemplate*(vm: ValidationPageViewModel): Component =
  let style = styleTmpl(Css, """
    <style>
      .error {
        background-color: pink;
        color: red;
      }
    </style>
  """)

  tmpl"""
    $(style)
    <main>
      <a href="/">go back</a>
      <form method="POST">
        $(csrfToken())
        <p><input type="text" name="email" placeholder="email" value="$(vm.formParams.old("email"))"></p>
        $if vm.formErrors.haskey("email"){
          <ul class="$(style.element("error"))">
            $for error in vm.formErrors["email"] {
              <li>$(error)</li>
            }
          </ul>
        }
        <p><input type="password" name="password" placeholder="password"></p>
        $if vm.formErrors.haskey("password"){
          <ul class="$(style.element("error"))">
            $for error in vm.formErrors["password"] {
              <li>$(error)</li>
            }
          </ul>
        }
        <p><input type="password" name="password_confirmation" placeholder="password confirmation"></p>
        $if vm.formErrors.haskey("password_confirmation"){
          <ul class="$(style.element("error"))">
            $for error in vm.formErrors["password_confirmation"] {
              <li>$(error)</li>
            }
          </ul>
        }
        <p><input type="number" name="number" placeholder="number between 1 ~ 10" value="$(vm.formParams.old("number"))"></p>
        $if vm.formErrors.haskey("number"){
          <ul class="$(style.element("error"))">
            $for error in vm.formErrors["number"] {
              <li>$(error)</li>
            }
          </ul>
        }
        <p><input type="text" name="float" placeholder="float between 0.1 ~ 1.0" value="$(vm.formParams.old("float"))"></p>
        $if vm.formErrors.haskey("float"){
          <ul class="$(style.element("error"))">
            $for error in vm.formErrors["float"] {
              <li>$(error)</li>
            }
          </ul>
        }
        <p><button type="submit">send</button></p>
      </form>
    </main>
  """
