import json, asyncdispatch
import ../../../../../../../src/basolato/view


proc validationPage*():Future[Component] {.async.} =
  let context = context()
  let (params, errors) = context.getParamsWithErrorsObject().await
  
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
        <p><input type="text" name="email" placeholder="email" value="$(params.old("email"))"></p>
        $if errors.haskey("email"){
          <ul class="$(style.element("error"))">
            $for error in errors["email"] {
              <li>$(error)</li>
            }
          </ul>
        }
        <p><input type="password" name="password" placeholder="password"></p>
        $if errors.haskey("password"){
          <ul class="$(style.element("error"))">
            $for error in errors["password"] {
              <li>$(error)</li>
            }
          </ul>
        }
        <p><input type="password" name="password_confirmation" placeholder="password confirmation"></p>
        $if errors.haskey("password_confirmation"){
          <ul class="$(style.element("error"))">
            $for error in errors["password_confirmation"] {
              <li>$(error)</li>
            }
          </ul>
        }
        <p><input type="number" name="number" placeholder="number between 1 ~ 10" value="$(params.old("number"))"></p>
        $if errors.haskey("number"){
          <ul class="$(style.element("error"))">
            $for error in errors["number"] {
              <li>$(error)</li>
            }
          </ul>
        }
        <p><input type="text" name="float" placeholder="float between 0.1 ~ 1.0" value="$(params.old("float"))"></p>
        $if errors.haskey("float"){
          <ul class="$(style.element("error"))">
            $for error in errors["float"] {
              <li>$(error)</li>
            }
          </ul>
        }
        <p><button type="submit">send</button></p>
      </form>
    </main>
  """
