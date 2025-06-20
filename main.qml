import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
import QtMultimedia
import MyUtils

Window {
    id:window

    property int mWINDOW_WIDTH: 1200
    property int mWINDOW_HEIGHT: 800

    width: 1200
    height: 800
    visible: true
    title: qsTr("鸟白岛音乐播放器")

    HttpUtils{
          id:http
      }

    Component.onCompleted: {
        testHttp()
    }


    Settings
    {
        id: localSettings
        category: "local"
    }
    Settings
    {
        id: favoriteSettings
        category: "favorites"
    }
    Settings
    {
            id:historySettings
            category:"history"
        }


    AudioOutput {
        id: audioOutput
        volume: 1.0
    }

    MediaPlayer{
        id:mediaPlayer

        property var times: []

        onPositionChanged: function(position) {
            //控制底部进度条 同步显示音乐进度
            layoutBottomView.setSlider(0, duration, position)
        }

        audioOutput: audioOutput

        //控制播放按钮与播放状态
        onPlaybackStateChanged: {
            layoutBottomView.playingState = playbackState===MediaPlayer.PlayingState? 1:0

            if(playbackState===MediaPlayer.StoppedState&&layoutBottomView.playbackStateChangeCallbackEnabled){
                layoutBottomView.playNext()
            }
        }
    }


    ColumnLayout{
        anchors.fill: parent
        //添加顶部工具栏
       spacing: 0
       LayoutHeaderView{
           id:layoutHeaderView

       }
       PageHomeView{
           id:pageHomeView

       }

       //底部工具栏
       LayoutBottomView{
           id:layoutBottomView
           //传入mediaPlayer
           mediaPlayer: mediaPlayer

       }
      }

}






























