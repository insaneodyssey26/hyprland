import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: root
    implicitHeight: 26
    implicitWidth: 32
    radius: 13
    color: kbdHover.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

    Behavior on color { ColorAnimation { duration: 150 } }

    Text {
        anchors.centerIn: parent
        text: "󰌌"
        font.family: "Symbols Nerd Font"
        font.pixelSize: 15
        color: kbdHover.containsMouse ? Colors.colPrimary : Colors.colTextMuted
    }

    MouseArea {
        id: kbdHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            toggleProc.running = true
        }
    }

    Process {
        id: toggleProc
        command: ["/home/masum/dotfiles/quickshell/scripts/toggle-keyboard.sh"]
    }
}
