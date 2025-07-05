#ifndef HTTPUTILS_H
#define HTTPUTILS_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class HttpUtils : public QObject
{
    Q_OBJECT
public:
    explicit HttpUtils(QObject *parent = nullptr);

    Q_INVOKABLE void replayFinished(QNetworkReply *reply);  //监听事件
    Q_INVOKABLE void connect(QString url);  //连接
private:
    QNetworkAccessManager * manager;
    QString BASE_URL = "http://localhost:3000/";    //默认的录入域名，这里用本地的
signals:
    void replySignal(QString reply);
};

#endif // HTTPUTILS_H
