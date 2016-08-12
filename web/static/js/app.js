import "phoenix_html"

import socket from "./socket"
import Elm from './main'
import setup_phoenix_socket_ports from './setup_phoenix_socket_ports'

let socket_setup_once = false
socket.onOpen(() => {
  $(document).ready(function(){
    if(socket_setup_once) return
    socket_setup_once = true

    // Here setup all your usual javascript that also needs to use the websocket

    let app = Elm.Main.embed(document.querySelector('#elm-target'))
    setup_phoenix_socket_ports(app, socket)
    
  });
});


// const elmDiv = document.querySelector('#elm-target');
// if (elmDiv) {
//   Elm.Main.embed(elmDiv);
// }