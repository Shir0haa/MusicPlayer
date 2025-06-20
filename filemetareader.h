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

    Q_INVOKABLE QVariantMap getFileInfo(const QString &filePath);
};
