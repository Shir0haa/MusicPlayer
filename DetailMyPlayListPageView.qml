import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Qt.labs.settings
import QtCore

Frame {
    id: playListPage
    Layout.fillWidth: true
    Layout.fillHeight: true
    padding: 0

    // 歌单数据
    property var playLists: []
    property int currentPlayListIndex: -1
    property var currentPlayList: currentPlayListIndex >= 0 ? playLists[currentPlayListIndex] : null

    // 初始化加载歌单数据
    function loadPlayLists() {
        var savedPlayLists = localSettings.value("playLists", "[]")
        try {
            playLists = JSON.parse(savedPlayLists)
            if (!Array.isArray(playLists)) {
                playLists = []
            }
            if (playLists.length > 0) {
                currentPlayListIndex = 0
                updateMusicListView()
            } else {
                musicListView.musicList = []
            }
        } catch (e) {
            console.error("加载歌单失败:", e)
            playLists = []
        }
        playListComboBox.model = playLists  // 更新下拉框
    }

    // 更新音乐列表视图
    function updateMusicListView() {
        if (currentPlayListIndex >= 0 && playLists[currentPlayListIndex]) {
            musicListView.musicList = playLists[currentPlayListIndex].songs || []
        } else {
            musicListView.musicList = []
        }
    }

    // 保存歌单数据
    function savePlayLists() {
        localSettings.setValue("playLists", JSON.stringify(playLists))
        loadPlayLists()  // 保存后刷新数据
    }

    // 创建新歌单
    function createPlayList(name) {
        var newPlayList = {
            id: "playlist-" + Date.now(),
            name: name || "新建歌单",
            cover: "qrc:/images/default-cover.png",
            songs: [],
            createTime: new Date().toISOString()
        }
        playLists.push(newPlayList)
        savePlayLists()
        return newPlayList
    }

    // 删除当前歌单
    function deleteCurrentPlayList() {
        if (currentPlayListIndex < 0) return

        playLists.splice(currentPlayListIndex, 1)
        savePlayLists()

        if (playLists.length > 0) {
            currentPlayListIndex = Math.min(currentPlayListIndex, playLists.length - 1)
            updateMusicListView()
        } else {
            currentPlayListIndex = -1
            musicListView.musicList = []
        }
    }

    // 添加歌曲到当前歌单
    function addSongsToCurrentPlayList(songs) {
        if (currentPlayListIndex < 0 || !playLists[currentPlayListIndex]) {
            showMessage("请先选择或创建一个歌单")
            return 0
        }

        // 确保songs数组存在
        if (!playLists[currentPlayListIndex].songs) {
            playLists[currentPlayListIndex].songs = []
        }

        // 去重检查
        var existingIds = playLists[currentPlayListIndex].songs.map(song => song.id)
        var newSongs = songs.filter(song => song && song.id && !existingIds.includes(song.id))

        if (newSongs.length === 0) {
            showMessage("没有可添加的新歌曲或歌曲已存在")
            return 0
        }

        playLists[currentPlayListIndex].songs = playLists[currentPlayListIndex].songs.concat(newSongs)
        savePlayLists()

        // 更新当前视图
        updateMusicListView()

        return newSongs.length
    }

    Component.onCompleted: loadPlayLists()

    // 创建歌单对话框
    Dialog {
        id: createPlayListDialog
        width: Math.min(window.width * 0.8, 400)
        title: "新建歌单"
        standardButtons: Dialog.Ok | Dialog.Cancel

        onAccepted: {
            var name = nameField.text.trim()
            if (name !== "") {
                var newPlayList = createPlayList(name)
                currentPlayListIndex = playLists.length - 1
                updateMusicListView()
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 15

            TextField {
                id: nameField
                Layout.fillWidth: true
                placeholderText: "输入歌单名称"
                focus: true
            }
        }
    }

    // 删除歌单确认对话框
    Dialog {
        id: deleteConfirmDialog
        width: Math.min(window.width * 0.8, 400)
        title: "删除歌单"
        standardButtons: Dialog.Yes | Dialog.No

        Label {
            text: "确定要删除歌单 \"" + (currentPlayList ? currentPlayList.name : "") + "\" 吗？"
            wrapMode: Text.Wrap
        }

        onAccepted: deleteCurrentPlayList()
    }

    // 添加本地歌曲对话框
    FileDialog {
        id: fileDialog
        title: "选择音乐文件"
        nameFilters: ["音乐文件 (*.mp3 *.wav *.flac *.ogg *.aac)"]
        fileMode: FileDialog.OpenFiles

        onAccepted: {
            var songsToAdd = []
            for (var i = 0; i < selectedFiles.length; i++) {
                var filePath = selectedFiles[i].toString()
                // 修复Windows路径问题
                if (Qt.platform.os === "windows") {
                    filePath = filePath.replace(/^file:\/\//, "")
                } else {
                    filePath = filePath.replace(/^file:\/\//, "/")
                }

                var fileName = filePath.substring(filePath.lastIndexOf('/') + 1)
                var dotIndex = fileName.lastIndexOf('.')
                var songName = dotIndex > 0 ? fileName.substring(0, dotIndex) : fileName
                var fileExtension = dotIndex > 0 ? fileName.substring(dotIndex + 1).toLowerCase() : ""

                songsToAdd.push({
                    id: "local-" + Date.now() + "-" + i,
                    name: songName,
                    artist: "未知艺术家",
                    album: "未知专辑",
                    url: filePath,
                    type: fileExtension,
                    source: "local"
                })
            }

            var addedCount = addSongsToCurrentPlayList(songsToAdd)
            if (addedCount > 0) {
                showMessage("成功添加 " + addedCount + " 首歌曲到歌单")
            }
        }
    }

    // 主界面布局
    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // 标题栏
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 60
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                spacing: 10

                Label {
                    Layout.leftMargin: 15
                    text: "歌单"
                    font.pixelSize: 25
                    color: "#ADD8E6"
                }

                Button {
                    text: "刷新数据"
                    implicitWidth: 100
                    onClicked: loadPlayLists()
                }
            }
        }

        // 歌单信息展示区
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 15
            Layout.rightMargin: 15
            spacing: 20
            visible: currentPlayListIndex >= 0

            MusicRoundImage {
                id: coverImage
                Layout.preferredWidth: 120
                Layout.preferredHeight: 120
                borderRadius: 5
                imgSrc: currentPlayList ? currentPlayList.cover : "qrc:/images/default-cover.png"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                Label {
                    text: currentPlayList ? currentPlayList.name : ""
                    font.pixelSize: 24
                    color: "#EEEEEE"
                    elide: Text.ElideRight
                }

                Label {
                    text: "歌曲数: " + (currentPlayList ? currentPlayList.songs.length : 0)
                    font.pixelSize: 14
                    color: "#AAAAAA"
                }

                Label {
                    text: "创建时间: " + (currentPlayList ? new Date(currentPlayList.createTime).toLocaleDateString() : "")
                    font.pixelSize: 14
                    color: "#AAAAAA"
                }

                RowLayout {
                    spacing: 10

                    Button {
                        text: "播放全部"
                        implicitWidth: 100
                        enabled: currentPlayList && currentPlayList.songs.length > 0
                        onClicked: {
                            layoutBottomView.playList = currentPlayList.songs
                            layoutBottomView.current = 0
                        }
                    }

                    Button {
                        text: "随机播放"
                        implicitWidth: 100
                        enabled: currentPlayList && currentPlayList.songs.length > 0
                        onClicked: {
                            layoutBottomView.playList = currentPlayList.songs
                            layoutBottomView.current = Math.floor(Math.random() * currentPlayList.songs.length)
                        }
                    }
                }
            }
        }

        // 操作按钮栏
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            spacing: 10

            Button {
                text: "新建歌单"
                implicitWidth: 120
                implicitHeight: 40
                onClicked: createPlayListDialog.open()
            }

            Button {
                text: "删除歌单"
                implicitWidth: 120
                implicitHeight: 40
                enabled: currentPlayListIndex >= 0
                onClicked: deleteConfirmDialog.open()
            }

            Button {
                text: "添加本地歌曲"
                implicitWidth: 120
                implicitHeight: 40
                enabled: currentPlayListIndex >= 0
                onClicked: fileDialog.open()
            }
        }

        // 歌单选择下拉框
        ComboBox {
            id: playListComboBox
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            model: playLists
            textRole: "name"
            enabled: playLists.length > 0

            onActivated: function(index) {
                currentPlayListIndex = index
                updateMusicListView()
            }

            Component.onCompleted: {
                if (playLists.length > 0) {
                    currentPlayListIndex = 0
                    currentIndex = 0
                }
            }
        }

        // 歌曲列表
        MusicListView {
            id: musicListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            deletable: true
            favoritable: true

            onDeleteItem: function(index) {
                if (currentPlayListIndex >= 0 && index >= 0 && playLists[currentPlayListIndex]?.songs && index < playLists[currentPlayListIndex].songs.length) {
                    playLists[currentPlayListIndex].songs.splice(index, 1)
                    savePlayLists()
                    updateMusicListView()
                    showMessage("已从歌单移除歌曲")
                }
            }
        }
    }

    // 消息提示
    function showMessage(text) {
        messagePopup.text = text
        messagePopup.open()
    }

    Popup {
        id: messagePopup
        width: 200
        height: 50
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        modal: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property alias text: messageLabel.text

        Label {
            id: messageLabel
            anchors.centerIn: parent
            color: "#EEEEEE"
        }

        background: Rectangle {
            color: "#60000000"
            radius: 5
        }

        Timer {
            interval: 2000
            running: messagePopup.opened
            onTriggered: messagePopup.close()
        }
    }
}
