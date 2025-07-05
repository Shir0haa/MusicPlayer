import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml


ColumnLayout{

    Rectangle{

        Layout.fillWidth: true
        width: parent.width
        height: 60
        color: "#00000000"
        Text {
            x:10
            verticalAlignment: Text.AlignBottom
            text: qsTr("我喜欢的")
            font.pointSize: 25
            color: "#ADD8E6"
        }
    }

    RowLayout{
        height: 80
        Item{
            width: 5
        }
        MusicTextButton{
            btnText: "刷新记录"
            btnHeight: 50
            btnWidth: 120
            onClicked: getFavorite()
        }
        MusicTextButton{
            btnText: "清空记录"
            btnHeight: 50
            btnWidth: 120
            onClicked: clearFavorite()
        }

    }

    MusicListView
    {
        id:favoriteListView
        favoritable: false
        onDeleteItem: deleteFavorite(index)
    }

    Component.onCompleted:
    {
        getFavorite()
    }

    function getFavorite() {
        try {
            var data = favoriteSettings.value("favorite", "[]");
            favoriteListView.musicList = JSON.parse(data);
        } catch (e) {
            console.error("加载收藏失败:", e);
            favoriteListView.musicList = [];
        }
    }

    function clearFavorite()    //清空记录
    {
        favoriteSettings.setValue("favorite","[]")
        getFavorite()
    }

    function deleteFavorite(index)  //删除
    {
        //读取当前收藏列表
        var favorites = [];
        try {
            var storedData = favoriteSettings.value("favorite", "[]");
            favorites = JSON.parse(storedData);
            if (!Array.isArray(favorites)) {
                console.warn("收藏数据格式错误，重置为空数组");
                favorites = [];
            }
        } catch (a) {
            console.error("解析收藏列表失败:", a);
            favorites = [];
        }
        //验证索引是否有效
        if (index < 0 || index >= favorites.length) {
            console.error("无效的索引:", index);
            return;
        }
        //执行删除
        var deletedSong = favorites[index];
        favorites.splice(index, 1);
        //保存更新后的列表
        try {
            favoriteSettings.setValue("favorite", JSON.stringify(favorites));
            console.log("删除成功，剩余收藏数:", favorites.length);
            //更新UI
            favoriteListView.musicList = favorites;
        } catch (e) {
            console.error("保存删除结果失败:", e);
        }
    }
}
