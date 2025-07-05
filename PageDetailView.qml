import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml
import QtCore

Item {
    Layout.fillWidth: true
    Layout.fillHeight: true

    property alias lyricView: lyricView
    //property alias textItem: textItem

    property alias lyricsList : lyricView.lyrics

    property alias current : lyricView.current



    property string lastUrl: ""

    //property var currentItem: ({})


    property string currentItemLyrics: "当前歌曲暂无歌词"

    Component.onCompleted: {
        var list = JSON.parse(localSettings.value("local", "[]"))
        for (var i = 0; i < list.length; i++) {
            if (normalizePath(list[i].url) === normalizePath(layoutBottomView.musicUrl)) {
                currentItemLyrics = list[i].lyrics || "当前歌曲暂无歌词"
                console.log("对比路径:", list[i].url, layoutBottomView.musicUrl)
                console.log("导入的歌词内容:", currentItemLyrics)
                break
            }
        }
    }

    // function updateLyrics(url) {
    //     var list = JSON.parse(localSettings.value("local", "[]"))
    //     for (var i = 0; i < list.length; i++) {
    //         if (normalizePath(list[i].url) === normalizePath(url)) {
    //             currentItemLyrics = list[i].lyrics || "当前歌曲暂无歌词"
    //             //console.log("【PageDetailView】设置歌词成功:", currentItemLyrics)
    //             return
    //         }
    //     }
    //     currentItemLyrics = "当前歌曲暂无歌词"
    //     console.log("【PageDetailView】未找到歌词，设置为默认提示")
    // }

    function updateLyrics(url) {
        var list = JSON.parse(localSettings.value("local", "[]"))
        for (var i = 0; i < list.length; i++) {
            if (normalizePath(list[i].url) === normalizePath(url)) {
                var parsed = layoutBottomView.parseLrc(list[i].lyrics || "")
                lyricView.lyrics = parsed.lyricsArray.length > 0 ? parsed.lyricsArray : ["暂无歌词"]
                lyricView.times = parsed.timesArray
                return
            }
        }
        lyricView.lyrics = ["暂无歌词"]
        lyricView.times = []
    }


    function normalizePath(path) {
        if (typeof path !== "string" || path === "") {
            return ""
        }
        if (path.startsWith("file://")) {
            return path.replace("file://", "")
        }
        return path
    }


    RowLayout {
        anchors.fill: parent

        // 左侧部分：封面 + 歌曲信息
        Frame {
            Layout.preferredWidth: parent.width * 0.45
            Layout.fillHeight: true
            padding: 0

            // 歌曲名称
            Text {
                id: nameMusicLyricView
                text: layoutBottomView.musicName
                anchors {
                    bottom: artist.top
                    bottomMargin: 20
                    horizontalCenter: parent.horizontalCenter
                }
                font.pointSize: 20
                color: "black"
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }

            // 歌手
            Text {
                id: artist
                text: layoutBottomView.musicArtist
                anchors {
                    bottom: cover.top
                    bottomMargin: 50
                    topMargin: 20
                    horizontalCenter: parent.horizontalCenter
                }
                font.pointSize: 16
                color: "black"
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }

            // 封面图
            MusicBorderImage {
                id: cover
                anchors.centerIn: parent
                width: parent.width * 0.6
                height: width
                borderRadius: width
                imgSrc: layoutBottomView.musicCover
                // imgSrc: layoutBottomView.coverBase64 !== "" ? layoutBottomView.coverBase64 : "qrc:/images/cat"

                // imgSrc: musicCover.imgSrc = coverBase64 !== "" ? coverBase64 : "qrc:/images/cat"
                isRotating: true
            }
        }

        // 右侧部分：歌词显示
        Frame {
            Layout.preferredWidth: parent.width * 0.55
            Layout.fillHeight: true
            padding: 0
            background: Rectangle { color: "transparent" }


            //统一使用该组件显示歌词
            MusicLyricView{
                id:lyricView
                anchors.fill: parent
                //visible: ture
            }

            // Flickable {
            //     anchors.fill: parent
            //     contentWidth: width
            //     contentHeight: textItem.height
            //     clip: true

            //     // 允许滚动，显示长歌词
            //     interactive: contentHeight > height

            //     Text {
            //         id: textItem
            //         width: parent.width
            //         text: currentItemLyrics
            //         visible:  true
            //         color: "black"
            //         wrapMode: Text.Wrap
            //         horizontalAlignment: Text.AlignHCenter
            //         font.pixelSize: 18

            //         // 实现垂直居中
            //         anchors.verticalCenter: parent.contentHeight < parent.height ? parent.verticalCenter : undefined
            //     }
            // }
        }

    }
}
