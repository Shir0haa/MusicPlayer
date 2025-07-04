//MusicBannerView.qml
// 音乐横幅轮播视图组件

import QtQuick
import QtQuick.Controls
import QtQml

// 使用Frame作为根组件
Frame{
    property int current: 0  // 当前选中的横幅索引
    property alias bannerList : bannerView.model  // 对外暴露的横幅列表数据接口

    // 设置透明背景
    background: Rectangle{
        color: "#00000000"
    }

    // 使用PathView实现3D轮播效果
    PathView{
        id:bannerView
        width: parent.width
        height: parent.height
        clip: true  // 裁剪超出部分

        // 鼠标交互区域
        HoverHandler {
            id: hoverHandler
            acceptedDevices: PointerDevice.Mouse
            onHoveredChanged: {
                if (hovered) {
                    bannerTimer.stop()
                } else {
                    bannerTimer.start()
                }
            }
        }
        //cursorShape: hoverHandler.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor

        // 每个横幅的代理组件
        delegate: Item{
            id:delegateItem
            width:bannerView.width*0.7  // 宽度为视图的70%
            height: bannerView.height
            z:PathView.z?PathView.z:0  // z轴层级
            scale: PathView.scale?PathView.scale:1.0  // 缩放比例

            // 圆形图片组件
            MusicRoundImage{
                id:image
                imgSrc:modelData.imageUrl  // 图片URL
                width: delegateItem.width
                height: delegateItem.height
            }

            // 可点击区域
            TapHandler {
                acceptedButtons: Qt.LeftButton
                onTapped: {
                    if (bannerView.currentIndex === index) {
                        // TODO: 点击当前项的行为
                        var item  =bannerView.model[index]
                        var targetId = item.targetId+""
                        var targetType = item.targetType+"" //1:单曲,10:专辑,1000:歌单
                        switch(targetType){
                        case "1":
                            //播放歌曲
                            layoutBottomView.current = -1
                            layoutBottomView.playList=[{id:targetId,name:"",artist:"",cover:"",album:""}]
                            layoutBottomView.current = 0
                            break
                        case "10":
                            //打开专辑
                        case "1000":
                            //打开播放列表
                            pageHomeView.showPlayList(targetId,targetType)
                            break
                        }
                        // console.log(targetId,targetType)
                    } else {
                        bannerView.currentIndex = index
                    }
                }
            }
        }

        pathItemCount: 3  // 同时显示的横幅数量
        path:bannerPath  // 使用的路径
        preferredHighlightBegin: 0.5  // 高亮区域起始位置
        preferredHighlightEnd: 0.5  // 高亮区域结束位置
    }

    // 定义横幅的显示路径
    Path{
        id:bannerPath
        startX: 0
        startY:bannerView.height/2-10  // Y轴居中并稍微上移

        // 路径起点属性
        PathAttribute{name:"z";value:0}  // z轴层级
        PathAttribute{name:"scale";value:0.6}  // 缩放比例

        // 路径中间点
        PathLine{
            x:bannerView.width/2
            y:bannerView.height/2-10
        }

        // 路径中间点属性(当前选中项)
        PathAttribute{name:"z";value:2}  // 更高层级
        PathAttribute{name:"scale";value:0.85}  // 更大尺寸

        // 路径终点
        PathLine{
            x:bannerView.width
            y:bannerView.height/2-10
        }

        // 路径终点属性
        PathAttribute{name:"z";value:0}
        PathAttribute{name:"scale";value:0.6}
    }

    // 页面指示器
    PageIndicator{
        id:indicator
        anchors{
            top:bannerView.bottom  // 位于轮播图下方
            horizontalCenter: parent.horizontalCenter  // 水平居中
            topMargin: -10  // 上边距
        }
        count: bannerView.count  // 指示点数量
        currentIndex: bannerView.currentIndex  // 当前选中索引
        spacing: 10  // 点间距
        delegate: Rectangle{
            width: 20
            height: 5
            radius: 5  // 圆角矩形
            color: index===bannerView.currentIndex?"black":"gray"  // 当前选中为黑色，其他为灰色
            Behavior on color{  // 颜色变化动画
                ColorAnimation {
                    duration: 200  // 200毫秒过渡
                }
            }

            // 指示点的鼠标交互
            TapHandler {
                onTapped: {
                    bannerTimer.stop()
                    bannerView.currentIndex = index
                    bannerTimer.start()
                }
            }
        }
    }

    // 自动轮播定时器
    Timer{
        id:bannerTimer
        running: true  // 默认运行
        repeat: true  // 循环执行
        interval: 3000  // 3秒间隔
        onTriggered: {
            if(bannerView.count>0)
                bannerView.currentIndex=(bannerView.currentIndex+1)%bannerView.count  // 循环切换
        }
    }
}
