import templates

proc vueHtml*(message: string): string = tmpli html"""
<html>
  <head>
      <title>👑Vue</title>
    <link href="https://fonts.googleapis.com/css?family=Roboto:100,300,400,500,700,900" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/@mdi/font@3.x/css/materialdesignicons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/vuetify@2.x/dist/vuetify.min.css" rel="stylesheet">
  </head>
  <body>
    <script src="https://cdn.jsdelivr.net/npm/vue@2.x/dist/vue.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/vuetify@2.x/dist/vuetify.js"></script>
    <div id="app">
      <p><a href="../../">戻る</a></p>
      <v-app>
        <v-parallax
          dark
          src="https://cdn.vuetifyjs.com/images/backgrounds/vbanner.jpg"
          @click="alert"
        >
          <v-row
            align="center"
            justify="center"
          >
            <h1 class="display-2 font-weight-thin mb-4">{{message}}</h1>
          </v-row>
        </v-parallax>
      </v-app>
    </div>
    <script>
      new Vue({
        el: '#app',
        vuetify: new Vuetify(),
        data() {
          return {
            message: '$(message)'
          }
        },
        methods: {
          alert: function () {
            alert("This is Vue page")
          }
        }
      })
    </script>
  </body>
</html>
"""