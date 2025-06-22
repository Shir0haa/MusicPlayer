import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Controls
import QtQml


Frame{

    property var musicList: []  //存储当前页面的音乐数据列表
    property int all: 0
    property int pageSize: 60
    property int current: 0

    property bool deletable: true
    property bool favoritable: true //功能开关属性

    signal loadMore(int offset,int current) //当用户点击分页按钮或滚动到底部需要加载下一页时
    signal deleteItem(int index) //用户点击某首歌曲的"删除"按钮时触发


    onMusicListChanged: {
        listViewModel.clear()
        listViewModel.append(musicList)
    }

    Layout.fillHeight: true
    Layout.fillWidth: true

    clip: true
    padding: 0

    background: Rectangle{
        color: "#00000000"
    }


    ListView{
        id:listView
        anchors.fill: parent
        anchors.bottomMargin: 70
        model:ListModel{
            id:listViewModel
        }
        delegate: listViewDelegate
        ScrollBar.vertical: ScrollBar{
            anchors.right: parent.right
        }
        header: listViewHeader
        highlight:Rectangle{
            color: "#00AAAA"
        }
        highlightMoveDuration: 0
        highlightResizeDuration: 0
    }




    //作为 ListView 的委托  用于渲染音乐播放器中的每个歌曲列表项
    Component{
        id:listViewDelegate
        Rectangle{
            id:listViewDelegateItem
            height: 45
            width: listView.width
            color: "#80CCCCCC"

            Shape{
                anchors.fill: parent
                ShapePath{
                    strokeWidth: 0
                    strokeColor: "#50ffffff"
                    strokeStyle: ShapePath.SolidLine
                    startX: 0
                    startY: 45
                    PathLine{
                        x:0
                        y:45
                    }
                    PathLine{
                        y:45
                    }
                }
            }//在列表项底部绘制一条分隔线

            // property bool hovered: false

            // MouseArea{
            //     anchors.fill: parent
            //     hoverEnabled: true
            //     cursorShape: Qt.PointingHandCursor  //鼠标悬停时显示为手型
            //     onEntered: hovered = true
            //     onExited: hovered = false

                RowLayout{
                    width: parent.width
                    height: parent.height
                    spacing: 15
                    x:5
                    Text{
                        text:index+1+pageSize*current //将当前页的索引转换为全局序号
                        horizontalAlignment: Qt.AlignHCenter
                        Layout.preferredWidth: parent.width*0.05
                        font.pointSize: 13
                        color: "#eeffffff"
                        elide: Qt.ElideRight
                    }
                    Text{
                        text:name
                        Layout.preferredWidth: parent.width*0.4
                        font.pointSize: 13
                        color: "#eeffffff"
                        elide: Qt.ElideRight
                    }
                    Text{
                        text:artist
                        horizontalAlignment: Qt.AlignHCenter
                        Layout.preferredWidth: parent.width*0.15
                        font.pointSize: 13
                        color: "#eeffffff"
                        elide: Qt.ElideMiddle
                    }
                    Text{
                        text:album
                        horizontalAlignment: Qt.AlignHCenter
                        Layout.preferredWidth: parent.width*0.15
                        font.pointSize: 13
                        color: "#eeffffff"
                        elide: Qt.ElideMiddle
                    }
                    Item{
                        Layout.preferredWidth: parent.width*0.15
                        RowLayout{
                            anchors.centerIn: parent
                            MusicIconButton{
                                iconSource: "qrc:/images/pause"
                                iconHeight: 16
                                iconWidth: 16
                                toolTip: "播放"
                                onClicked: {
                                    // playMusic(index)
                                    layoutBottomView.playList = musicList
                                    // layoutBottomView.playMusic(index)
                                    // layoutBottomView.current = -1                // 重置当前播放索引
                                    layoutBottomView.playList = musicList        // 设置播放列表
                                    layoutBottomView.current = index             // 播放当前项
                                }
                            }
                            MusicIconButton {
                                visible: favoritable
                                iconSource: "qrc:/images/favorite"
                                iconHeight: 16
                                iconWidth: 16
                                toolTip: "喜欢"
                                onClicked: {
                                    // 传递当前歌曲数据
                                    layoutBottomView.saveFavorite({
                                                                      id: model.id,
                                                                      name: model.name,
                                                                      artist: model.artist,
                                                                      url: model.url,
                                                                      album: model.album,
                                                                      type: model.type
                                                                  });
                                    toolTip.text = "已收藏";
                                }
                            }
                            MusicIconButton {
                                visible: deletable
                                iconSource: "qrc:/images/clear"
                                iconHeight: 16
                                iconWidth: 16
                                toolTip: "删除"

                                onClicked: {
                                    if (favoritable === false) {
                                        deleteFavorite(index); // 收藏列表直接删除
                                    } else {
                                        deleteItem(index); // 其他列表删除
                                    }
                                }
                            }
                        }
                    }
                }

                // 点击处理
                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onTapped: {
                        listViewDelegateItem.ListView.view.currentIndex = index
                    }
                }


                // onClicked: {
                //     listViewDelegateItem.ListView.view.currentIndex = index // 选中当前项
                // }

            // }
        }
    }

    Component{
        id:listViewHeader
        Rectangle{
            color: "#3000AAAA"
            height: 45
            width: listView.width
            RowLayout{
                width: parent.width
                height: parent.height
                spacing: 15
                x:5
                Text{
                    text:"序号"
                    horizontalAlignment: Qt.AlignHCenter//水平居中
                    Layout.preferredWidth: parent.width*0.05//占父容器宽度的5%
                    font.pointSize: 13// 字号13pt
                    color: "#00AAAA"// 浅白色（带透明度）
                    elide: Qt.ElideRight // 文本过长时右侧省略
                }
                Text{
                    text:"歌名"
                    Layout.preferredWidth: parent.width*0.4
                    font.pointSize: 13
                    color: "#00AAAA"
                    elide: Qt.ElideRight
                }
                Text{
                    text:"歌手"
                    horizontalAlignment: Qt.AlignHCenter
                    Layout.preferredWidth: parent.width*0.15
                    font.pointSize: 13
                    color: "#00AAAA"
                    elide: Qt.ElideMiddle
                }
                Text{
                    text:"专辑"
                    horizontalAlignment: Qt.AlignHCenter
                    Layout.preferredWidth: parent.width*0.15
                    font.pointSize: 13
                    color: "#00AAAA"
                    elide: Qt.ElideMiddle
                }
                Text{
                    text:"操作"
                    horizontalAlignment: Qt.AlignHCenter
                    Layout.preferredWidth: parent.width*0.15
                    font.pointSize: 13
                    color: "#00AAAA"
                    elide: Qt.ElideRight
                }
            }
        }
    }

    Item{
        id:pageButton
        visible: musicList.length!==0&&all!==0
        width: parent.width
        height: 40
        anchors.top: listView.bottom
        anchors.topMargin: 20

        ButtonGroup {
            id: pageButtonGroup
            buttons:buttons.children
        }

        RowLayout{
            id:buttons
            anchors.centerIn: parent
            Repeater{
                id:repeater
                model: all/pageSize>9?9:all/pageSize
                Button{
                    Text{
                        anchors.centerIn: parent
                        text: modelData+1

                        font.pointSize: 14
                        color: checked?"#497563":"#eeffffff"
                    }
                    background: Rectangle{
                        implicitHeight: 30
                        implicitWidth: 30
                        color: checked?"#e2f0f8":"#20e9f4ff"
                        radius: 3
                    }
                    checkable: true
                    checked: modelData === current
                    onClicked: {
                        if(current===index) return
                        loadMore(current*pageSize,index)
                    }
                }
            }
        }
    }



}








