import QtQuick 2.12
import QtQuick.Controls 2.12

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

    // Create an animation when the opacity changes
    Behavior on opacity {NumberAnimation{}}

    // Setup the anchors so that the badge appears on the bottom right
    // area of its parent
    anchors.right: parent.right
    anchors.top: parent.top

    color: "#ec3e3a"  // redish color (exactly the one used in OS X 10.10)

    // Make the rectangle a circle
    radius: width / 2

    // Setup height of the rectangle (the default is 18 pixels)
    height: 22

    // Make the rectangle and ellipse if the length of the text is bigger than 2 characters
    width: badgeLbl.text.length > 2 ? badgeLbl.paintedWidth + height / 2 : height


    // Create a label that will display the number of connected users.
    Label {
        id: badgeLbl
        color: "#fdfdfdfd"
        font.pixelSize: 9
        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter

        // We need to have the same margins as the badge so that the text
        // appears perfectly centered inside its parent.
        anchors.margins: parent.anchors.margins
    }
}
