#? stdtmpl | standard
#proc vuetifyHtml*(header: string, users: string): string =
<head>
  <title>👑Nim Basolato</title>
  <link href="https://fonts.googleapis.com/css?family=Roboto:100,300,400,500,700,900" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/@mdi/font@3.x/css/materialdesignicons.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/vuetify@2.x/dist/vuetify.min.css" rel="stylesheet">
</head>
<body>
  <h1>Vue Users index</h1>
  <p><a href="/">go back</a></p>
  <div id="app">
    <v-app>
      <v-data-table
        :headers="headers"
        :items="users"
        :items-per-page="10"
        class="elevation-1"
      >
      </v-data-table>
    </v-app>
  </div>
  <script src="https://cdn.jsdelivr.net/npm/vue@2.x/dist/vue.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/vuetify@2.x/dist/vuetify.js"></script>
  <script>
    new Vue({
      el: '#app',
      vuetify: new Vuetify(),
      data() {
        return {
          headers: JSON.parse('$header'),
          users: JSON.parse('$users')
        }
      }
    })
  </script>
</body>
