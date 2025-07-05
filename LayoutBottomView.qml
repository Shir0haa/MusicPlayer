//LayoutBottomView.qml

import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import QtCore


Rectangle{

    // property var mediaPlayer

    // 播放列表
    property var playList: []
    property int current: -1

    property var loca_wabl_lyric: []


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

    property string coverBase64: ""

    property string musicCover: ""


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
                text: musicName ? musicName + " / " + musicArtist : qsTr("暂无歌曲")

                // text: musicName ? musicName : qsTr("暂无歌曲")
                color: "#ffffff"
            }

            Text {
                id:timeText
                anchors.right: slider.right
                anchors.bottom: slider.top
                // anchors.bottomMargin: 5
                anchors.rightMargin: 5
                text: formatTime(mediaPlayer.position) + " / " + formatTime(mediaPlayer.duration)

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

        //优先显示解析图片，没有则显示默认图片
        MusicBorderImage {
            id: myMusicCover
            width: 50
            height: 50
            imgSrc: musicCover
            // imgSrc: layoutBottomView.musicCover
            // imgSrc: layoutBottomView.coverBase64 !== "" ? layoutBottomView.coverBase64 : "qrc:/images/cat"

            TapHandler {
                onTapped: {
                    pageDetailView.visible = !pageDetailView.visible
                    pageHomeView.visible = !pageHomeView.visible
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

        var currentItem = playList[current]
        //获取播放链接
        if(playList[current].type==="1"){
            //播放本地音乐
            //pageDetailView.lyricView.visible = false
            //pageDetailView.textItem.visible = true

            var parsed = parseLrc(currentItem.lyrics || "")
            pageDetailView.lyricView.lyrics = parsed.lyricsArray.length > 0 ? parsed.lyricsArray : ["暂无歌词"]
            pageDetailView.lyricView.times = parsed.timesArray


            //var currentItem = playList[current]
            //pageDetailView.updateLyrics(currentItem.url)
            playLocalMusic()

        }
        else
            //播放网络音乐
        {
            // local_lyric = false
            // web_lyric = true
            //pageDetailView.lyricView.visible = true
            //pageDetailView.textItem.visible = false

            playWebMusic()

        }
        saveHistory(current)//保存播放历史
    }
    function playLocalMusic() {
        var currentItem = playList[current]
        mediaPlayer.source = currentItem.url
        mediaPlayer.play()
        saveHistory(current)

        musicName = currentItem.name
        musicArtist = currentItem.artist

        // 更新封面 Base64 → 自动驱动所有绑定的 imgSrc 更新
        coverBase64 = metaReader.getCoverBase64(currentItem.url)
        musicCover = coverBase64 !== "" ? coverBase64 : "qrc:/images/cat"
        // musicCover.imgSrc = coverBase64 !== "" ? coverBase64 : "qrc:/images/cat"


        // 解析本地歌词，传递给歌词组件
        var parsed = parseLrc(currentItem.lyrics || "")
                pageDetailView.lyricView.lyrics = parsed.lyricsArray.length > 0 ? parsed.lyricsArray : ["暂无歌词"]
                pageDetailView.lyricView.times = parsed.timesArray



        mediaPlayer.times = parsed.timesArray
        //  // 绑定进度同步
        // mediaPlayer.positionChanged.connect(function() {
        //     pageDetailView.lyricView.position = mediaPlayer.position
        // })


    }

    function parseLrc(lyricsText) {
        var lines = lyricsText.split('\n')
        var parsed = []

        var timeReg = /\[(\d{2}):(\d{2})(?:\.(\d{2,3}))?\]/g

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i]
            var result
            var timesInLine = []

            // 提取所有时间标签
            while ((result = timeReg.exec(line)) !== null) {
                var min = parseInt(result[1])
                var sec = parseInt(result[2])
                var msec = result[3] ? parseInt(result[3]) : 0
                if (result[3] && result[3].length === 2) {
                    msec *= 10
                }
                var timeMs = min * 60 * 1000 + sec * 1000 + msec
                timesInLine.push(timeMs)
            }

            // 提取歌词内容（剥离所有时间标签）
            var text = line.replace(/\[[^\]]+\]/g, '').trim()
            if (text.length === 0) continue  // 忽略空行

            for (var j = 0; j < timesInLine.length; j++) {
                parsed.push({ time: timesInLine[j], text: text })
            }
        }

        // 按时间升序排序
        parsed.sort(function(a, b) {
            return a.time - b.time
        })

        // 拆分为两个数组
        var lyricsArray = []
        var timesArray = []

        for (var k = 0; k < parsed.length; k++) {
            lyricsArray.push(parsed[k].text)
            timesArray.push(parsed[k].time)
        }

        return {
            lyricsArray: lyricsArray,
            timesArray: timesArray
        }
    }





    function playWebMusic(index =  current){
        //获取播放链接
        getUrl(index)

    }

    function getUrl(index){
        //播放
        if(playList.length<index+1) return
        var id = playList[index].id
        if(!id) return

        //设置详情
        // nameText.text = playList[index].name+"/"+playList[index].artist

        function onReply(reply){

            http.onReplySignal.disconnect(onReply)

            // console.log(reply)

            var url = JSON.parse(reply).data[0].url
            if(!url) return

            var cover = playList[index].cover
            if(cover.length<1) {
                //请求Cover
                getCover(id)
            }else{
                musicCover = cover
                getLyric(id)
                // musicCover.imgSrc = cover
            }
            musicName = playList[index].name
            musicArtist = playList[index].artist

            mediaPlayer.source = url
            mediaPlayer.play()
        }

        http.onReplySignal.connect(onReply)
        http.connect("song/url?id="+id)
    }

    //获取封面
    function getCover(id){
        function onReply(reply){
            http.onReplySignal.disconnect(onReply)

            getLyric(id)

            var song = JSON.parse(reply).songs[0]
            var cover = song.al.picUrl
            // var cover = JSON.parse(reply).songs[0].al.picUrl
            if(cover){
                //修改了cover,让search的也可以显示
                musicCover = cover
                if(musicName.length<1)musicName = song.name
                if(musicArtist.length<1)musicArtist = song.ar[0].name
                // musicCover.imgSrc = url
                // coverBase64  = musicCover.imgSrc
            }
            // coverBase64 = url
        }
        http.onReplySignal.connect(onReply)
        http.connect("song/detail?ids="+id)
    }


    function getLyric(id){
        function onReply(reply){
            http.onReplySignal.disconnect(onReply)

            var lyric = JSON.parse(reply).lrc.lyric
            // console.log(lyric)


            if(lyric.length < 0)
                return

            //
            var lyrics = (lyric.replace(/\[.*\]/gi,"")).split("\n")

            if(lyrics.length>0) pageDetailView.lyricsList = lyrics

            var times = []

            lyric.replace(/\[.*\]/gi,function(match,index){
                //match : [00:00.00]
                if(match.length>2){
                    var time  = match.substr(1,match.length-2)
                    var arr = time.split(":")
                    var timeValue = arr.length>0? parseInt(arr[0])*60*1000:0
                    arr = arr.length>1?arr[1].split("."):[0,0]
                    timeValue += arr.length>0?parseInt(arr[0])*1000:0
                    timeValue += arr.length>1?parseInt(arr[1])*10:0

                    times.push(timeValue)
                }
            })

            mediaPlayer.times = times

            // var cover = song.al.picUrl
            // var cover = JSON.parse(reply).songs[0].al.picUrl
            // if(cover){
            //     //修改了cover,让search的也可以显示
            //     musicCover = cover
            //     if(musicName.length<1)musicName = song.name
            //     if(musicArtist.length<1)musicArtist = song.ar[0].name
            // musicCover.imgSrc = url
            // coverBase64  = musicCover.imgSrc
            // }
            // coverBase64 = url
        }

        // mediaPlayer.times = times


        http.onReplySignal.connect(onReply)
        http.connect("lyric?id="+id)
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
        favoriteSettings.setValue("favorite", JSON.stringify(favorites));
        console.log("收藏成功，当前收藏数:", favorites.length);
    }

    //保存播放历史
    function saveHistory(index = 0) {
        //验证索引是否有效
        if (index < 0 || index >= playList.length) {
            console.warn("Invalid index for saveHistory:", index)
            return false
        }

        //获取当前歌曲项并验证
        var item = playList[index]
        if (!item || typeof item !== 'object' || !item.id) {
            console.warn("Invalid music item at index", index, ":", item)
            return false
        }

        //准备要保存的数据
        var historyItem = {
            id: String(item.id || ''),
            name: String(item.name || '未知歌曲'),
            artist: String(item.artist || '未知艺术家'),
            url: String(item.url || ''),
            type: String(item.type || '0'),
            album: String(item.album || '未知专辑'),
            timestamp: new Date().toLocaleString()
        }

        //获取现有历史记录
        var history = []
        try {
            var stored = historySettings.value("history", "[]")
            history = JSON.parse(stored)
            if (!Array.isArray(history)) {
                console.warn("History data is not array, resetting")
                history = []
            }
        } catch (a) {
            console.error("Error reading history:", a)
            history = []
        }
        //移除重复项
        var existingIndex = history.findIndex(i => i.id === historyItem.id)
        if (existingIndex >= 0) {
            history.splice(existingIndex, 1)
        }
        //添加到历史记录开头
        history.unshift(historyItem)
        //限制历史记录数量
        if (history.length > 100) {
            history = history.slice(0, 100)
        }
        //保存到Settings
        try {
            historySettings.setValue("history", JSON.stringify(history));
            //修改history存储结构，实现和favorites统一
            //historySettings.setValue("history", history)
            console.log("History saved successfully")
            return true
        } catch (e) {
            console.error("Error saving history:", e)
            return false
        }
    }
}

