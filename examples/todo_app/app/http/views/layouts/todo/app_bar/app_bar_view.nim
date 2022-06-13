import json, asyncdispatch
import ../../../../../../../../src/basolato/view
import ./app_bar_view_model


const jsFile = staticRead("./app_bar_js.js")

proc appBarView*(viewMode:AppBarViewModel):Future[string] {.async.} =
  style "css", style:"""
    <style>
    </style>
  """

  tmpli html"""
    <script>
      $<jsFile>
    </script>

    <script>
      window.addEventListener('load', ()=>{
        if(window.matchMedia('screen and (max-width: 780px)').matches){
          let el = document.getElementsByClassName('navbar')[0]
          el.classList.add('bulma-is-fixed-top')
        }
      })

      const toggleNavbarBurger=()=>{
        let el = document.getElementById('navbarMenu')
        el.classList.toggle('bulma-is-active')
      }
    </script>

    <nav class="bulma-navbar">
      <div class="bulma-navbar-brand">
        <h1 class="bulma-title bulma-is-1">Todo App</h1>
        <a class="bulma-navbar-burger" onclick="toggleNavbarBurger()">
          <span aria-hidden="true"></span>
          <span aria-hidden="true"></span>
          <span aria-hidden="true"></span>
        </a>
      </div>
      <div class="bulma-navbar-menu" id="navbarMenu">
        <div class="bulma-navbar-end">
          <p class="bulma-navbar-item">Login user: $(viewMode.name)</p>
          <p class="bulma-navbar-item">
            <a class="bulma-button bulma-is-light" href="/signout">
              Sign out
            </a>
          </p>
        </div>
      </div>
    </nav>
  """
