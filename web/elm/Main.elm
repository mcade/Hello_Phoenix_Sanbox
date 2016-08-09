port module Main exposing (..)
import Html exposing (text, Html)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import JSPhoenix exposing (ChannelEventMsg, ChanExitCB)
import Markdown exposing (..)
import Json.Decode as JD exposing (int, string, bool)
import Json.Encode as JE exposing (int, null)
import Html.App as Html
import Html exposing (..)

-- MODEL

type alias Model =
  { id:         Int
  , date:       String
  , author:     String
  , text:       String
  , published:  Bool
  }

initModel: Model
initModel =
  { id        = 0
  , date      = ""
  , author    = ""
  , text      = ""
  , published = False
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
  { date : String
  , markdown : String
  , author : String
  , read_cnt : Int
  , published : Bool
  , inserted_at : JSPhoenix.TimexDateTime
  , updated_at : JSPhoenix.TimexDateTime
  }

type alias RoomMessages =
  { msgs : List RoomMessage }

port onRoomConnect : (ChannelEventMsg RoomMessages RoomMessage -> msg) -> Sub msg
port onRoomInfo : (ChannelEventMsg {} Int -> msg) -> Sub msg
port onRoomMsgsInit : (ChannelEventMsg RoomMessages Int -> msg) -> Sub msg
port onRoomMsgsAdd : (ChannelEventMsg RoomMessages Int -> msg) -> Sub msg
port onRoomSyncState : (ChannelEventMsg RoomSyncState Int -> msg) -> Sub msg
port onRoomSyncJoin : (ChannelEventMsg RoomSyncEvent Int -> msg) -> Sub msg
port onRoomSyncLeave : (ChannelEventMsg RoomSyncEvent Int -> msg) -> Sub msg

port portSubmit: Model -> Cmd msg
port portReflection: (Model -> msg) -> Sub msg


connect_room rid =
  JSPhoenix.connect
      { topic = "reflection"
      , timeout_ms = Nothing -- Just 10000 -- Default value is 10000 if Nothing is used
      , chanCloseCB = Nothing
      , chanErrorCB = Nothing
      , syncState = Just { portName = "onRoomSyncState", cb_data = (JE.int rid) }
      , syncJoin = Just { portName = "onRoomSyncJoin", cb_data = (JE.int rid) }
      , syncLeave = Just { portName = "onRoomSyncLeave", cb_data = (JE.int rid) }
      , joinData = null
      , joinEvents =
          [ { portName = "onRoomConnect", msgID = "ok", cb_data = (JE.int rid) }
          ]
      , onPorts =
          [ { portName = "onRoomInfo", msgID = "room:info", cb_data = (JE.int rid) }
          , { portName = "onRoomMsgsInit", msgID = "msgs:init", cb_data = (JE.int rid) }
          , { portName = "onRoomMsgsAdd", msgID = "msgs:add", cb_data = (JE.int rid) }
          ]
      }

type alias ModelFormatted = 
    { cb_data : Model
    , msg : RoomMessage
    , msgID : String
    , topic : String
    }

type Msg
    = NoOp
    | SubmitReflection
    | InitRefl Model
    | ReflectionDate String
    | ReflectionAuthor String
    | ReflectionText String
    | Published Bool

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NoOp -> (model, Cmd.none)
    
    InitRefl newModel -> 
        let
          foo = Debug.log "INIT REFL" newModel
        in
          ( newModel , Cmd.none)
    ReflectionDate s ->
      ( { model | date = s }, Cmd.none)

    ReflectionAuthor s -> 
      ( { model | author = s }, Cmd.none)

    ReflectionText s ->
      ( { model | text = s }, Cmd.none)
      
    SubmitReflection ->
        ( model, portSubmit model )
        
    Published bool ->
      let
        foo = Debug.log "PUBLISHED" bool
        newModel = { model | published = bool }
      in
        ( newModel, portSubmit newModel)
--     MyConnectMessage rid ->
--       ( model
--       , connect_room rid -- You can use the JSPhoenix.connect like any normal command
--       )

-- subscriptions : Model -> Sub Msg
-- subscriptions model =
--   Sub.batch -- Subscribe to your port events to get their messages
--     [ onRoomConnect (\{ msg, cb_data } -> MyRoomConnectMsg msg cb_data) -- Example to show you the structure of the data
--     , onRoomConnect (\{ msg } -> MyRoomConnectMsg msg)
--     , onRoomInfo MyRoomInfoMsg
--     , onRoomMsgsInit MyRoomMsgsInitMsg
--     , onRoomMsgsAdd MyRoomMsgsAddMsg
--     , onRoomSyncState MyRoomSyncStateMsg
--     , onRoomSyncJoin MyRoomSyncJoinMsg
--     , onRoomSyncLeave MyRoomSyncLeaveMsg
--     ]

subscriptions: Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ portReflection InitRefl]

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
  [ inputDate model
  , inputAuthor model
  , inputText model
  , ul [id "refl-buttons"]
      [ li [] [ button [ onClick SubmitReflection ] [ text "Submit" ] ] 
      ]
  , showText model
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
        , Html.Attributes.value model.text
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
  , div [id "md-text"] [Markdown.toHtml [] model.text]
  ]