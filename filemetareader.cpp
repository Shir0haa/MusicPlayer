#include "filemetareader.h"
#include <QVariantMap>
#include <QUrl>
#include <taglib/mpegfile.h>
#include <taglib/id3v2tag.h>
#include <taglib/textidentificationframe.h>
#include <taglib/flacfile.h>
#include <taglib/wavfile.h>
#include <QFileInfo>

FileMetaReader::FileMetaReader(
    QObject *parent)
    : QObject(parent)
{}

// 获取音乐文件的元数据信息
QVariantMap FileMetaReader::getFileInfo(
    const QString &filePath)
{
    QVariantMap result;
    result["filePath"] = filePath;

    // 将 QML 传入的 URL 转换为本地文件路径
    QString localPath = QUrl(filePath).toLocalFile();

    // 获取文件后缀名（小写）
    QString suffix = QFileInfo(localPath).suffix().toLower();

    // 添加 qDebug 调试输出
    //qDebug() << "File path:" << localPath << " Suffix:" << suffix;

    // 根据后缀名选择对应的 TagLib 解析方式，处理三种文件格式
    if (suffix == "mp3") {
        TagLib::MPEG::File file(localPath.toUtf8().constData());
        if (file.isValid()) {
            auto *tag = file.tag();
            result["title"] = QString::fromStdWString(tag->title().toWString());
            result["artist"] = QString::fromStdWString(tag->artist().toWString());
            result["album"] = QString::fromStdWString(tag->album().toWString());
            return result;
        }
    } else if (suffix == "flac") {
        TagLib::FLAC::File file(localPath.toUtf8().constData());
        if (file.isValid()) {
            auto *tag = file.tag();
            result["title"] = QString::fromStdWString(tag->title().toWString());
            result["artist"] = QString::fromStdWString(tag->artist().toWString());
            result["album"] = QString::fromStdWString(tag->album().toWString());
            return result;
        }
    } else if (suffix == "wav") {
        TagLib::RIFF::WAV::File file(localPath.toUtf8().constData());
        if (file.isValid()) {
            auto *tag = file.tag();
            result["title"] = QString::fromStdWString(tag->title().toWString());
            result["artist"] = QString::fromStdWString(tag->artist().toWString());
            result["album"] = QString::fromStdWString(tag->album().toWString());
            return result;
        }
    }

    // 如果无法通过 TagLib 获取元数据，则采用文件名作为歌曲标题（后续处理）
    result["title"] = "未知";
    result["artist"] = "未知";
    result["album"] = "本地音乐";
    return result;
}
