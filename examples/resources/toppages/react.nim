import templates

proc reactHtml*(message: string): string = tmpli html"""
<html>
  <head>
    <title>👑React</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:300,400,500,700&display=swap" />
    <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons" />
  </head>
  <body>
    <!-- react -->
    <script src="https://unpkg.com/react@latest/umd/react.development.js" crossorigin="anonymous"></script>
    <script src="https://unpkg.com/react-dom@latest/umd/react-dom.development.js"></script>
    <!-- material ui -->
    <script src="https://unpkg.com/@material-ui/core@latest/umd/material-ui.development.js" crossorigin="anonymous"></script>
    <!-- babel -->
    <script src="https://unpkg.com/babel-standalone@latest/babel.min.js" crossorigin="anonymous"></script>
    <!-- Fonts to support Material Design -->
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:300,400,500,700&display=swap" />
    <!-- Icons to support Material Design -->
    <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons" />
    
    <p><a href="../../">戻る</a></p>
    <div id="app"></div>
    <script type="text/babel">
      const {
        createMuiTheme,
        MuiThemeProvider,
        CssBaseline,
        Paper,
        Card,
        CardContent,
        Typography
      } = MaterialUI;

      const theme = createMuiTheme();

      class App extends React.PureComponent {
        constructor(props) {
          super(props);
          this.state = {
            message: '$(message)'
          };
          this.alert = this.alert.bind(this);
        }

        alert() {
          alert('This is React page');
        }

        render() {
          return(
            <Paper className="paper" onClick={this.alert}>
              <Card className="card">
                <CardContent>
                  <Typography component="h1" variant="h3" color="inherit" gutterBottom className="typo">
                    {this.state.message}
                  </Typography>
                </CardContent>
              </Card>
            </Paper>
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

    <style>
      .paper {
        background-image: url("https://cdn.vuetifyjs.com/images/backgrounds/vbanner.jpg");
      }
      .card {
        width: 90%;
        min-height: 85vh;
        background-color: rgba(255,255,255, 0);
        margin: auto;
        text-shadow: none;
        padding: 16px;
      }
      .typo {
        color: white;
      }
    </style>
  </body>
</html>
"""