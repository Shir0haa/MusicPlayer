import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
Window {
    width: 1200
    height: 800
    visible: true
    title: qsTr("鸟白岛音乐播放器")

    //添加顶部工具栏
    ToolBar{
        background: Rectangle{
            color: "#00000000"
        }

        width: parent.width
        Layout.fillWidth: true
        // height: 32

        RowLayout{
            anchors.fill: parent
            Layout.fillWidth: true
            height: 32

            ToolButton{
                icon.source: "qrc:/images/music"
                width: 32
                height: 32
            }
            ToolButton{
                icon.source: "qrc:/images/about"
                width: 32
                height: 32
            }
            //弹性布局，让图标挤到一块，不然会分隔很远
            Item {
                id: item
                Layout.fillWidth: true
                height: 32
                Text {
                    id: tx
                    anchors.centerIn: parent
                    text: qsTr("JimmyWang")
                    //字体
                    font.family: window.mFONT_FAMILY
                    font.pointSize: 15
                    color:"black"
                }
            }
            ToolButton{
                icon.source: "qrc:/images/全屏"
                width: 32
                height: 32
            }
            ToolButton{
                icon.source: "qrc:/images/power"
                width: 32
                height: 32
            }
        }
    }
}
