import QtQuick
import QtQuick.Controls

Button{
    property alias btnText: self.text
    property alias isCheckable:self.checkable
    property alias isChecked:self.checked
    property alias btnWidth: self.width
    property alias btnHeight: self.height

    id:self

    text: "Button"

    font.pointSize: 14

    background: Rectangle{
        implicitHeight: self.height
        implicitWidth: self.width
        color: self.down || (self.checkable && self.checked) ? "#D3D3D3" : "#A9A9A9"
        radius: 3
    }
    width: 50
    height: 50
    checkable: false
    checked: false
}
