import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtQml.Models 2.10
import Qt.labs.settings 1.0

import io.croplan.components 1.0
import "date.js" as MDate

ColumnLayout {
    id: control

    property int plantingId
    property int year

//    property int length: Number(plantingAmountField.text)
    property int dtt: NDate.daysTo(greenhouseStartDateField.calendarDate,
                                   plantingDateField.calendarDate)
    property int dtm: NDate.daysTo(plantingDateField.calendarDate,
                                   begHarvestDateField.calendarDate)
    property int harvestWindow: NDate.daysTo(begHarvestDateField.calendarDate,
                                             endHarvestDateField.calendarDate)

    property int plantingType: Planting.type(plantingId)
    property bool coherentDates: (plantingType !== 2 || dtt >= 0) && dtm >= 0 && harvestWindow >= 0
    property bool accepted: coherentDates

    signal plantingModified()

    function updatePlanting() {
        var map = {"planting_date": plantingDateField.isoDateString,
                   "dtm": dtm,
                   "harvest_window": harvestWindow };

        if (plantingType === 2)
            map["dtt"] = dtt

        Planting.update(plantingId, map)
        plantingModified();
    }

    spacing: 0
    implicitWidth: 150

    RowLayout {
        ToolButton {
            id: backButton
            text: "\ue5c4" // arrow_back
            font.family: "Material Icons"
            font.pixelSize: Units.fontSizeHeadline
            onClicked: conflictStackView.pop();
        }

        Label {
            text: Planting.cropName(plantingId)
            font.family: "Roboto Regular"
            font.pixelSize: Units.fontSizeBodyAndButton
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        ToolButton {
            id: confirmButton
            text: "\ue876"
            enabled: control.accepted
            font.family: "Material Icons"
            font.pixelSize: Units.fontSizeHeadline
            onClicked: {
                updatePlanting();
                conflictStackView.pop();
            }
        }
    }

    ThinDivider { Layout.fillWidth: true }

//    MyTextField {
//        id: plantingAmountField
//        text:
//        labelText: qsTr("Length")
//        suffixText: qsTr("bed m")
//        floatingLabel: true
//        inputMethodHints: Qt.ImhDigitsOnly
//        validator: IntValidator { bottom: 0; top: 999 }
//        Layout.fillWidth: true
//        Layout.topMargin: Units.formSpacing
//        Layout.leftMargin: Units.formSpacing
//        Layout.rightMargin: Layout.leftMargin
//        onActiveFocusChanged: ensureVisible(activeFocus, y, height)
//    }

    DatePicker {
        id: greenhouseStartDateField

        visible: plantingType === 2
        Layout.fillWidth: true
        Layout.topMargin: Units.formSpacing
        Layout.leftMargin: Units.formSpacing
        Layout.rightMargin: Layout.leftMargin
        floatingLabel: true
        labelText: qsTr("Greenhouse start date")
        currentYear: control.year
        calendarDate: Planting.sowingDate(plantingId);
    }

    DatePicker {
        id: plantingDateField

        visible: plantingType !== 3
        Layout.fillWidth: true
        Layout.topMargin: Units.formSpacing
        Layout.leftMargin: Units.formSpacing
        Layout.rightMargin: Layout.leftMargin
        floatingLabel: true
        labelText: plantingType === 1 ? qsTr("Field sowing") : qsTr("Field planting")
        currentYear: control.year
        calendarDate: Planting.plantingDate(plantingId)
    }

    DatePicker {
        id: begHarvestDateField

        Layout.fillWidth: true
        Layout.topMargin: Units.formSpacing
        Layout.leftMargin: Units.formSpacing
        Layout.rightMargin: Layout.leftMargin
        floatingLabel: true
        labelText: qsTr("First harvest")
        currentYear: control.year
        calendarDate: Planting.begHarvestDate(plantingId)
    }

    DatePicker {
        id: endHarvestDateField

        Layout.fillWidth: true
        Layout.topMargin: Units.formSpacing
        Layout.leftMargin: Units.formSpacing
        Layout.rightMargin: Layout.leftMargin
        floatingLabel: true
        labelText: qsTr("Last harvest")
        currentYear: control.year
        calendarDate: Planting.endHarvestDate(plantingId)
    }
}
