#include "startAPIServer.h"
#include <QApplication>
#include <QFile>
#include <QDebug>
#include <QTimer>

void startAPIServer(QObject* parent) {
    QProcess* apiProcess = new QProcess(parent);

    // 获取应用程序目录
    QString appDir = QApplication::applicationDirPath();

    // 设置 API 可执行文件路径
    QString apiPath = appDir + "/api/netease_api";

    // 设置工作目录为 API 目录
    apiProcess->setWorkingDirectory(appDir + "/api");

    // 设置可执行权限（Linux 需要）
    QFile apiFile(apiPath);
    if (apiFile.exists()) {
        apiFile.setPermissions(QFile::ExeOwner | QFile::ReadOwner | QFile::WriteOwner);
    }

    // 启动 API 服务
    apiProcess->start(apiPath);

    // 检查启动状态
    if (!apiProcess->waitForStarted(3000)) {
        qWarning() << "API服务启动失败:" << apiProcess->errorString();
    } else {
        qDebug() << "API服务已启动，PID:" << apiProcess->processId();
    }

    // 连接输出信号以便调试
    QObject::connect(apiProcess, &QProcess::readyReadStandardOutput, [apiProcess]() {
        qDebug() << "API输出:" << QString::fromUtf8(apiProcess->readAllStandardOutput());
    });

    QObject::connect(apiProcess, &QProcess::readyReadStandardError, [apiProcess]() {
        qWarning() << "API错误:" << QString::fromUtf8(apiProcess->readAllStandardError());
    });

    // 程序退出时终止API进程
    QObject::connect(qApp, &QApplication::aboutToQuit, [apiProcess]() {
        if (apiProcess->state() == QProcess::Running) {
            apiProcess->terminate();
            if (!apiProcess->waitForFinished(1000)) {
                apiProcess->kill();
            }
        }
        apiProcess->deleteLater();
    });
}
