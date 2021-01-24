#include "qropnews.h"
#include "qrop.h"

#include <QUrl>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>

QropNews::QropNews(QObject *parent)
    : QObject(parent)
    , m_lang()
    , m_lastUpdate()
    , m_mainText()
    , m_lastRelease()
    , m_news()
    , m_numberOfUnreadNews(0)
    , m_markAsRead(false)
{
}

QropNews::~QropNews()
{
    qDeleteAll(m_news);
}

void QropNews::fetchNews()
{
    m_lang = Qrop::instance()->preferredLanguage();
    if (m_lang == "system")
        m_lang = QLocale::system().name().left(2);

    QString url = QString("%1").arg(s_newsJsonBaseLink);
    if (!m_lang.isEmpty() && m_lang != "en")
        url += QString("_%1").arg(m_lang);
    url += ".json";

    //    qDebug() << "[QropNews::fetchNews] url: " << url;

    QNetworkRequest req(url);
    req.setRawHeader("User-Agent", "Qrop Cpp app");

    QNetworkReply *reply = Qrop::instance()->networkManager().get(req);
    connect(reply, &QNetworkReply::finished, this, &QropNews::onNewsReceived);
}

void QropNews::_error(const QString &err)
{
    m_mainText = err;
    emit newsReceived();
    Qrop::instance()->sendError(err);
}

QString QropNews::toHtml()
{
    if (m_news.isEmpty())
        return QString();

    QString news("<ul>");
    for (News *n : m_news) {
        if (n->unread)
            news += QString("<b><li><font color=\"darkRed\"><i> %1</i></font>").arg(n->date);
        else
            news += QString("<li><i> %1</i> ").arg(n->date);
        if (n->link.isEmpty())
            news += QString("<b>%1</b>").arg(n->title);
        else
            news += QString("<a href=\"%1\">%2</a>").arg(n->link).arg(n->title);
        if (n->unread)
            news += "</b>";
        if (!n->desc.isEmpty())
            news += ": <br/>" + n->desc;
        news += "<br/></li>";
    }
    news += "</ul>";

    return news;
}

void QropNews::onNewsReceived()
{
    QNetworkReply *reply = static_cast<QNetworkReply *>(sender());
    m_numberOfUnreadNews = 0;
    if (reply->error() != QNetworkReply::NoError) {
        _error(tr("Error fetching news: %1").arg(reply->errorString()));
        reply->deleteLater();
        return;
    }

    QVariant contentType = reply->header(QNetworkRequest::ContentTypeHeader);
    if (!contentType.isValid() || !contentType.toString().startsWith("text/plain")) {
        _error(tr("Error fetching news: invalid contentType from url: %1 : %2")
                       .arg(reply->url().toString())
                       .arg(contentType.toString()));
        reply->deleteLater();
        return;
    }

    QString jsonTxt = reply->readAll();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonTxt.toUtf8());
    QJsonObject json = jsonDoc.object();
    m_mainText = json["mainText"].toString();
    m_lastRelease = json["lastRelease"].toString();

    if (Qrop::instance()->newReleaseAvailable(m_lastRelease)) {
        m_mainText += QString("<br/><br/><b><a href=\"%1\">%2 : %3</a></b>")
                              .arg(s_qropDownloadURL)
                              .arg(tr("New version available"))
                              .arg(m_lastRelease);
        ++m_numberOfUnreadNews;
    }

    QJsonArray news = json["news"].toArray();
    //        qDebug() << "[QropNews::onNewsReceived] lastUpdate: " << m_lastUpdate
    //                 << ", lastRelease: " << m_lastRelease << ", news count : " << m_news.count()
    //                 << ", mainText: " << m_mainText;

    qDeleteAll(m_news);
    m_news.clear();
    m_news.reserve(news.count());
    m_lastUpdate = QDate();
    QDate lastNewsUpdate = Qrop::instance()->lastNewsUpdate();
    for (auto it = news.begin(), itEnd = news.end(); it != itEnd; ++it) {
        QJsonObject n = it->toObject();
        QString date, title, link, desc;
        bool unread = false;
        if (n.contains("date")) {
            date = n["date"].toString();
            if (lastNewsUpdate.isNull()
                || QDate::fromString(date, m_lang == "en" ? "MM/dd/yyyy" : "dd/MM/yyyy")
                        > lastNewsUpdate) {
                unread = true;
                ++m_numberOfUnreadNews;
            }
            if (m_lastUpdate.isNull())
                m_lastUpdate = QDate::fromString(date, m_lang == "en" ? "MM/dd/yyyy" : "dd/MM/yyyy");
        }
        if (n.contains("title"))
            title = n["title"].toString();
        if (n.contains("link"))
            link = n["link"].toString();
        if (n.contains("desc"))
            desc = n["desc"].toString();

        if (!date.isEmpty() && !title.isEmpty())
            m_news << new News(date, title, link, desc, unread);
        else
            qCritical() << "unexpected News: " << n;
    }

    emit newsReceived();
    reply->deleteLater();
}
