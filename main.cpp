#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include "httputils.h"
#include <QQmlContext>
#include "filemetareader.h"
#include "startAPIServer.h"
#include "fileio.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    // 启动 API 服务
    startAPIServer(&app);


    app.setWindowIcon(QIcon(":/images/cat"));

    // 自定义
    //设置组织名和域名，确保Settings能够正常工作
    QCoreApplication::setOrganizationName("MyOrg");
    QCoreApplication::setOrganizationDomain("myorg.com");
    QCoreApplication::setApplicationName("ShirohaPlayer");

    HttpUtils *httpUtils = new HttpUtils(&app);


    // 注册到qml,之前使用的qmlRegisterType,还需要在main.qml只能够import,现在就可以不用import，在QML中作为全局对象

    FileIO fileIo;

    FileMetaReader metaReader;

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("fileIo", &fileIo);

    engine.rootContext()->setContextProperty("http", httpUtils);

    engine.rootContext()->setContextProperty("metaReader", &metaReader);



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

    return app.exec();
}


