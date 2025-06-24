#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include "httputils.h"
#include <QQmlContext>
#include "filemetareader.h"
#include "startAPIServer.h"


int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    // 启动 API 服务
    startAPIServer(&app);

    //参数：qmlRegisterType<C++类型名> (命名空间 主版本 次版本 QML中的类型名)
    qmlRegisterType<HttpUtils>("MyUtils" ,1 ,0 ,"HttpUtils");   //注册到qml

    app.setWindowIcon(QIcon(":/images/cat"));

    // 自定义
    QCoreApplication::setOrganizationName("MyOrg");
    QCoreApplication::setOrganizationDomain("myorg.com");
    QCoreApplication::setApplicationName("ShirohaPlayer");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    FileMetaReader metaReader;
    engine.rootContext()->setContextProperty("metaReader", &metaReader);

    return app.exec();
}


