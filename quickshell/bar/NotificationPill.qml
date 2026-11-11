import QtQuick
import QtQuick.Layouts
import "../theme"
import "../notifications"

Rectangle {
    id: root
    implicitHeight: 26
    implicitWidth: notiRow.implicitWidth + 14
    radius: 13
    color: (notiHover.containsMouse || NotificationManager.drawerOpen) ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

    Behavior on color { ColorAnimation { duration: 150 } }

    RowLayout {
        id: notiRow
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: NotificationManager.dndActive ? "󰂛" : (NotificationManager.count > 0 ? "󱅫" : "󰂚")
            font.family: "Symbols Nerd Font"
            font.pixelSize: 14
            color: NotificationManager.dndActive ? Colors.colError : (NotificationManager.count > 0 ? Colors.colPrimary : Colors.colTextMuted)
        }

        Text {
            text: NotificationManager.count > 0 ? NotificationManager.count.toString() : ""
            font.family: "Geist"
            font.pixelSize: 12
            font.bold: true
            color: Colors.colText
            visible: NotificationManager.count > 0
        }
    }

    MouseArea {
        id: notiHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                NotificationManager.toggleDnd()
            } else {
                NotificationManager.toggleDrawer()
            }
        }
    }
}
