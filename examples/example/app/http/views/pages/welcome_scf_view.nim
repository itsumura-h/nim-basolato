#? stdtmpl(toString="toString") | standard
#import std/asyncdispatch
#import ../../../../../../src/basolato/view
#import ./welcome_scf_style
#proc welcomeScfView*(name:string): Future[Component] {.async.} =
# result = Component.new()
${style}
<link rel="stylesheet" href="http://cdn.jsdelivr.net/gh/highlightjs/cdn-release@9.17.1/build/styles/dracula.min.css">
<script src="http://cdn.jsdelivr.net/gh/highlightjs/cdn-release@9.17.1/build/highlight.min.js"></script>
<article>
  <section>
    <h1 class="${style.element("title")}">Nim ${name} is successfully running!!!</h1>
    <div class="${style.element("topImage")}">
      <img src="/basolato.svg" alt="nim-logo" style="height: 40vh">
    </div>
  </section>
</article>
<article>
  <section>
    <h2 class="${style.element("goldFont")}">
      Full-stack Web Framewrok for Nim
    </h2>
    <p class="${style.element("whiteFont")}">
      <i>—utilitas, firmitas et venustas (utility, strength and beauty)— by De architectura / Marcus Vitruvius
        Pollio</i>
    </p>
    <div class="${style.element("whiteFont")}">
      <ul>
        <li>Easy syntax as Python thanks to Nim</li>
        <li>Develop as easy as Ruby on Rails</li>
        <li>Stably structure as Symfony(PHP)</li>
        <li>Including easy query builder as Laravel(PHP)</li>
        <li>Run fast and light as Go and Rust</li>
        <li>This is the fastest full-stack web framework in the world</li>
      </ul>
    </div>
  </section>
</article>
