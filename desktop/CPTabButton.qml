import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.1
import QtQuick.Controls.Universal 2.1

TabButton {
    width: implicitWidth
    icon.name: "back"
    display: checked ? AbstractButton.TextBesideIcon : AbstractButton.IconOnly
}
