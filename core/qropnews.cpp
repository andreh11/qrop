/*
 * Copyright (C) 2021 André Hoarau <ah@ouvaton.org>
 *                  & Matthieu Bruel <Matthieu.Bruel@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "qropnews.h"
#include "qrop.h"
#include "qrpdate.h"

#include <QUrl>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>

QropNews::QropNews(QObject *parent)
    : QObject(parent)
    , m_lang()
    , m_mainText()
    , m_lastRelease()
    , m_numberOfUnreadNews(0)
    , m_markAsRead(false)
    , m_defaultLangTried(false)
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

    fetchNews(m_lang);
}

void QropNews::fetchNews(const QString &lang)
{
    QNetworkRequest req(QString("%1_%2.json").arg(s_newsJsonBaseLink, lang));
    req.setRawHeader("User-Agent", "Qrop Qt app");

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
    QLocale locale(m_lang);
    for (auto it = m_news.cbegin(), itEnd = m_news.cend(); it != itEnd; ++it) {
        News *n = *it;
        if (n->unread)
            news += QString("<b><li><font color=\"darkRed\"><i>%1 : </i></font>")
                            .arg(locale.toString(n->date, QLocale::ShortFormat));
        else
            news += QString("<li><i>%1 : </i> ").arg(locale.toString(n->date, QLocale::ShortFormat));
        if (n->link.isEmpty())
            news += QString("<b>%1</b>").arg(n->title);
        else
            news += QString("<a href=\"%1\">%2</a>").arg(n->link, n->title);
        if (n->unread)
            news += "</b>";
        if (!n->desc.isEmpty())
            news += "<br/>" + n->desc;
        news += "<br/></li>";
    }
    news += "</ul>";

    return news;
}

void QropNews::onNewsReceived()
{
    auto *reply = static_cast<QNetworkReply *>(sender());
    m_numberOfUnreadNews = 0;
    if (m_defaultLangTried && reply->error() != QNetworkReply::NoError) {
        qDebug() << "[QropNews::onNewsReceived] error #" << reply->error() << " : "
                 << reply->errorString();
        _error(tr("Error fetching news: %1").arg(reply->errorString()));
        reply->deleteLater();
        m_defaultLangTried = false;
        return;
    } else if (reply->error() == QNetworkReply::ContentNotFoundError) {
        qDebug() << "[QropNews::onNewsReceived] Failing fetching news for language " << m_lang
                 << " => trying default one: " << s_defaultLanguage;
        fetchNews(s_defaultLanguage);
        reply->deleteLater();
        m_defaultLangTried = true;
        return;
    }

    QVariant contentType = reply->header(QNetworkRequest::ContentTypeHeader);
    if (!contentType.isValid() || !contentType.toString().startsWith(s_newsJsonContentType)) {
        _error(tr("Error fetching news: invalid contentType from url: %1 : %2")
                       .arg(reply->url().toString(), contentType.toString()));
        reply->deleteLater();
        m_defaultLangTried = false;
        return;
    }

    m_defaultLangTried = false;
    QString jsonTxt = reply->readAll();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonTxt.toUtf8());
    QJsonObject json = jsonDoc.object();
    m_mainText = json["mainText"].toString();
    m_lastRelease = json["lastRelease"].toString();

    if (Qrop::instance()->newReleaseAvailable(m_lastRelease)) {
        m_mainText += QString("<br/><br/><b><a href=\"%1\">%2 : %3</a></b>")
                              .arg(s_qropDownloadURL, tr("New version available"), m_lastRelease);
        ++m_numberOfUnreadNews;
    }

    QJsonArray news = json["news"].toArray();
    qDeleteAll(m_news);
    m_news.clear();
    m_news.reserve(news.count());
    m_lastUpdate = QDate();
    QDate lastNewsUpdate = Qrop::instance()->lastNewsUpdate();
    for (auto it = news.begin(), itEnd = news.end(); it != itEnd; ++it) {
        QJsonObject n = it->toObject();
        QString title;
        QString link;
        QString desc;
        QDate date;
        bool unread = false;

        if (n.contains("date")) {
            date = QDate::fromString(n["date"].toString(), Qt::ISODate);
            if (lastNewsUpdate.isNull() || date > lastNewsUpdate) {
                unread = true;
                ++m_numberOfUnreadNews;
            }
            if (m_lastUpdate.isNull())
                m_lastUpdate = date;
        }
        if (n.contains("title"))
            title = n["title"].toString();
        if (n.contains("link"))
            link = n["link"].toString();
        if (n.contains("desc"))
            desc = n["desc"].toString();

        if (date.isValid() && !title.isEmpty())
            m_news << new News(date, title, link, desc, unread);
        else
            qCritical() << "unexpected News: " << n;
    }

    emit newsReceived();
    reply->deleteLater();
}
