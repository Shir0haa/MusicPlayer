import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs as Dialogs
import QtCore

ColumnLayout {


    // 用于持久化保存本地音乐列表
    Settings {
        id: localSettings
        category: "local"
    }

    Rectangle {
        Layout.fillWidth: true
        height: 60
        color: "transparent"
        Text {
            anchors.centerIn: parent
            text: "本地音乐"
            font.pointSize: 25
            color: "#eeffffff"
        }
    }

    // 按钮区域：添加、刷新、清空
    RowLayout {
        height: 80
        spacing: 10

        MusicTextButton {
            btnText: "添加本地音乐"
            btnHeight: 50
            btnWidth: 180
            onClicked: fileDialog.open()
        }

        MusicTextButton {
            btnText: "刷新记录"
            btnHeight: 50
            btnWidth: 120
            onClicked: getLocal()
        }

        MusicTextButton {
            btnText: "清空记录"
            btnHeight: 50
            btnWidth: 120
            onClicked: saveLocal([])
        }
    }

    // 显示本地音乐列表的视图组件
    MusicListView {
        id: localListView
        Layout.fillWidth: true
        Layout.fillHeight: true
        onDeleteItem: deleteLocal(index)
    }

    // 文件选择对话框，用于选择音乐文件
    Dialogs.FileDialog {
        id: fileDialog
        title: "选择本地音乐文件"
        // 支持多选
        fileMode: Dialogs.FileDialog.OpenFiles
        // 限定的文件类型
        nameFilters: ["MP3 (*.mp3)", "FLAC (*.flac)", "WAV (*.wav)"]
        currentFolder: StandardPaths.standardLocations(StandardPaths.MusicLocation)[0]


        onAccepted: {
            var list = getLocal()
            for (var i = 0; i < selectedFiles.length; i++) {
                var path = selectedFiles[i].toString()


                // 从 C++ 获取真实音乐信息
                var meta = metaReader.getFileInfo(path)
                var name = meta.title || "未知"
                var artist = meta.artist || "未知"
                var album = meta.album || "本地音乐"


                //部分歌曲并不为标准音乐格式，没有包含歌名歌手等信息，需要从文件名解析
                //仅当歌曲名为“未知”时，尝试从文件名解析歌名（不处理 artist）
                //但文件名有些也不准确，因此只解析歌曲名部分
                if (name === "未知") {
                    var arr = path.split("/")
                    var fileName = arr[arr.length - 1]
                    var fileNameWithoutExt = fileName.substring(0, fileName.lastIndexOf("."))

                    var nameArr = fileNameWithoutExt.split("-")
                    if (nameArr.length > 1) {
                        //使用 '-' 前面部分作为歌名
                        name = nameArr[0].trim()
                    } else {
                        name = fileNameWithoutExt
                    }
                }


                //避免重复导入
                if (!list.some(item => item.id === path)) {
                    list.push({
                        id: path,
                        name: name,
                        artist: artist,
                        album: album,
                        url: path,
                        type: "1"
                    })
                }
            }
            saveLocal(list)
        }

    }

    Component.onCompleted: {
        Qt.application.organizationName = "MyOrganization"
        Qt.application.organizationDomain = "example.com"
        // 加载已保存的本地音乐列表
        getLocal()
    }

    //从本地设置读取音乐列表
    function getLocal() {
        var str = localSettings.value("local", "[]")
        try {
            var list = JSON.parse(str)
            localListView.musicList = list
            return list
        } catch (e) {
            console.log("JSON.parse 出错，清空本地设置:", e)
            saveLocal([])  // 清空错误数据
            return []
        }
    }


    //保存已经导入的本地歌曲，在下次打开时依旧存在能被读取加载
    function saveLocal(list) {
        localSettings.setValue("local", JSON.stringify(list))
        getLocal()
    }

    // 删除指定索引的音乐项
    function deleteLocal(index) {
        var list = getLocal()
        if (index >= 0 && index < list.length) {
            list.splice(index, 1)
            saveLocal(list)
        }
    }
}
