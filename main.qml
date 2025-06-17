import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id:window

    property int mWINDOW_WIDTH: 1200
    property int mWINDOW_HEIGHT: 800

    width: 1200
    height: 800
    visible: true
    title: qsTr("鸟白岛音乐播放器")



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

      //底部工具栏
        LayoutBottomView{
            id:layoutBottomView

        }
      }
}






























