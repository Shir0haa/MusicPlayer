import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml
import QtCore

Item {
    Layout.fillWidth: true
    Layout.fillHeight: true

    property var currentItem: ({})


    Component.onCompleted: {
        var list = JSON.parse(localSettings.value("local", "[]"))
        for (var i = 0; i < list.length; i++) {
            if (list[i].url === layoutBottomView.musicUrl) {
                currentItem = list[i]
                break
            }
        }

        // 确保 currentItem 包含 lyrics 属性
        if (!currentItem.lyrics) {
            currentItem.lyrics = "当前歌曲暂无歌词"
        }
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
                id: name
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
                imgSrc: layoutBottomView.coverBase64 !== "" ? layoutBottomView.coverBase64 : "qrc:/images/cat"

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

            Flickable {
                anchors.fill: parent
                contentWidth: width
                contentHeight: textItem.height
                clip: true

                // 允许滚动，显示长歌词
                interactive: contentHeight > height

                Text {
                    id: textItem
                    width: parent.width
                    text: currentItem.lyrics || "当前歌曲暂无歌词"
                    color: "black"
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 18

                    // 实现垂直居中
                    anchors.verticalCenter: parent.contentHeight < parent.height ? parent.verticalCenter : undefined
                }
            }
        }

    }
}
