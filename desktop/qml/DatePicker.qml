/****************************************************************************
**
** Copyright (C) 2014 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4

Item {
    property alias calendar: calendar

    implicitWidth: 80
    implicitHeight: textField.height
    anchors.leftMargin: 16

        TextField {
            id: textField
            width: parent.width
            text: Qt.formatDate(calendar.selectedDate, "dd/MM/yyyy")
            inputMask: "99/99/9999"
            Layout.fillWidth: true
            anchors.verticalCenter: parent.verticalCenter
            onEditingFinished: {
                var newDate = new Date();
                newDate.setDate(text.substr(0, 2));
                newDate.setMonth(text.substr(3, 2) - 1);
                newDate.setFullYear(text.substr(6, 4));
                calendar.selectedDate = newDate;
            }
            style: TextFieldStyle {
                padding.left: button.width + 16
            }

        }

        Label {
            id: button
            font.family: "Font Awesome 5 Free"
            text: "\uf133"
//            source: "qrc:/icon-calendar.png"
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -1
            anchors.left: parent.left
            anchors.leftMargin: 8

            MouseArea {
                anchors.fill: parent
                onClicked: calendar.visible = true
            }
        }

    Rectangle {
        id: focusShade
        parent: window.contentItem
        anchors.fill: parent
        opacity: calendar.visible ? 0.5 : 0
        color: "black"

        Behavior on opacity {
            NumberAnimation {
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: parent.opacity > 0
            onClicked: calendar.visible = false
        }
    }

    Calendar {
        id: calendar
        parent: window.contentItem
        visible: false
        z: focusShade.z + 1
        width: parent.width * 0.8
        height: width
        anchors.centerIn: parent
        weekNumbersVisible: true

        focus: visible
        onClicked: visible = false
        Keys.onBackPressed: {
            event.accepted = true;
            visible = false;
        }


//        style: TouchCalendarStyle {
//        }
    }
}
