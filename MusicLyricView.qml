import QtQuick
import QtQuick.Layouts
import QtQml

Rectangle {
    // 对外暴露当前高亮项的索引
    property alias current: list.currentIndex
    // 对外暴露歌词数据模型
    property alias lyrics: list.model

    id: lyricView

    // 设置高度为父项高度的80%
    Layout.preferredHeight: parent.height * 0.8
    // 居中对齐
    Layout.alignment: Qt.AlignCenter

    // 启用裁剪，防止内容溢出
    clip: true

    ListView {
        id: list
        anchors.fill: parent
        // 默认歌词数据（测试用）
        model: ["当前歌曲暂无歌词....", "Shiroha", "Asuka"]
        // 使用自定义的委托组件
        delegate: listDelegate

        // 高亮当前选中项的背景
        highlight: Rectangle {
            color: "#2073a7db"  // 半透明蓝色
        }

        // 高亮移动和大小变化动画时间为0（无动画）
        highlightMoveDuration: 0
        highlightResizeDuration: 0

        // 初始选中第0项
        currentIndex: 0

        // 设置高亮区域的位置（居中）
        preferredHighlightBegin: parent.height / 2 - 50
        preferredHighlightEnd: parent.height / 2

        // 强制高亮区域严格匹配（不允许部分显示）
        highlightRangeMode: ListView.StrictlyEnforceRange
    }

    Component {
        id: listDelegate

        Item {
            id: delegateItem
            width: list.width
            height: 50  // 每行高度50

            // 歌词
            Text {
                text: modelData
                anchors.centerIn: parent
                // 当前选中项为黑色，其他为灰色
                color: index === list.currentIndex ? "black" : "#505050"
                font.pointSize: 12
            }

            // 状态：当前选中项放大1.2倍
            states: State {
                when: delegateItem.ListView.isCurrentItem
                PropertyChanges {
                    target: delegateItem
                    scale: 1.2
                }
            }

            TapHandler {
                // 点击时切换当前选中项
                onTapped: list.currentIndex = index
            }
        }
    }
}
