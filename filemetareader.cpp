#include "filemetareader.h"
#include <QVariantMap>
#include <QUrl>
#include <taglib/mpegfile.h>
#include <taglib/id3v2tag.h>
#include <taglib/textidentificationframe.h>
#include <taglib/flacfile.h>
#include <taglib/wavfile.h>
#include <QFileInfo>

#include <QBuffer>
#include <QImage>
#include <QDebug>
#include <taglib/id3v2frame.h>
#include <taglib/attachedpictureframe.h>

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

// 读取封面图片 → 转为 Base64 → 返回 data:image/png;base64,...
QString FileMetaReader::getCoverBase64(
    const QString &filePath)
{
    QString localPath = QUrl(filePath).toLocalFile();
    QString suffix = QFileInfo(localPath).suffix().toLower();

    QByteArray coverData;

    if (suffix == "mp3") {
        TagLib::MPEG::File file(localPath.toUtf8().constData());
        if (file.isValid()) {
            auto *tag = file.ID3v2Tag();
            if (tag) {
                auto frames = tag->frameListMap()["APIC"];
                if (!frames.isEmpty()) {
                    auto *frame = dynamic_cast<TagLib::ID3v2::AttachedPictureFrame *>(
                        frames.front());
                    if (frame) {
                        coverData = QByteArray(frame->picture().data(), frame->picture().size());
                    }
                }
            }
        }
    } else if (suffix == "flac") {
        TagLib::FLAC::File file(localPath.toUtf8().constData());
        if (file.isValid()) {
            auto pictures = file.pictureList();
            if (!pictures.isEmpty()) {
                auto pic = pictures.front();
                coverData = QByteArray(pic->data().data(), pic->data().size());
            }
        }
    }
    if (coverData.isEmpty())
        return "";

    return "data:image/jpeg;base64," + coverData.toBase64();
}
// 内部封面提取后返回图片二进制数据
QByteArray FileMetaReader::extractCoverImage(
    const QString &localPath)
{
    QString suffix = QFileInfo(localPath).suffix().toLower();

    if (suffix == "mp3") {
        TagLib::MPEG::File file(localPath.toUtf8().constData());
        if (file.isValid() && file.ID3v2Tag()) {
            auto *tag = file.ID3v2Tag();
            auto frames = tag->frameListMap()["APIC"];
            for (auto *frame : frames) {
                auto *pic = dynamic_cast<TagLib::ID3v2::AttachedPictureFrame *>(frame);
                if (pic && !pic->picture().isEmpty())
                    return QByteArray(pic->picture().data(), pic->picture().size());
            }
        }
    } else if (suffix == "flac") {
        TagLib::FLAC::File file(localPath.toUtf8().constData());
        if (file.isValid()) {
            auto pictures = file.pictureList();
            if (!pictures.isEmpty())
                return QByteArray(pictures.front()->data().data(), pictures.front()->data().size());
        }
    }
    // WAV 不支持专辑封面则不作处理
    return QByteArray();
}
