#pragma once

#include <QObject>

class FileIO : public QObject
{
    Q_OBJECT
public:
    explicit FileIO(QObject *parent = nullptr);

    Q_INVOKABLE bool exists(const QString &path) const;
    Q_INVOKABLE QString readAll(const QString &path) const;
};
