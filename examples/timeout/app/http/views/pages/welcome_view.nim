import basolato/view
import ../layouts/application_view

style "css", style:"""
body {
  background-color: black;
}

article {
  margin: 16px;
}

.title {
  color: goldenrod;
  text-align: center;
}

.topImage {
  background-color: gray;
  text-align: center;
}

.goldFont {
  color: goldenrod;
}

.whiteFont {
  color: silver;
}

.ulLink li {
  margin: 8px;
}

.ulLink li a {
  color: skyblue;
}

.architecture {
  padding: 10px
}

.architecture h2 {
  color: goldenrod;
}

.components {
  display:flex;
}

.discription {
  width: 50vw;
}

.discription h3 {
  color: goldenrod;
}

.discription p {
  color: white;
}

.sourceCode {
  width: 50vw
}

.sourceCode p {
  color: white;
  margin-bottom: 0;
}

.sourceCode pre {
  margin-top: 0;
}
"""

proc impl(title, name:string):string = tmpli html"""
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title</title>
  <link rel="stylesheet" href="http://cdn.jsdelivr.net/gh/highlightjs/cdn-release@9.17.1/build/styles/dracula.min.css">
  <script src="http://cdn.jsdelivr.net/gh/highlightjs/cdn-release@9.17.1/build/highlight.min.js"></script>
  $(style)
</head>
<body>
  <article>
    <section>
      <h1 class="$(style.get("title"))">Nim $name is successfully running!!!</h1>
      <div class="$(style.get("topImage"))">
        <img
          src="/basolato.svg"
          alt="nim-logo"
          style="height: 40vh"
        >
      </div>
    </section>
  </article>
  <article>
    <section>
      <h2 class="$(style.get("goldFont"))">
        Full-stack Web Framewrok for Nim
      </h2>
      <p class="$(style.get("whiteFont"))">
        <i>—utilitas, firmitas et venustas (utility, strength and beauty)— by De architectura / Marcus Vitruvius Pollio</i>
      </p>
      <div class="$(style.get("whiteFont"))">
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
</body>
</html>
"""

proc welcomeView*(name:string):string =
  let title = "Welcome Basolato"
  return impl(title, name)
