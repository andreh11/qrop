import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.settings 1.0

import io.qrop.components 1.0

// TODO: refactor
ThinDivider {
    width: largeDisplay ? 0 : parent.width
}
