import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia



Rectangle{

    property var mediaPlayer

    // 播放列表
    property var playList: []
    property int current: -1


    property int currentPlayMode: 0

    // 当前歌曲信息
    property string musicName: ""
    property string musicArtist: ""

    property bool playbackStateChangeCallbackEnabled: false

    // 播放状态（0 停止，1 播放）
    property int playingState: 0


    Layout.fillWidth: true
    height: 60
    color: "#00AAAA"



    RowLayout{
        anchors.fill: parent

        Item {
            Layout.preferredWidth: parent.width/10
            Layout.fillWidth: true
            // Layout.fillHeight: true
        }

        MusicIconButton{
            Layout.preferredWidth: 50
            icon.source: "qrc:/images/previous"
            toolTip: "上一曲"
        }
        MusicIconButton{
            Layout.preferredWidth: 50
            icon.source: "qrc:/images/stop"
            toolTip: "暂停"
            onClicked:playOrPause()

        }
        MusicIconButton{
            Layout.preferredWidth: 50
            icon.source: "qrc:/images/next"
            toolTip: "下一曲"

        }


        Item {
            Layout.preferredWidth: parent.width/2
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.topMargin: 25

            Text {
                id:nameText
                anchors.left: slider.left
                anchors.bottom: slider.top
                // anchors.bottomMargin: 5
                anchors.leftMargin: 5
                text: qsTr("Shiroha")
                font.family: "微软雅黑"
                color: "#ffffff"
            }
            Text {
                id:timeText
                anchors.right: slider.right
                anchors.bottom: slider.top
                // anchors.bottomMargin: 5
                anchors.rightMargin: 5
                text: formatTime(mediaPlayer.position) + " / " + formatTime(mediaPlayer.duration)

                font.family: "微软雅黑"
                color: "#ffffff"
            }

            Slider {
                id: slider
                width: parent.width
                Layout.fillWidth: true
                height: 25

                from: 0
                to: mediaPlayer.duration
                value: mediaPlayer.position

                property bool userIsDragging: false


                onMoved: {
                    mediaPlayer.position = value
                }


                background: Rectangle {
                    //居中
                    x:slider.leftPadding
                    y:slider.topPadding+(slider.availableHeight-height)/2
                    width: slider.availableWidth
                    height: 4
                    radius: 2
                    color: "#e9f4ff"

                    Rectangle {
                        width: slider.visualPosition * parent.width
                        height: parent.height
                        color: "#73a7ab"
                        radius: 2
                    }
                }
            }

        }



        MusicIconButton{
            Layout.preferredWidth: 50
            icon.source: "qrc:/images/favorite"
            toolTip: "喜欢"

        }
        MusicIconButton{
            Layout.preferredWidth: 50
            icon.source: "qrc:/images/repeat"
            toolTip: "重复播放"

        }

        Item {
            Layout.preferredWidth: parent.width/10
            Layout.fillWidth: true
            // Layout.fillHeight: true
        }

    }

    Component.onCompleted: {
        //从配置文件中拿到currentPlayMode
        currentPlayMode =localSettings.value("currentPlayMode",0)
    }

    onCurrentChanged: {
        playbackStateChangeCallbackEnabled =false
        playMusic(current)
    }


    // 时间格式化：00:00
    function formatTime(ms) {
        var sec = Math.floor(ms / 1000)
        var min = Math.floor(sec / 60)
        var s = sec % 60
        return (min < 10 ? "0" + min : min) + ":" + (s < 10 ? "0" + s : s)
    }

    function playOrPause() {
        if(!mediaPlayer.source) return
        if(mediaPlayer.playbackState===MediaPlayer.PlayingState){
            mediaPlayer.pause()
        }else if(mediaPlayer.playbackState===MediaPlayer.PausedState){
            mediaPlayer.play()
        }
    }
    function playMusic(){
        if(current<0)return
        if(playList.length<current+1) return
        //获取播放链接
        if(playList[current].type==="1"){
            //播放本地音乐
            playLocalMusic()
        }
    }
    function playLocalMusic(){
        var currentItem = playList[current]
        mediaPlayer.source =currentItem.url
        mediaPlayer.play()
        musicName = currentItem.name
        musicArtist = currentItem.artist
    }
    // 手动设置进度条范围和当前位置
    function setSlider(from, to, value) {
        slider.from = from
        slider.to = to
        slider.value = value
    }


}
