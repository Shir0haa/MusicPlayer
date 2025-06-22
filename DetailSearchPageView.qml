import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    Layout.fillHeight: true
    Layout.fillWidth: true

    Rectangle{
        Layout.fillWidth: true
        width: parent.width
        height: 60
        color: "#00000000"
        Text {
            x:10
            verticalAlignment: Text.AlignBottom
            text: qsTr("搜索歌曲")
            font.pointSize: 25
        }
    }

    RowLayout{

        Layout.fillWidth: true        //搜索框
        TextField{
            id:searchInput
            font.pixelSize: 14
            selectByMouse: true
            selectionColor: "#999999"//选中背景颜色
            placeholderText: qsTr("请输入搜索关键词")   //提示
            color: "black"
            background: Rectangle {
                border.width: 2;
                border.color: "#B2B2B2"
                radius: 4;
                color: "#FFFFFF"
                opacity: 0.05
                implicitHeight: 40
                implicitWidth: 400
            }
            focus: true // 聚焦
            Keys.onPressed: function(event) {
                            if(event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                doSearch()
                            }
                        }
        }
        MusicIconButton{
            iconSource: "qrc:/images/search"
            toolTip: "搜索"
            onClicked: doSearch()
        }
    }

    MusicListView{
        id:musicListView
        onLoadMore: function(offset) {
                    doSearch(offset)
                }
    }


    function doSearch(offset = 0) {
        console.log("Searching with offset:", offset) // 更好的日志输出

        var Keywords = searchInput.text
        if (Keywords.length < 1)
            return

        function onReply(reply) {
            http.onReplySignal.disconnect(onReply)
            var result = JSON.parse(reply).result

            if (offset === 0) {
                // 如果是第一页，重置数据
                musicListView.all = result.songCount
                musicListView.musicList = result.songs.map(item => {
                    return {
                        id: item.id,
                        name: item.name,
                        artist: item.artists[0].name,
                        album: item.album.name,
                        cover:""
                    }
                })
            } else {
                // 如果是加载更多，追加数据
                var newSongs = result.songs.map(item => {
                    return {
                        id: item.id,
                        name: item.name,
                        artist: item.artists[0].name,
                        album: item.album.name,
                        cover:""
                    }
                })
                musicListView.musicList = musicListView.musicList.concat(newSongs)
            }
        }

        http.onReplySignal.connect(onReply)
        http.connect("search?keywords=" + Keywords + "&offset=" + offset + "&limit=60")
    }

    // function doSearch(offset = 0){

    //     console.log(offset)

    //     var Keywords = searchInput.text
    //     if(Keywords.length < 1)
    //         return
    //     function onReply(reply){
    //         http.onReplySignal.disconnect(onReply)  //断开,解绑

    //         // console.log(reply)

    //         var result = JSON.parse(reply).result

    //         musicListView.all = result.songCount

    //         musicListView.musicList = result.songs.map(item=>{
    //                                                        return {
    //                                                            id:item.id,
    //                                                            name:item.name,
    //                                                            artist:item.artists[0].name,
    //                                                            album:item.album.name,
    //                                                            cover:""
    //                                                        }
    //                                                    })

    //     }
    //     http.onReplySignal.connect(onReply) //绑定到c++的replay
    //     http.connect("search?keywords=" + Keywords + "&offset=" + offset + "&limit=60")
    // }
}
