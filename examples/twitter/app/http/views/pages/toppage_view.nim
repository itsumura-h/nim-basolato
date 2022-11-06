import std/asyncdispatch
import std/json
import basolato/view
import ../layouts/application_view


proc impl():Future[Component] {.async.} =
  let style = styleTmpl(Scss, """
    <style>
      .flex {
        display: flex;
      }
      .sidebar{
        padding: 12px;
        flex-grow: 1;

        .col{
          width: 68px;
          padding: 0 4px;
          flex: none;
          float: right;
        
          .row{
            width: 48px;
            height: 48px;
            display: flex;

            a{
              height: 100%;
              width: 100%;
              justify-content: center;
              align-items: center;
              display: flex;

            
              i{
                justify-content: center;
                align-items: center;
                font-size: 1.75rem;
              }
            }
          }
        }
      }
      .main{
        width: 920px;
        display: flex;
      }

      .info{
        width: 290px;
      }
    </style>
  """)

  tmpli html"""
    $(style)
    <div class="$(style.get("flex"))">
      <header class="$(style.get("sidebar"))">
        <div class="$(style.get("col"))">
          <div class="$(style.get("row"))">
            <a href="/">
              <i class="fa-brands fa-twitter"></i>
            </a>
          </div>
          <div class="$(style.get("row"))">
            <a href="/explore">
              <i class="fa-solid fa-magnifying-glass"></i>
            </a>
          </div>
          <div class="$(style.get("row"))">
            <a href="/settings">
              <i class="fa-solid fa-gear"></i>
            </a>
          </div>
        </div>
      </header>
      <main class="$(style.get("main"))">
        <div>
          main
        </div>
        <div class="$(style.get("info"))">
          info
        </div>
      </main>
    </div>
  """

proc toppageView*():Future[string] {.async.} =
  let title = ""
  return $applicationView(title, impl().await)
