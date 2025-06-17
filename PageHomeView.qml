import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQml

RowLayout{

    //左侧菜单的选项
    property var qmlList: [
        {icon:"recommend-white",value:"推荐内容",qml:"DetailRecommendPageView"},
        {icon:"cloud-white",value:"搜索音乐",qml:"DetailSearchPageView"},
        {icon:"local-white",value:"本地音乐",qml:"DetailLocalPageView"},
        {icon:"history-white",value:"播放历史",qml:"DetailHistoryPageView"},
        {icon:"favorite-big-white",value:"我喜欢的",qml:"DetailFavoritePageView"},
        {icon:"favorite-big-white",value:"专辑歌单",qml:"DetailPlayListPageView"}
    ]
    Frame{

        Layout.preferredWidth: 200
        Layout.fillHeight: true
        background: Rectangle{
            color: "#00AAAA"
        }

        padding: 0


        ColumnLayout{
            anchors.fill: parent

            Item{
                Layout.fillWidth: true
                Layout.preferredHeight: 150

                //圆，把图片裁切成圆形

                MusicRoundImage{
                    anchors.centerIn:parent
                    height: 100
                    width:100
                    borderRadius: 100
                }
            }

            ListView{
                id:menuView
                height: parent.height
                Layout.fillHeight: true
                Layout.fillWidth: true
                model:ListModel{
                    id:menuViewModel
                }
                delegate:menuViewDelegate
                highlight: Rectangle{
                    color: "#00AAAA"
                }
            }
        }

        Component{
            id:menuViewDelegate
            Rectangle{
                id:menuViewDelegateItem
                height: 50
                width: 200
                color: "#00AAAA"
                RowLayout{
                    anchors.fill: parent
                    anchors.centerIn: parent
                    spacing:15
                    Item{
                        width: 30
                    }

                    Image{
                        source: "qrc:/images/"+icon
                        Layout.preferredHeight: 20
                        Layout.preferredWidth: 20
                    }

                    Text{
                        text:value
                        Layout.fillWidth: true
                        height:50
                        color: "#ffffff"
                    }
                }
                //鼠标悬停
                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        color="#aa73a7ab"
                    }
                    onExited: {
                        color="#00AAAA"
                    }
                    //鼠标点击事件，点击左侧菜单加载出对应的菜单
                    onClicked:{
                        repeater.itemAt(menuViewDelegateItem.ListView.view.currentIndex).visible =false
                        menuViewDelegateItem.ListView.view.currentIndex = index
                        var loader = repeater.itemAt(menuViewDelegateItem.ListView.view.currentIndex)
                        loader.visible=true
                        loader.source = qmlList[index].qml+".qml"
                        }
                }
            }
        }

        Component.onCompleted: {
            //打开自动加载推荐页面
            menuViewModel.append(qmlList)
            var loader = repeater.itemAt(0)
            loader.visible = true
            loader.source = qmlList.qml + ".qml"
        }
    }

    //创建list
    Repeater{
        id:repeater
        model: qmlList.length
        Loader{
            visible: failse
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
