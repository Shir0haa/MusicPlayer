//DetailPlayListPageView.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml

ColumnLayout{

    property string targetId: ""
    property string targetType:"10"//album,playlist/detail
    property string name: "-"

    onTargetIdChanged:{
        if(targetType=="10")loadAlbum()
        else if(targetType=="1000") loadPlayList()
    }

    Rectangle{

        Layout.fillWidth: true
        width: parent.width
        height: 60
        color: "#00000000"
        Text {
            x:10
            verticalAlignment: Text.AlignBottom
            text: qsTr(targetType=="10"?"专辑":"歌单")+name
            font.pointSize: 25
            color: "#87CEEB"
        }
    }

    RowLayout{
        height: 200
        width: parent.width
        MusicRoundImage{
            id:playListCover
            width: 180
            height: 180
            Layout.leftMargin: 15
        }

        Item{
            Layout.fillWidth: true
            height: parent.height

            Text{
                id:playListDesc
                width: parent.width*0.95
                anchors.centerIn: parent
                wrapMode: Text.WrapAnywhere //自动换行
                font.pointSize: 14
                maximumLineCount: 4
                elide: Text.ElideRight
                lineHeight: 1.5

            }

        }

    }

    MusicListView{
        id:playListListView
    }
    function loadAlbum(){

        var url = "album?id="+(targetId.length<1?"32311":targetId)

        function onReply(reply){
            http.onReplySignal.disconnect(onReply)
            var album = JSON.parse(reply).album
            var songs = JSON.parse(reply).songs
            playListCover.imgSrc = album.blurPicUrl
            playListDesc.text = album.description
            name = "-"+album.name
            playListListView.musicList= songs.map(item=>{
                                                      return {
                                                          id:item.id,
                                                          name:item.name,
                                                          artist:item.ar[0].name,
                                                          album:item.al.name,
                                                          cover:item.al.picUrl
                                                      }
                                                  })
        }

        http.onReplySignal.connect(onReply)
        http.connect(url)
    }

    function loadPlayList(){

        var url = "playlist/detail?id="+(targetId.length<1?"32311":targetId)


        function onSongDetailReply(reply){
            http.onReplySignal.disconnect(onSongDetailReply)
            // console.log(reply)
            var songs = JSON.parse(reply).songs
            playListListView.musicList= songs.map(item=>{
                                                      return {
                                                          id:item.id,
                                                          name:item.name,
                                                          artist:item.ar[0].name,
                                                          album:item.al.name,
                                                          cover:item.al.picUrl
                                                      }
                                                  })
        }

        function onReply(reply){
            http.onReplySignal.disconnect(onReply)
            var playlist = JSON.parse(reply).playlist
            playListCover.imgSrc = playlist.coverImgUrl
            playListDesc.text = playlist.description
            name = "-"+playlist.name
            var ids = playlist.trackIds.map(item=>item.id).join(",")
            // console.log(ids)
            http.onReplySignal.connect(onSongDetailReply)
            http.connect("song/detail?ids="+ids)

        }
        http.onReplySignal.connect(onReply)
        http.connect(url)
    }
}
