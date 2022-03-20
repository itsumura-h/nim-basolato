import json, asyncdispatch
import ../../../../../../../src/basolato/view


proc appBarView*(name:string):Future[string] {.async.} =
  style "css", style:"""
    <style>
    </style>
  """

  script ["navbarMenu"], script:"""
    <script>
      window.addEventListener('load', ()=>{
        if(window.matchMedia('screen and (max-width: 780px)').matches){
          let el = document.getElementsByClassName('navbar')[0]
          el.classList.add('is-fixed-top')
        }
      })

      const toggleNavbarBurger=()=>{
        let el = document.getElementById('navbarMenu')
        el.classList.toggle('is-active')
      }
    </script>
  """

  tmpli html"""
    $(script)
    <nav class="navbar">
      <div class="navbar-brand">
        <h1 class="title is-1">Todo App</h1>
        <a class="navbar-burger" onclick="toggleNavbarBurger()">
          <span aria-hidden="true"></span>
          <span aria-hidden="true"></span>
          <span aria-hidden="true"></span>
        </a>
      </div>
      <div class="navbar-menu" id="$(script.element("navbarMenu"))">
        <div class="navbar-end">
          <p class="navbar-item">Login user: $(name.get)</p>
          <p class="navbar-item">
            <a class="button is-light" href="/signout">
              Sign out
            </a>
          </p>
        </div>
      </div>
    </nav>
  """
