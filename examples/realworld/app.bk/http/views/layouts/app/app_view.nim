import basolato/view
import ../head_view
import ../navbar/navbar_view
import ../footer_view
import ./app_view_model


proc appView*(viewModel:AppViewModel, body:Component):Component =
  tmpl"""
    <!DOCTYPE html>
    <html>
      $(headView(viewModel.title))
      <body hx-ext="head-support">
        $(navbarView(viewModel.navbarViewModel))

        <div id="app-body">
          $(body)
        </div>

        $(footerView())

        <script src="/js/tagify.js"></script>
        <script>
          var isTagify = null;

          document.body.addEventListener('htmx:configRequest', function(evt) {
            evt.detail.headers['X-CSRF-TOKEN'] = '{{ csrf_token() }}';
          })

          window.addEventListener('DOMContentLoaded', function() {
            renderTagify();
          });

          document.body.addEventListener("htmx:afterSwap", function(evt) {
            renderTagify();
          });

          function renderTagify() {
            const input = document.querySelector('input[name=tags]');
            const tagify = document.querySelector('tags[class="tagify  form-control tagify--outside"]');

            if (input && !tagify) {
              new Tagify(input, {
                whitelist: [],
                dropdown: {
                  position: "input",
                  enabled : 0 // always opens dropdown when input gets focus
                }
              })
            }
          }
        </script>
      </body>
    </html>
  """
