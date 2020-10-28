#? stdtmpl | standard
#proc materialUiHtml*(users: string): string =
<html>
  <head>
    <title>👑React</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:300,400,500,700&display=swap" />
    <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons" />
  </head>
  <body>
    <!-- react -->
    <!-- <script src="https://unpkg.com/react@latest/umd/react.development.js" crossorigin="anonymous"></script>
    <script src="https://unpkg.com/react-dom@latest/umd/react-dom.development.js"></script> -->
    <script crossorigin src="https://unpkg.com/react@16/umd/react.production.min.js"></script>
    <script crossorigin src="https://unpkg.com/react-dom@16/umd/react-dom.production.min.js"></script>
    <!-- material ui -->
    <!-- <script src="https://unpkg.com/@material-ui/core@latest/umd/material-ui.development.js" crossorigin="anonymous"></script> -->
    <script src="https://unpkg.com/@material-ui/core@latest/umd/material-ui.production.min.js"></script>
    <!-- babel -->
    <script src="https://unpkg.com/babel-standalone@latest/babel.min.js" crossorigin="anonymous"></script>
    <!-- Fonts to support Material Design -->
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:300,400,500,700&display=swap" />
    <!-- Icons to support Material Design -->
    <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons" />
    
    <h1>React Users index</h1>
    <p><a href="../../">back</a></p>
    <div id="app"></div>
    <script type="text/babel">
      const {
        createMuiTheme,
        MuiThemeProvider,
        CssBaseline,
        Table,
        TableBody,
        TableCell,
        TableContainer,
        TableHead,
        TableRow,
        Paper
      } = MaterialUI;

      const theme = createMuiTheme();

      class App extends React.PureComponent {
        constructor(props) {
          super(props);
          this.state = {
            users: JSON.parse('$users')
          };
        }

        render() {
          return(
            <div>
              <TableContainer component={Paper}>
                <Table aria-label="simple table">
                  <TableHead>
                    <TableRow>
                      <TableCell align="right">id</TableCell>
                      <TableCell align="right">name</TableCell>
                      <TableCell align="right">email</TableCell>
                      <TableCell align="right">auth</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {this.state.users.map(user => (
                      <TableRow key={user.id}>
                        <TableCell component="th" scope="row">{user.id}</TableCell>
                        <TableCell align="right">{user.name}</TableCell>
                        <TableCell align="right">{user.email}</TableCell>
                        <TableCell align="right">{user.auth}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </div>
          );
        }
      }
      
      ReactDOM.render(
        <MuiThemeProvider theme={theme}>
          {/* CssBaseline kickstart an elegant, consistent, and simple baseline to build upon. */}
          <CssBaseline />
          <App />
        </MuiThemeProvider>,
        document.querySelector('#App'),
      );
    </script>
  </body>
</html>
