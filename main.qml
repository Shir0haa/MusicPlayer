import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
import QtMultimedia

Window {
    id:window

    property int mWINDOW_WIDTH: 1200
    property int mWINDOW_HEIGHT: 800

    width: 1200
    height: 800
    visible: true
    title: qsTr("鸟白岛音乐播放器")


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

            if(times.length>0){
                var count = times.filter(time=>time<position).length
                pageDetailView.current  = (count===0)?0:count-1
            }
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
        PageDetailView{
            id:pageDetailView
            visible: false
        }

        //底部工具栏
        LayoutBottomView{
            id:layoutBottomView
            //传入mediaPlayer
            // mediaPlayer: mediaPlayer

        }
    }

}






























