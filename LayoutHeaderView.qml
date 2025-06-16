import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

ToolBar{
    background: Rectangle{
        color: "red"
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
        ToolButton{
            icon.source: "qrc:/images/small-screen"
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
            icon.source: "qrc:/images/minimize-screen"
            width: 32
            height: 32
        }
        ToolButton{
            icon.source: "qrc:/images/full-screen"
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
