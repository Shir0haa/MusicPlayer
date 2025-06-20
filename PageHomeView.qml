import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQml


RowLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true


    // 左侧菜单配置 - 用于初始化 ListModel
    property var qmlList: [
        { icon: "recommend-white", value: "推荐内容", qml: "DetailRecommendPageView" },
        { icon: "cloud-white", value: "搜索音乐", qml: "DetailSearchPageView" },
        { icon: "local-white", value: "本地音乐", qml: "DetailLocalPageView" },
        { icon: "history-white", value: "播放历史", qml: "DetailHistoryPageView" },
        { icon: "favorite-big-white", value: "我喜欢的", qml: "DetailFavoritePageView" },
        { icon: "favorite-big-white", value: "专辑歌单", qml: "DetailPlayListPageView" }
    ]

    // 当前页面索引
    property int currentIndex: 0

    // 左侧菜单
    Frame {
        Layout.preferredWidth: 200
        Layout.fillHeight: true
        background: Rectangle { color: "#00AAAA" }

        ColumnLayout {
            anchors.fill: parent
            spacing: 10

            // 顶部头像
            MusicRoundImage {
                Layout.alignment: Qt.AlignHCenter
                width: 100
                height: 100
                borderRadius: 50
            }

            // 菜单列表
            ListView {
                id: menuView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: ListModel {
                    id: menuViewModel
                }
                delegate: Rectangle {
                    id: menuItem
                    width: parent.width
                    height: 50
                    color: ListView.isCurrentItem ? "#aa73a7ab" : "#00AAAA"

                    RowLayout {
                        anchors.fill: parent
                        spacing: 10
                        Item { width: 20 }  // 左边留白
                        Image {
                            source: "qrc:/images/" + model.icon
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }


                        Text {
                            text: model.value
                            color: "white"
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 16
                        }
                    }

                    // 点击切换页面
                    TapHandler {
                        onTapped: {
                            menuView.currentIndex = index
                            currentIndex = index
                            if (model.qml && model.qml.length > 0) {
                                pageLoader.source = model.qml + ".qml"
                            } else {
                                console.warn("页面未定义：", model)
                            }
                        }
                    }
                }
            }
        }

        // 初始化菜单数据
        Component.onCompleted: {
            for (var i = 0; i < qmlList.length; i++) {
                menuViewModel.append(qmlList[i])
            }
            // 默认加载首页
            if (qmlList.length > 0) {
                pageLoader.source = qmlList[0].qml + ".qml"
            }
        }
    }

    // 右侧页面区域
    Loader {
        id: pageLoader
        Layout.fillWidth: true
        Layout.fillHeight: true
        onStatusChanged: {
            if (status === Loader.Error) {
                console.error("页面加载失败：", source, errorString)
            }
        }
    }
}
