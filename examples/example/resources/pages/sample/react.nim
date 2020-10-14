import basolato/view
proc reactHtml*(users:string): string = tmpli html"""
<main></main>
<script crossorigin src="https://unpkg.com/react@16/umd/react.development.js"></script>
<script crossorigin src="https://unpkg.com/react-dom@16/umd/react-dom.development.js"></script>
<!-- <script crossorigin src="https://unpkg.com/react@16/umd/react.production.min.js"></script>
<script crossorigin src="https://unpkg.com/react-dom@16/umd/react-dom.production.min.js"></script> -->
<!-- router -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/react-router-dom/5.1.2/react-router-dom.min.js"></script>
<!-- babel -->
<script src="https://unpkg.com/babel-standalone@latest/babel.min.js" crossorigin="anonymous"></script>
<script type="text/babel">
  const {useState} = React
  const {BrowserRouter, Switch, Route, Link } = ReactRouterDOM
  function Header(){
    return <div>
      <Link to="/sample/react" style={{marginRight: '10px'}}>react</Link>
      <Link to="/sample/react/page1" style={{marginRight: '10px'}}>page1</Link>
      <Link to="/sample/react/page2" style={{marginRight: '10px'}}>page2</Link>
    </div>
  }
  function Index(){
    let [count, setCount] = useState(0)
    let users = JSON.parse('$users')
    console.log(users)
    
    return <div>
      <h1>index</h1>
      <button onClick={function(){setCount(count+1)}}>add</button>
      <p>{count}</p>
      <table border="1">
        <tr>
          <th>id</th><th>name</th><th>email</th><th>auth</th>
        </tr>
          {users.map(user=>{
            return <tr>
              <td>{user.id}</td><td>{user.name}</td><td>{user.email}</td><td>{user.auth}</td>
            </tr>
          })}
      </table>
    </div>
  }
  function Page1(){
    return <h1>page1</h1>
  }
  function Page2(){
    return <h1>page2</h1>
  }
  function App(){
    return <div>
      <a href="/">go back</a>
      <BrowserRouter>
        <Header/>
        <Switch>
          <Route exact path='/sample/react' children={<Index/>} />
          <Route exact path='/sample/react/page1' children={<Page1/>} />
          <Route exact path='/sample/react/page2' children={<Page2/>} />
        </Switch>
      </BrowserRouter>
    </div>
  }
  ReactDOM.render(<App/>,document.querySelector('main'))
</script>
"""
