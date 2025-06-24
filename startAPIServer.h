#ifndef STARTAPISERVER_H
#define STARTAPISERVER_H

#include <QObject>
#include <QProcess>
#include <QString>

// 前向声明 QApplication
class QApplication;

// 声明启动API服务器的函数
void startAPIServer(QObject* parent);

#endif // STARTAPISERVER_H
