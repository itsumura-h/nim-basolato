import ../../../../../../src/basolato/view

let style* = styleTmpl(Css, """
<style>
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
    display: flex;
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
</style>
""")
