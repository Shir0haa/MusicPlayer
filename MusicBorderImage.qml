import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string imgSrc: "qrc:/images/player"
    property int borderRadius: 5
    property bool isRotating: false
    property real rotationAngle: 0.0

    radius: borderRadius
    color: "#333333"

    MusicRoundImage {
        id: image
        anchors.centerIn: parent
        width: parent.width * 0.9
        height: parent.height * 0.9
        borderRadius: borderRadius
        imgSrc: root.imgSrc
        rotation: root.rotationAngle
        transformOrigin: Item.Center
    }

    NumberAnimation on rotationAngle {
        running: isRotating
        loops: Animation.Infinite
        from: rotationAngle
        to: 360 + rotationAngle
        duration: 10000
        onStopped: rotationAngle = image.rotation
    }
}
