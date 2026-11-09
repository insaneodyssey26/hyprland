import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    implicitHeight: 28
    implicitWidth: row.implicitWidth + 20
    radius: 14
    color: Qt.rgba(Colors.colSurface.r, Colors.colSurface.g, Colors.colSurface.b, 0.72)
    border.color: Qt.rgba(1, 1, 1, 0.08)
    border.width: 1

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: "󰣇"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 14
            color: Colors.colPrimary

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Qt.createQmlObject('import Quickshell.Io; Process { command: ["fuzzel"]; running: true }', root)
                }
            }
        }

        Text {
            text: "masum@Arch"
            font.family: "Literation Mono Ligature"
            font.pixelSize: 12
            font.bold: true
            color: Colors.colText
        }
    }
}
