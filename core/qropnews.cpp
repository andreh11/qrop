#include "qropnews.h"
#include"qrop.h"

#include <QUrl>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>

QropNews::QropNews(QObject *parent)
    : QObject(parent)
    , m_lastUpdate(), m_mainText(), m_lastRelease(), m_dateFormat(), m_news()
    , m_netError()
    , m_numTryFetched(0)
{
}


void QropNews::fetchNews()
{
    const QString lang = Qrop::instance()->preferredLanguage();
    QString url = QString("%1").arg(s_newsJsonBaseLink);
    if (!lang.isEmpty() && lang != "en")
        url += QString("_%1").arg(lang);
    url += ".json";
    QNetworkRequest req(url);
    req.setRawHeader("User-Agent", "Qrop Cpp app");

    QNetworkReply *reply = Qrop::instance()->networkManager().get(req);
    connect(reply, &QNetworkReply::finished, this, &QropNews::onNewsReceived);
    ++m_numTryFetched;
}

void QropNews::onNewsReceived()
{
    QNetworkReply *reply = static_cast<QNetworkReply *>(sender());

    if (reply->error() == QNetworkReply::NoError) {
        QVariant contentType = reply->header(QNetworkRequest::ContentTypeHeader);
        if (!contentType.isValid() || !contentType.toString().startsWith("application/json")) {
            Qrop::instance()->sendError(tr("Error fetching news: invalid contentType from url: %1 : %2")
                                        .arg(reply->url().toString())
                                        .arg(contentType.toString()));
            return;
        }
        QString jsonTxt = reply->readAll();
        qDebug() << "Json from " << reply->url().toString() << " : " << jsonTxt;

        QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonTxt.toUtf8());
        QJsonObject json = jsonDoc.object();
    } else
        Qrop::instance()->sendError(tr("Error fetching news: %1").arg(reply->errorString()));

    reply->deleteLater();
}
