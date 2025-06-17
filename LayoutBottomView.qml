import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

Rectangle{
    Layout.fillWidth: true
    height: 60
    color: "green"

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
                text: qsTr("00:00/05:20")
                font.family: "微软雅黑"
                color: "#ffffff"
            }
            //播放进度条
            Slider{
                id:slider
                width: parent.width
                Layout.fillWidth: true
                height: 25
                background:Rectangle{
                    //居中
                    x:slider.leftPadding
                    y:slider.topPadding+(slider.availableHeight-height)/2
                    width: slider.availableWidth
                    height: 4
                    radius: 2
                    color: "#e9f4ff"

                    //左右拖动进度条的颜色变化
                    Rectangle{
                        width: slider.visualPosition*parent.width
                        height: parent.height
                        color: "#73a7ab"
                        radius: 2
                    }
                }
                handle:Rectangle{
                    x:slider.leftPadding+(slider.availableWidth-width)*slider.visualPosition
                    y:slider.topPadding+(slider.availableHeight-height)/2
                    width: 15
                    height: 15
                    radius: 5
                    color: "#f0f0f0"
                    border.color: "#73a7ab"
                    border.width: 0.5
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
}
