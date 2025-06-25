import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    // 图片资源路径（默认猫咪图片）
    property string imgSrc: "qrc:/images/cat"
    property int borderRadius: 5
    // 控制是否旋转
    property bool isRotating: false
    property real rotationAngle: 0.0

    radius: borderRadius
    color: "#333333"

    // 中心图片组件，显示圆形图片
    MusicRoundImage {
        id: image
        anchors.centerIn: parent
        width: parent.width * 0.9
        height: parent.height * 0.9
        borderRadius: borderRadius
        imgSrc: root.imgSrc
        rotation: root.rotationAngle
        // 旋转中心设置为自身中心
        transformOrigin: Item.Center
    }

     // 控制 rotationAngle 的动画（实现旋转）
    NumberAnimation on rotationAngle {
        running: isRotating
        // 无限循环（一直旋转）
        loops: Animation.Infinite
        from: rotationAngle
        to: 360 + rotationAngle
        duration: 10000
        onStopped: rotationAngle = image.rotation
    }
}
