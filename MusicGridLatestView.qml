import QtQuick
import QtQuick.Controls
import QtQml

Item {
    // 对外暴露的列表数据接口
    property alias list: gridRepeater.model

    // 使用Grid布局创建3列网格
    Grid {
        id: gridLayout
        anchors.fill: parent  // 填充父项
        columns: 3  // 设置3列布局

        // 使用Repeater动态创建网格项
        Repeater {
            id: gridRepeater

            // 每个网格项的框架
            Frame {
                padding: 5  // 内边距
                width: parent.width * 0.333  // 宽度占父项1/3
                height: parent.width * 0.1  // 固定高度

                // 背景矩形（透明）
                background: Rectangle {
                    id: background
                    color: "#00000000"  // 透明背景
                }

                clip: true  // 裁剪超出内容

                // 圆形专辑封面图片
                MusicRoundImage {
                    id: img
                    width: parent.width * 0.25  // 宽度占父项25%
                    height: parent.width * 0.25 // 保持正方形
                    imgSrc: modelData.album.picUrl  // 绑定专辑图片URL
                }

                // 专辑名称文本
                Text {
                    id: name
                    anchors {
                        left: img.right  // 定位在图片右侧
                        verticalCenter: parent.verticalCenter  // 垂直居中
                        bottomMargin: 10  // 下边距
                        leftMargin: 5  // 左外边距
                    }
                    text: modelData.album.name  // 绑定专辑名称
                    font.pointSize: 11  // 字体大小
                    height: 30  // 固定高度
                    width: parent.width * 0.72  // 文本区域宽度
                    elide: Qt.ElideRight  // 超出部分右侧省略
                }

                // 艺术家名称文本
                Text {
                    anchors {
                        left: img.right  // 定位在图片右侧
                        top: name.bottom  // 位于专辑名称下方
                        leftMargin: 5  // 左外边距
                    }
                    text: modelData.artists[0].name  // 绑定第一个艺术家名称
                    height: 30  // 固定高度
                    width: parent.width * 0.72  // 文本区域宽度
                    elide: Qt.ElideRight  // 超出部分右侧省略
                }

                // 鼠标交互区域
                TapHandler {
                    acceptedButtons: Qt.LeftButton  // 接受左键点击
                    gesturePolicy: TapHandler.WithinBounds  // 限制在组件范围内触发
                    cursorShape: Qt.PointingHandCursor  // 鼠标指针变为手型

                    // 鼠标进入或离开时改变背景色
                    onPressedChanged: {
                        background.color = pressed ? "#50000000" : "#00000000"
                    }

                    // 点击事件（可根据需要自定义行为）
                    onTapped: {
                        console.log("点击专辑:", modelData.album.name)
                    }
                }
            }
        }
    }
}
