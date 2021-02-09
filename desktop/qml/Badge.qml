import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.3

Rectangle {
    id: root

    function displayBadge(msg) {
        if (msg.length === 0) {
            visible = false;
        }
        else {
            visible = true;
            badgeLbl.text = msg;
        }
    }

    visible: false
    smooth: true
    color: Material.color(Material.Red, Material.Shade900)
    radius: width / 2
    height: 18
    // Make the rectangle and ellipse if the length of the text is bigger than 2 characters
    width: badgeLbl.text.length > 2 ? badgeLbl.paintedWidth + height / 2 : height

    // Create an animation when the opacity changes
    Behavior on opacity { NumberAnimation { } }

    Label {
        id: badgeLbl
        color: "#fdfdfdfd"
        font.pixelSize: Units.fontSizeCaption
        font.family: "Roboto Condensed"
        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter

        // We need to have the same margins as the badge so that the text
        // appears perfectly centered inside its parent.
        anchors.margins: parent.anchors.margins
    }
}
