// MusicGridHotView.qml
// 热门歌单网格视图组件

import QtQuick
import QtQuick.Controls
import QtQml

Item {
    // 对外暴露的属性：获取网格的数据模型
    property alias list: gridRepeater.model

    // 使用 Grid 布局创建网格视图
    Grid {
        id: gridLayout
        anchors.fill: parent  // 填充整个父组件
        columns: 5  // 设置5列布局

        // 使用 Repeater 根据数据模型动态创建子项
        Repeater {
            id: gridRepeater

            // 每个网格项的框架容器
            Frame {
                padding: 5  // 内边距5像素
                width: parent.width * 0.2  // 宽度占父容器的20%（5列）
                height: parent.width * 0.2 + 30  // 高度=图片宽度+文字区域高度

                // 背景矩形（透明）
                background: Rectangle {
                    id: background
                    color: "#00000000"  // 完全透明
                }

                clip: true  // 启用裁剪，超出部分不显示

                // 圆形封面图片组件
                MusicRoundImage {
                    id: img
                    width: parent.width  // 宽度填满父容器
                    height: parent.width  // 高度等于宽度，保持正方形
                    imgSrc: modelData.coverImgUrl  // 绑定封面图片URL
                }

                // 歌单名称文本
                Text {
                    anchors {
                        top: img.bottom  // 定位在图片下方
                        horizontalCenter: parent.horizontalCenter  // 水平居中
                    }
                    text: modelData.name  // 绑定歌单名称数据
                    height: 30  // 固定高度
                    width: parent.width  // 宽度填满父容器
                    verticalAlignment: Text.AlignVCenter  // 文字垂直居中
                    horizontalAlignment: Text.AlignHCenter  // 文字水平居中
                    elide: Qt.ElideMiddle  // 文字过长时在中间显示省略号
                }

                // 鼠标交互区域
                TapHandler {
                    acceptedButtons: Qt.LeftButton  // 接受左键点击
                    gesturePolicy: TapHandler.WithinBounds  // 限制在组件范围内触发
                    cursorShape: Qt.PointingHandCursor  // 鼠标悬停时显示手型指针

                    // 鼠标进入时改变背景色（半透明黑色）
                    onPointChanged: {
                        if (containsPress) {
                            background.color = "#50000000"
                        } else {
                            background.color = "#00000000"
                        }
                    }

                    // 点击事件处理
                    onTapped: {
                        // TODO: 在此处理点击事件，例如进入歌单详情页
                        console.log("点击歌单:", modelData.name)
                    }
                }
            }
        }
    }
}

