/*
 * Copyright (C) 2018−2021 André Hoarau <ah@ouvaton.org>
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

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as Platform
import QtQuick.Window 2.12

import io.qrop.components 1.0

Popup {
    id: root

    property alias newsBadge: newsBadge

    modal: true
    focus: true
    width: 340

    contentHeight: aboutColumn.height + bar.height + 2*Units.mediumSpacing

    function setNews(subTitle, newsHtml, numberOfUnreadNews) {
        newsSubTitle.text = subTitle;
        news.text = newsHtml;

        if (numberOfUnreadNews === 0) {
            flickableNews.height = aboutColumn.height - newsTitle.height - newsTitle.height + Units.mediumSpacing / 2
            markNewsAsRead.visible = false;
        }
        else {
            flickableNews.height = aboutColumn.height - newsTitle.height - newsSubTitle.height
                    - markNewsAsRead.height + Units.mediumSpacing / 2
            markNewsAsRead.visible = true;
        }

        newsRefresh.visible = newsHtml.length === 0;
    }

    SwipeView {
        id: view
        currentIndex: bar.currentIndex
        anchors.fill: parent
        clip: true

        Pane {
            Column {
                id: aboutColumn
                spacing: Units.mediumSpacing
                width: root.availableWidth -  2 * Units.smallSpacing

                Image {
                    id: image
                    source: "/icon.png"
                    width: 100
                    height: width
                    fillMode: Image.PreserveAspectFit
                    anchors.horizontalCenter:  parent.horizontalCenter
                }

                Label {
                    width: parent.width
                    text: "Qrop"
                    font.family: "Roboto Regular"
                    font.pixelSize:  Units.fontSizeHeadline
                    wrapMode: Label.Wrap
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    id: versionLbl
                    width: parent.width
                    text: "v%1".arg(cppQrop.buildInfo().version)
                    font.family: "Roboto Regular"
                    wrapMode: Label.Wrap
                    font.pixelSize:  Units.fontSizeBodyAndButton
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    width: parent.width
                    text: qsTr("A cross-platform tool for crop planning and recordkeeping. Made by farmers, for farmers with the help of the French coop <a href='https://latelierpaysan.org'>L'Atelier paysan</a>.")
                    font.family: "Roboto Regular"
                    wrapMode: Label.Wrap
                    font.pixelSize: Units.fontSizeBodyAndButton
                    onLinkActivated: Qt.openUrlExternally(link)
                    horizontalAlignment: Text.AlignHCenter
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }
                }


                Label {
                    width: parent.width
                    text: "Copyright © 2018−2021, André Hoarau"
                    font.family: "Roboto Regular"
                    wrapMode: Label.Wrap
                    font.pixelSize: Units.fontSizeCaption
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    width: parent.width
                    text: qsTr("This program comes with ABSOLUTELY NO WARRANTY,<br/>for more details, visit <a href='https://www.gnu.org/licenses/gpl-3.0.html'>GNU General Public License version 3</a>.")
                    font.family: "Roboto Regular"
                    wrapMode: Label.Wrap
                    font.pixelSize: Units.fontSizeCaption
                    horizontalAlignment: Text.AlignHCenter
                    onLinkActivated: Qt.openUrlExternally(link)
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }
                }

            }
        }
        Pane {
            Column {
                spacing: 0
                width: root.availableWidth -  2 * Units.smallSpacing

                Item {
                    width: parent.width
                    height: newsTitle.height
                    Label {
                        id: newsTitle
                        text: "<h1>%1</h1>".arg(qsTr("News"));
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
                Label {
                    id: newsSubTitle
                    width: parent.width
                    text: qsTr("you need an internet connection")
                    font.family: "Roboto Regular"
                    wrapMode: Label.Wrap
                    font.pixelSize: Units.fontSizeBodyAndButton
                    horizontalAlignment: Text.AlignHCenter
                    onLinkActivated: Qt.openUrlExternally(link)
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }
                }
                Item {
                    width: 1 // dummy value != 0
                    height: Units.mediumSpacing
                }
                MyToolButton {
                    id: newsRefresh
                    text: qsTr("ReTry fetching News")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: cppQrop.news().fetchNews()
                }
                ScrollView {
                    id: flickableNews
                    clip: true
                    width: view.width
                    height: aboutColumn.height - newsTitle.height -newsSubTitle.height - markNewsAsRead.height + parent.spacing / 2
                    contentHeight: news.height
                    contentWidth: view.width
                    Label {
                        id: news
                        width: parent.width
                        //                    text: qsTr("you need an internet connection");
                        font.family: "Roboto Regular"
                        wrapMode: Label.Wrap
                        font.pixelSize: Units.fontSizeBodyAndButton
                        horizontalAlignment: Text.AlignLeft
                        onLinkActivated: Qt.openUrlExternally(link)
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                            cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }
                }
                CheckBox {
                    id: markNewsAsRead
                    text: qsTr("Mark news as read")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onToggled: cppQrop.news().markAsRead(checked);
                }
            }
        }
        Pane {
            Label {
                id: feedback
                width: parent.width
                text: "<center><h1>%1</h1></center>".arg(qsTr("Feedback Page"))
                font.family: "Roboto Regular"
                wrapMode: Label.Wrap
                font.pixelSize: Units.fontSizeCaption
                horizontalAlignment: Text.AlignHCenter
                onLinkActivated: Qt.openUrlExternally(link)
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }
        }
        Pane {
            TextArea {
                width: parent.width
                height: parent.height
                text: ("Version: %1\n"
                       + "Commit: %2\n"
                       + "Branch: %3\n"
                       + "Mobile device: %4\n"
                       + "Documents folder: %5\n")
                .arg(cppQrop.buildInfo().version)
                .arg(cppQrop.buildInfo().commit)
                .arg(cppQrop.buildInfo().branch)
                .arg(cppQrop.buildInfo().isMobileDevice() ? "true" : "false")
                .arg(FileSystem.rootPath)
                selectByMouse: true
                selectByKeyboard: true
                readOnly: true
            }
        }
    }

    TabBar {
        id: bar
        width: parent.width
        anchors.bottom: view.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        currentIndex: view.currentIndex
        TabButton {
            text: qsTr("Credits")
        }
        TabButton {
            id: newsTab
            text: qsTr("News")

            Badge {
                id: newsBadge
                anchors {
                    top: parent.top
                    topMargin: 2
                    left: parent.left
                    leftMargin: (parent.width + newsTab.contentItem.implicitWidth) / 2 - 5
                }
                z: 1
            }
        }
        TabButton {
            text: qsTr("Feedback")
        }
        TabButton {
            text: qsTr("Debug information")
        }
    }

}
