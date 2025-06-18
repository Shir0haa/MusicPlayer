#include "httputils.h"

HttpUtils::HttpUtils(QObject *parent)
    : QObject{parent}
{
    manager = new QNetworkAccessManager(this); //创建manager成员对象
    QObject::connect(manager , SIGNAL(finished(QNetworkReply*)) , this , SLOT(replayFinished(QNetworkReply*)));

}

void HttpUtils::replayFinished(QNetworkReply *reply)
{
    emit replySignal(reply ->readAll());    //接收信号
}

void HttpUtils::connect(QString url)
{
    QNetworkRequest request;
    request.setUrl(QUrl(BASE_URL + url)); //get请求
    manager ->get(request); //让manager发起get请求

}
