import ../../../../../../../src/basolato/view


proc webSocketIframeTemplate*():Component =
  let style = styleTmpl(Css, """
    <style>
      .form {
        border: 0px;
        box-shadow: none;
      }
    </style>
  """)

  tmpl"""
    <script>
      let socket = new WebSocket("ws://localhost:8000/sample/ws");

      const sendHandler=()=>{
        let outgoingMessage = document.getElementById("input").value;
        socket.send(outgoingMessage);
      }

      const clearHandler=()=>{
        let el = document.getElementById('messages');
        while(el.firstChild){
          el.removeChild(el.firstChild);
        }
      }

      socket.onmessage = function(event) {
        let message = event.data;

        let messageElem = document.createElement('div');
        messageElem.textContent = message;
        document.getElementById('messages').prepend(messageElem);
      }
    </script>
    <form class="$(style.element("form"))">
      <input type="text" id="input">
      <button type="button" onclick="sendHandler()">Send</button>
      <button type="button" onclick="clearHandler()">Delete</button>
    </form>
    <div id="messages"></div>
    $(style)
  """
