#pragma once

#include <QObject>
#include <QVariantMap>
#include <QMap>
#include <QString>
#include <QVariant>

struct SongInfo
{
    QString filePath;
    QString title;
    QString artist;
    QString album;
};

class FileMetaReader : public QObject
{
    Q_OBJECT
public:
    explicit FileMetaReader(QObject *parent = nullptr);

    //图片提取
    Q_INVOKABLE QString getCoverBase64(const QString &filePath);

    Q_INVOKABLE QVariantMap getFileInfo(const QString &filePath);

    Q_INVOKABLE QString getLyrics(const QString &filePath);

private:
    //返回图片数据
    QByteArray extractCoverImage(const QString &localPath);
};
