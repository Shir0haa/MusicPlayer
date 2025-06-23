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
            text: qsTr("历史播放")
            font.pointSize: 25
            color: "#87CEEB"
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
            onClicked: getHistory()
        }
        MusicTextButton{
            btnText: "清空记录"
            btnHeight: 50
            btnWidth: 120
            onClicked: clearHistory()
        }

    }

    MusicListView{
        id:historyListView
        onDeleteItem: deleteHistory(index)
    }


    Component.onCompleted: {
        getHistory()
    }



    function getHistory() {
        var data = historySettings.value("history", "[]");
        historyListView.musicList = JSON.parse(data);

    }

    function clearHistory(){
        historySettings.setValue("history","[]");
        getHistory();
    }


    function deleteHistory(index){
        var list = historySettings.value("history",[])
        if(list.length<index+1)return
        list.splice(index,1)
        historySettings.setValue("history",list)
        getHistory()
    }

}
