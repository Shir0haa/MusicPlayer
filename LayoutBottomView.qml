import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import QtCore


Rectangle{

    property var mediaPlayer

    // 播放列表
    property var playList: []
    property int current: -1


    property int currentPlayMode: 0
    //三种播放模式
    property var playModeList: [
        {icon:"single-repeat",name:"单曲循环"},
        {icon:"repeat",name:"顺序播放"},
        {icon:"random",name:"随机播放"}]

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
            onClicked: playPrevious()
        }
        MusicIconButton {
            Layout.preferredWidth: 50
            //动态设置暂停/播放图标
            icon.source: mediaPlayer.playbackState === MediaPlayer.PlayingState
                         ? "qrc:/images/pause"
                         : "qrc:/images/stop"
            toolTip: mediaPlayer.playbackState === MediaPlayer.PlayingState
                     ? "暂停"
                     : "播放"
            onClicked: playOrPause()
        }

        MusicIconButton{
            Layout.preferredWidth: 50
            icon.source: "qrc:/images/next"
            toolTip: "下一曲"
            onClicked: playNext()
        }


        Item {
            Layout.preferredWidth: parent.width/2
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.topMargin: 25

            Text {
                id: nameText
                anchors.left: slider.left
                anchors.bottom: slider.top
                anchors.leftMargin: 5
                text: musicName ? musicName : qsTr("暂无歌曲")
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
            iconWidth: 32
            iconHeight: 32
            toolTip: "添加喜欢"
            onClicked: saveFavorite( playList[current])
        }
        //加载播放模式图标
        MusicIconButton{
            Layout.preferredWidth: 50
            icon.source: "qrc:/images/"+playModeList[currentPlayMode].icon
            iconWidth: 32
            iconHeight: 32
            toolTip: playModeList[currentPlayMode].name
            onClicked: changePlayMode()
        }

        //添加倍速功能（只增加0.9x,1.1x）因为变速会导致变调,会影响听歌体验
        Button {
            id: speedButton
            text: mediaPlayer.playbackRate + "x"
            font.pixelSize: 14
            background: Rectangle {
                radius: 6
                color: "#00AAAA"
                border.color: "#ffffff"
            }
            contentItem: Text {
                text: speedButton.text
                color: "white"
                font.bold: true
                anchors.centerIn: parent
            }

            onClicked: {
                // 使用 popup(x, y)，确保菜单弹出在按钮处
                speedMenu.popup(speedButton.mapToItem(null, 0, speedButton.height).x,
                                speedButton.mapToItem(null, 0, speedButton.height).y)
            }
            ToolTip.text: "当前倍速：" + mediaPlayer.playbackRate + "x"
        }

        Menu {
            id: speedMenu
            MenuItem { text: "0.9x"; onTriggered: setSpeed(0.9) }
            MenuItem { text: "1x"; onTriggered: setSpeed(1.0) }
            MenuItem { text: "1.1x"; onTriggered: setSpeed(1.1) }
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


    // 设置倍速函数
    function setSpeed(value) {
        mediaPlayer.playbackRate = value
        speedButton.text = value + "x"
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

    //改变播放模式
    function changePlayMode(){
        currentPlayMode = (currentPlayMode+1)%playModeList.length
        localSettings.setValue("currentPlayMode",currentPlayMode)
    }

    // 播放上一首
    function playPrevious(){
          if(playList.length<1)return
          switch(currentPlayMode){
          case 1:
              current = (current+playList.length-1)%playList.length
              break
          case 2:{
              var random = parseInt(Math.random()*playList.length)
              current = current === random?random+1:random
              break
          }
          }
      }



    // 播放下一首
    function playNext(type='natural'){
        if(playList.length<1)return
        switch(currentPlayMode){
        case 0:
            if(type==='natural'){
                mediaPlayer.play()
            }break
        case 1:
            current = (current+1)%playList.length
            break
        case 2:{
            var random = parseInt(Math.random()*playList.length)
            current = current === random?random+1:random
            break
        }
        }
    }
    //收藏我的喜欢
    function saveFavorite(value = {})
    {
        //对象参数验证
        if (!value || !value.id) {
            console.error("无效的歌曲对象");
            return;
        }
        //读取现有收藏列表
        var favorites = [];
        try {
            var storedData = favoriteSettings.value("favorite", "[]");
            favorites = JSON.parse(storedData);
            if (!Array.isArray(favorites)) {
                console.warn("收藏数据格式错误，重置为空数组");
                favorites = [];
            }
        } catch (a) {
            console.error("解析收藏列表失败:", a);
            favorites = [];
        }
       //检查是否已存在
        var exists = favorites.some(item => String(item.id) === String(value.id));
        if (exists) {
            console.log("歌曲已存在于收藏中");
            return;
        }
        // 准备要保存的歌曲数据
        var songToSave = {
            id: String(value.id),
            name: String(value.name || "未知歌曲"),
            artist: String(value.artist || "未知艺术家"),
            url: value.url ? String(value.url) : "",
            type: value.type ? String(value.type) : "0",
            album: String(value.album || "本地音乐")
        };
        //添加到收藏列表开头
        favorites.unshift(songToSave);
        //限制收藏数量
        if (favorites.length > 500) {
            favorites = favorites.slice(0, 500);
        }

        //保存到设置
        try {
            favoriteSettings.setValue("favorite", JSON.stringify(favorites));
            console.log("收藏成功，当前收藏数:", favorites.length);
            //更新UI
            if (favoriteListView && favoriteListView.musicList) {
                favoriteListView.musicList = favorites;
            }
        } catch (e) {
            console.error("保存收藏失败:", e);
        }
    }
}
