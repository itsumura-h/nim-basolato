import basolato/view
import ../layouts/application

proc impl():string = tmpli html"""
<main />

<script type="text/babel">

  const HelloWorld =(props)=> {
    return (
      <div>
        Hello World {props.name}
      </div>
    )
  }

  ReactDOM.render(<HelloWorld name="01"/>, document.querySelector('main'))

</script>
"""

proc todo_spaView*(this:View):string =
  let title = ""
  return this.applicationView(title, impl())
