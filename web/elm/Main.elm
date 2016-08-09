port module Main exposing (..)
import Html exposing (text, Html)
import JSPhoenix exposing (ChannelEventMsg, ChanExitCB)
import Markdown exposing (..)
import Json.Decode exposing (int, string, bool)
import Json.Encode exposing (null)
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
  , old : Maybe { String, List RoomSyncMeta }
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
port portReflection: (ChannelEventMsg RoomMessage Model -> msg) -> Sub msg


connect_room rid =
  JSPhoenix.connect
      { topic = "reflection"
      , timeout_ms = Nothing -- Just 10000 -- Default value is 10000 if Nothing is used
      , chanCloseCB = Nothing
      , chanErrorCB = Nothing
      , syncState = Just { portName = "onRoomSyncState", cb_data = (int rid) }
      , syncJoin = Just { portName = "onRoomSyncJoin", cb_data = (int rid) }
      , syncLeave = Just { portName = "onRoomSyncLeave", cb_data = (int rid) }
      , joinData = null
      , joinEvents =
          [ { portName = "onRoomConnect", msgID = "ok", cb_data = (int rid) }
          ]
      , onPorts =
          [ { portName = "onRoomInfo", msgID = "room:info", cb_data = (int rid) }
          , { portName = "onRoomMsgsInit", msgID = "msgs:init", cb_data = (int rid) }
          , { portName = "onRoomMsgsAdd", msgID = "msgs:add", cb_data = (int rid) }
          ]
      }

type Msg
    = SubmitReflection Model

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    SubmitReflection _ ->
        ( model, Cmd.none )
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


view : Model -> Html Msg
view = 
    p [] [ text "Hello Foo" ]
  

main = Html.program
  { init = init
  , update = update
  , view = view
  , subscriptions = (\model -> portReflection SubmitReflection)
  }
 