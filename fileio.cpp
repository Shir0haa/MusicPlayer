#include "fileio.h"
#include <QFile>
#include <QTextStream>

FileIO::FileIO(
    QObject *parent)
    : QObject(parent)
{}

bool FileIO::exists(
    const QString &path) const
{
    return QFile::exists(path);
}

QString FileIO::readAll(
    const QString &path) const
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return "";

    //UTF-8 中文歌词
    QTextStream in(&file);
    in.setEncoding(QStringConverter::Utf8);

    return in.readAll();
}
