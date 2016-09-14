port module Main exposing (..)
import Html exposing (text, Html, textarea,button, h3)
import Html.Attributes exposing (id, style, checked, type', name, autofocus, placeholder)
import Html.Events exposing (..)
import JSPhoenix exposing (ChannelEventMsg, ChanExitCB)
import Markdown exposing (..)
import Json.Decode as JD exposing (int, string, bool)
import Json.Encode as JE exposing (int, null, object)
import Html.App as Html
import Html exposing (div, p, ul, li, input, span)
import Svg exposing (Svg, rect, svg, path, g)
import Svg.Attributes exposing (width, height, x, y, rx, ry, viewBox, d, class)
-- MODEL 

type alias Model =
  { id:         Int
  , date:       String
  , author:     String
  , markdown:   String
  , published:  Bool
  , email:      String
  }

initModel: Model
initModel =
  { id        = 0
  , date      = ""
  , author    = ""
  , markdown  = ""
  , published = False
  , email = ""
  }

init: (Model, Cmd Msg)
init = (initModel, Cmd.none)

type alias RoomSyncMeta =
  { phx_ref : String
  , loc : String
  , online_at : JSPhoenix.TimexDateTime
  , nick : String
  }

type alias RoomSyncState =
  List ( String, { metas : List RoomSyncMeta } )

type alias RoomSyncEvent =
  { id : String
  , old : Maybe ( String, List RoomSyncMeta )
  , new : List ( String, List RoomSyncMeta )
  }

-- Custom messages, whatever fits your Phoenix app:
type alias RoomMessage =
  { id : Int 
  , date : String
  , markdown : String
  , author : String
  --, read_cnt : Int
  , published : Bool
  , email : String
  }


type alias RoomMessages =
  { msgs : List RoomMessage }

--port onRoomConnect : (ChannelEventMsg {} String -> msg) -> Sub msg
port onMsgSent : (ChannelEventMsg {} String -> msg) -> Sub msg
port onMsgReceived : (ChannelEventMsg {} String -> msg) -> Sub msg
-- { :reply, :ok, socket }

connect_room =
  JSPhoenix.connect
      { topic = "reflection"
      , timeout_ms = Nothing -- Just 10000 -- Default value is 10000 if Nothing is used
      , chanCloseCB = Nothing
      , chanErrorCB = Nothing
      , syncState = Nothing
      , syncJoin = Nothing
      , syncLeave = Nothing
      , joinData = null
      , joinEvents =
          []
      , onPorts =
          [ --{ portName = "onMsgSent", msgID = "reply", cb_data = (JE.string "reflection submitted successfully") }
          ]
      }
 
pushRoomLoginMsg : Model -> Cmd Msg
pushRoomLoginMsg model =
  let
    msg_send_push : JSPhoenix.Push
    msg_send_push =
    { topic = "reflection"
    , mid = "login"
    , msg = JE.object [ ( "email", JE.string model.email ) ]
    , pushEvents =
        [ { portName = "onMsgSent"
          , msgID = "ok"
          , cb_data = JE.string "ok"
          }
        , { portName = "onMsgError"
          , msgID = "error"
          , cb_data = JE.string "error"
          }
        , { portName = "onMsgTimeout"
          , msgID = "timeout"
          , cb_data = JE.string "timeout"
          }
        , { portName = "onMsgSent"
          , msgID = "reply"
          , cb_data = JE.string ("This is a reply from " ++ model.author ++ "'s submission!")
          }
        ]
    }
  in
    JSPhoenix.push msg_send_push

pushRoomMsg : Model -> Cmd Msg
pushRoomMsg model =
  let
    msg_send_push : JSPhoenix.Push
    msg_send_push =
    { topic = "reflection"
    , mid = "submit"
    , msg = JE.object [ ( "date", JE.string model.date )
                      , ( "markdown", JE.string model.markdown )
                      , ( "author", JE.string model.author )
                      , ( "published", JE.bool model.published )
                      ]
    , pushEvents =
        [ { portName = "onMsgSent"
          , msgID = "ok"
          , cb_data = JE.string "ok"
          }
        , { portName = "onMsgError"
          , msgID = "error"
          , cb_data = JE.string "error"
          }
        , { portName = "onMsgTimeout"
          , msgID = "timeout"
          , cb_data = JE.string "timeout"
          }
        , { portName = "onMsgSent"
          , msgID = "reply"
          , cb_data = JE.string ("This is a reply from " ++ model.author ++ "'s submission!")
          }
        ]
    }
  in
    JSPhoenix.push msg_send_push

    
type Msg
    = NoOp
    --| SubmitReflection
    | InitRefl Model
    | ReflectionDate String
    | ReflectionAuthor String
    | ReflectionText String
    | ReflectionEmail String
    | Published Bool
    -- | MyRoomConnectMsg (ChannelEventMsg {} String)
    -- | MyRoomMsgsSubmitMsg (ChannelEventMsg RoomMessage String)
    | SubmitClickMsg
    | SubmissionReplyMsg (ChannelEventMsg {} String)
    | ConnectClickMsg
    | LoginMsg
 
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NoOp -> (model, Cmd.none)
    
    -- MyRoomConnectMsg msg ->
    --   ( model
    --   , connect_room -- You can use the JSPhoenix.connect like any normal command
    --   )
    ConnectClickMsg ->
        ( model
        , connect_room
        )
      
    InitRefl newModel -> 
        let
          foo = Debug.log "INIT REFL" newModel
        in
          ( newModel , Cmd.none)
    ReflectionEmail s ->
      ( { model | email = s }, Cmd.none )
      
    ReflectionDate s ->
      ( { model | date = s }, Cmd.none )

    ReflectionAuthor s -> 
      ( { model | author = s }, Cmd.none )

    ReflectionText s ->
      ( { model | markdown = s }, Cmd.none )
      
    -- MyRoomMsgsSubmitMsg msg ->
    --     ( model, pushRoomMsg model )
    LoginMsg ->
        (model, pushRoomLoginMsg model )
    SubmitClickMsg ->
        ( model, pushRoomMsg model )
    
    SubmissionReplyMsg msg ->
    let
      _ = Debug.log "msg" msg
    in
        ( model , Cmd.none ) --pushRoomMsg model)
        
    Published bool ->
      let
        foo = Debug.log "PUBLISHED" bool
        newModel = { model | published = bool }
      in
        ( newModel, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch -- Subscribe to your port events to get their messages
    [ onMsgSent SubmissionReplyMsg
    --onRoomConnect MyRoomConnectMsg
    ]

-- subscriptions: Model -> Sub Msg
-- subscriptions model =
--   Sub.batch
--   [ portReflection InitRefl]

main = Html.program
  { init = init
  , update = update
  , view = view
  , subscriptions = subscriptions
  }
 
 
 
 
 -- View
 
view : Model -> Html Msg
view model =
  div [ id "refl-edit"]
  [ inputEmail model
  , inputDate model
  , inputAuthor model
  , inputText model
  , ul [id "refl-buttons"]
      [ li [] [ button [ onClick SubmitClickMsg ] [ text "Submit" ] ]
      , li [] [ button [ onClick ConnectClickMsg ] [ text "Connect" ] ]
      , li [] [ button [ onClick LoginMsg ] [ text "Login" ] ]
      ]
  , showText model
  , showAnimation
  ]

inputEmail: Model -> Html Msg
inputEmail model =
  p [] 
    [ input
        [ id "reflection-email"
        , name "reflection-email"
        , type' "text"
        , placeholder "Reflection Email"
        , Html.Attributes.value model.email
        , onInput ReflectionEmail
        , autofocus True
        ] 
        []
    ]
    
inputDate: Model -> Html Msg
inputDate model =
  p [] 
    [ input
        [ id "reflection-date"
        , name "reflection-date"
        , type' "text"
        , placeholder "Reflection Date"
        , Html.Attributes.value model.date
        , onInput ReflectionDate
        , autofocus True
        ] 
        []
    ]

inputAuthor: Model -> Html Msg
inputAuthor model =
  p [] 
    [ input
        [ id "reflection-author"
        , name "reflection-author"
        , type' "text"
        , placeholder "Your name"
        , Html.Attributes.value model.author
        , onInput ReflectionAuthor
        , autofocus True
        ] 
        []
    ]

inputText: Model -> Html Msg
inputText model =
  p [ id "refl-textarea"]
    [ textarea 
        [ id "reflection-text"
        , name "reflection-text"
        , placeholder "Use Markdown formatting"
        , Html.Attributes.value model.markdown
        , onInput ReflectionText
        , autofocus True
        ]
        []
    ]

showText: Model -> Html Msg
showText model =
  div [id "preview"] 
  [ h3 [] 
    [ text "Preview  "
    , span [ style [("font-weight", "normal"), ("font-size", "0.7em")] ] [ text "( published" ]
    , input [ type' "checkbox"
            , checked model.published
            , onCheck Published
            ]
            []
    , span [ style [("font-weight", "normal"), ("font-size", "0.7em")] ] [ text ")" ]
    ]
  , div [id "md-text"] [Markdown.toHtml [] model.markdown]
  ]
  
showAnimation : Html msg
showAnimation =
  svg
    [ width "100%", height "100%", viewBox "0 0 320 180", Svg.Attributes.class "letters letters--effect-1" ]
    [ g [ Svg.Attributes.class "letter letter--1" ]
        [ g [ Svg.Attributes.class "letter__part" ]
          [ path [ d "M25,39.7l22.4,51l7.9-32.2L76.2,84l1.3-61.2", class "letter__layer color-6" ] []
          , path [ d "M25,39.7l22.4,51l7.9-32.2L76.2,84l1.3-61.2", class "letter__layer color-1" ] []
          , path [ d "M25,39.7l22.4,51l7.9-32.2L76.2,84l1.3-61.2", class "letter__layer color-2" ] []
          ]
        ]
    ]
