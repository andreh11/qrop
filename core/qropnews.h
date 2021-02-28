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

#ifndef QROPNEWS_H
#define QROPNEWS_H

#include "core_global.h"

#include <QObject>
#include <QString>
#include <QVector>
#include <QDate>

class CORESHARED_EXPORT QropNews : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString mainText READ mainText CONSTANT FINAL)
    Q_PROPERTY(QString toHtml READ toHtml CONSTANT FINAL)

    static constexpr const char *s_newsJsonBaseLink =
            "https://framagit.org/ah/qrop/-/raw/master/news/qrop_news"; //!< we add "_<lang>.json"
    static constexpr const char *s_newsJsonContentType = "text/plain";
    static constexpr const char *s_qropDownloadURL = "https://qrop.frama.io/fr/download/";

    static constexpr const char *s_defaultLanguage = "en";

    typedef struct News {
        const QDate date;
        const QString title;
        const QString link;
        const QString desc;
        const bool unread;
        News(const QDate &date_, const QString &title_, const QString &link_, const QString &desc_,
             bool unread_)
            : date(date_)
            , title(title_)
            , link(link_)
            , desc(desc_)
            , unread(unread_)
        {
        }
    } News;

public:
    QropNews(QObject *parent = nullptr);
    ~QropNews() override;

    inline QDate lastUpdate() const { return m_lastUpdate; }
    inline QString lastRelease() const { return m_lastRelease; }

    inline QString mainText() const { return m_mainText; }
    QString toHtml();

    Q_INVOKABLE void fetchNews();
    inline Q_INVOKABLE int numberOfUnreadNews() const { return m_numberOfUnreadNews; }

    inline Q_INVOKABLE void markAsRead(bool read) { m_markAsRead = read; }
    inline bool areRead() const { return m_markAsRead; }

signals:
    void newsReceived();

private slots:
    void onNewsReceived();

private:
    void _error(const QString &err);
    void fetchNews(const QString &lang);

private:
    QString m_lang;
    QDate m_lastUpdate;
    QString m_mainText;
    QString m_lastRelease;
    QVector<News *> m_news;
    ushort m_numberOfUnreadNews;
    bool m_markAsRead;
    bool m_defaultLangTried;
};

#endif // QROPNEWS_H
