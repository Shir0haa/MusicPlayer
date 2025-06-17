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

        MusicToolButton{
            icon.source: "qrc:/images/music"
            toolTip: "关于"
            onClicked: {
                aboutPop.open()
            }
        }
        MusicToolButton{
            icon.source: "qrc:/images/about"
            toolTip: "09组实训项目，点击进入github项目页"
            onClicked: {
                Qt.openUrlExternally("https://github.com/Shir0haa/MusicPlayer")
            }
        }
        MusicToolButton{
            id:smallWindow
            icon.source: "qrc:/images/small-window"
            toolTip: "小窗播放"
            onClicked: {
                setWindowSize(330,650)
                smallWindow.visible=false
                normalWindow.visible=true
            }
        }

        MusicToolButton{
            id:normalWindow
            iconSource: "qrc:/images/exit-small-window"
            toolTip: "退出小窗播放"
            visible: false
            onClicked: {
                setWindowSize()
                normalWindow.visible=false
                smallWindow.visible=true
            }
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
                // font.family: window.mFONT_FAMILY
                // font.pointSize: 15
                color:"black"
            }
        }
        MusicToolButton{
            icon.source: "qrc:/images/minimize-screen"
            toolTip: "最小化"
            onClicked: {
                window.hide()
            }
        }
        MusicToolButton{
            id:resize
            icon.source: "qrc:/images/small-screen"
            toolTip: "退出全屏"
            visible: false
            onClicked: {
                setWindowSize()
                window.visibility = Window.AutomaticVisibility
                maxWindow.visible = true
                resize.visible = false
            }
        }
        MusicToolButton{
            id:maxWindow
            icon.source: "qrc:/images/full-screen"
            toolTip: "全屏"
                onClicked: {
                window.visibility = Window.Maximized
                maxWindow.visible = false
                resize.visible = true
                }
        }
        MusicToolButton{
            icon.source: "qrc:/images/power"
            toolTip: "退出"
            onClicked: {
                Qt.quit()
            }
        }
    }
    Popup{
    id:aboutPop

            topInset: 0
            leftInset: -2
            rightInset: 0
            bottomInset: 0

            //居中
            parent: Overlay.overlay
            x:(parent.width-width)/2
            y:(parent.height-height)/2

            width: 250
            height: 230

            background: Rectangle{
                color:"#e9f4ff"
                radius: 5
                border.color: "#2273a7ab"
            }

            contentItem: ColumnLayout{
                width: parent.width
                height: parent.height
                Layout.alignment: Qt.AlignHCenter

                Image{
                    Layout.preferredHeight: 60
                    source: "qrc:/images/cat"
                    Layout.fillWidth:true
                    fillMode: Image.PreserveAspectFit

                }

                Text {
                    text: qsTr("Shiroha")
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 18
                    color: "#8573a7ab"
                    font.bold: true
                }
                Text {
                    text: qsTr("这是09组的MusicPlayer")
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 16
                    color: "#8573a7ab"
                    font.bold: true
                }
                Text {
                    text: qsTr("https://github.com/Shir0haa/MusicPlayer")
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 16
                    color: "#8573a7ab"
                    font.bold: true
                }
            }
        }

    //JS function

    function setWindowSize(width = window.mWINDOW_WIDTH,height = window.mWINDOW_HEIGHT){
        window.width = width
        window.height = height
        window.x=(Screen.desktopAvailableWidth-window.width)/2
        window.y=(Screen.desktopAvailableHeight-window.height)/2
    }
}
