import QtQuick
import QtQuick.Controls


Button{
    property string iconSource: ""
    property int iconWidth: 32
    property int iconHeight: 32
    //是否被选中
    property bool isCheckable: false
    property bool isChecked: false

    property string toolTip: ""


    id:self

    icon.source: iconSource
    icon.height: iconHeight
    icon.width: iconWidth

    //提示框
    ToolTip.visible: hovered
    ToolTip.text: toolTip

    background: Rectangle{
        //点击按钮变色
        color: self.down||(isCheckable&&self.checked)?"#497563":"#20e9f4ff"
        //透明度
        radius: 3

    }
    icon.color: self.down||(isCheckable&&self.checked)?"#00000000":"#eeeeee"

    checkable: isCheckable
    checked: isChecked

}
