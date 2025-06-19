import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

ScrollView {

    clip: true  //图片超出范围自动裁剪
    ColumnLayout{

        Rectangle{

            Layout.fillWidth: true
            width: parent.width
            height: 60
            color: "#00000000"
            Text {
                x:10
                verticalAlignment: Text.AlignBottom
                text: qsTr("推荐内容")
                font.pointSize: 25
            }
        }

        MusicBannerView{
            id:bannerView
            Layout.preferredWidth: window.width-200
            Layout.preferredHeight: (window.width-200)*0.3
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Rectangle{

            Layout.fillWidth: true
            width: parent.width
            height: 60
            color: "#00000000"
            Text {
                x:10
                verticalAlignment: Text.AlignBottom
                text: qsTr("热门歌单")
                font.pointSize: 25
            }
        }

        MusicGridHotView{
            id:hotView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: (window.width-250)*0.2*4+30*4+20
            Layout.bottomMargin: 20
        }

        Rectangle{

            Layout.fillWidth: true
            width: parent.width
            height: 60
            color: "#00000000"
            Text {
                x:10
                verticalAlignment: Text.AlignBottom
                text: qsTr("新歌推荐")
                font.pointSize: 25
            }
        }


        MusicGridLatestView{
            id:latestView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: (window.width-230)*0.1*10+20
            Layout.bottomMargin: 20
        }

    }
    Component.onCompleted: {
        getBannerList()
    }

    function getBannerList(){
        function onReply(reply){
            http.onReplySignal.disconnect(onReply)  //断开,解绑

            var banners = JSON.parse(reply).banners     //将网站中的JSON转为string

            bannerView.bannerList = banners //拿到数据

            getHotList()

        }
        http.onReplySignal.connect(onReply) //绑定到c++的replay
        http.connect("banner")
    }


    function getHotList(){
        function onReply(reply){
            http.onReplySignal.disconnect(onReply)  //断开,解绑

            var playlists = JSON.parse(reply).playlists     //将网站中的JSON转为string

            hotView.list = playlists //拿到数据

            getLatestList()
        }
        http.onReplySignal.connect(onReply) //绑定到c++的replay
        http.connect("top/playlist/highquality?limit=20")
    }

    function getLatestList(){
        function onReply(reply){
            http.onReplySignal.disconnect(onReply)  //断开,解绑

            var latestList = JSON.parse(reply).data     //将网站中的JSON转为string

            latestView.list =latestList.slice(0,30) //拿到数据 , 这里只拿30个
        }
        http.onReplySignal.connect(onReply) //绑定到c++的replay
        http.connect("top/song")
    }
}



