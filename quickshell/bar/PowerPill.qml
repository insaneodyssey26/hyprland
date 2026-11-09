import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"
import "../services"

Rectangle {
    id: root
    implicitHeight: 28
    implicitWidth: 32
    radius: 14
    color: (pwrHover.containsMouse || PopupManager.isPopupOpen("power")) ? Qt.rgba(Colors.colError.r, Colors.colError.g, Colors.colError.b, 0.25) : "transparent"

    Behavior on color { ColorAnimation { duration: 150 } }

    Text {
        anchors.centerIn: parent
        text: "󰐥"
        font.family: "Symbols Nerd Font"
        font.pixelSize: 15
        color: pwrHover.containsMouse ? "#ff5555" : Colors.colError
    }

    MouseArea {
        id: pwrHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: PopupManager.openPopup("power")
    }

    // Power Actions Card Popup
    PopupWindow {
        id: pwrPopup
        anchor {
            item: root
            edges: Edges.Bottom
            gravity: Edges.Bottom
            margins.top: 8
        }
        implicitWidth: 220
        implicitHeight: 180
        visible: PopupManager.isPopupOpen("power")
        grabFocus: true
        onVisibleChanged: {
            if (!visible && PopupManager.activePopup === "power") {
                PopupManager.closeAll()
            }
        }
        color: "transparent"

        Item {
            id: pwrAnimContainer
            anchors.fill: parent
            scale: 0.92
            opacity: 0.0

            Rectangle {
                anchors.fill: parent
                radius: 18
                color: Qt.rgba(18/255, 18/255, 20/255, 0.98)
                border.color: Qt.rgba(1, 1, 1, 0.18)
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 8

                    // Lock
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 32; radius: 8
                        color: lockHover.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.06)
                        RowLayout {
                            anchors.centerIn: parent; spacing: 8
                            Text { text: "󰌾"; font.family: "Symbols Nerd Font"; font.pixelSize: 13; color: Colors.colPrimary }
                            Text { text: "Lock Screen"; font.family: "Geist"; font.pixelSize: 12; font.bold: true; color: Colors.colText }
                        }
                        MouseArea {
                            id: lockHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Qt.createQmlObject('import Quickshell.Io; Process { command: ["/home/masum/dotfiles/scripts/lock.sh"]; running: true }', root)
                                PopupManager.closeAll()
                            }
                        }
                    }

                    // Suspend
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 32; radius: 8
                        color: suspHover.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.06)
                        RowLayout {
                            anchors.centerIn: parent; spacing: 8
                            Text { text: "󰤄"; font.family: "Symbols Nerd Font"; font.pixelSize: 13; color: Colors.colPrimary }
                            Text { text: "Suspend"; font.family: "Geist"; font.pixelSize: 12; font.bold: true; color: Colors.colText }
                        }
                        MouseArea {
                            id: suspHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Qt.createQmlObject('import Quickshell.Io; Process { command: ["systemctl", "suspend"]; running: true }', root)
                                PopupManager.closeAll()
                            }
                        }
                    }

                    // Reboot
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 32; radius: 8
                        color: rebootHover.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.06)
                        RowLayout {
                            anchors.centerIn: parent; spacing: 8
                            Text { text: "󰜉"; font.family: "Symbols Nerd Font"; font.pixelSize: 13; color: Colors.colPrimary }
                            Text { text: "Restart"; font.family: "Geist"; font.pixelSize: 12; font.bold: true; color: Colors.colText }
                        }
                        MouseArea {
                            id: rebootHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Qt.createQmlObject('import Quickshell.Io; Process { command: ["systemctl", "reboot"]; running: true }', root)
                                PopupManager.closeAll()
                            }
                        }
                    }

                    // Shutdown
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 32; radius: 8
                        color: shutHover.containsMouse ? Qt.rgba(Colors.colError.r, Colors.colError.g, Colors.colError.b, 0.3) : Qt.rgba(1, 1, 1, 0.06)
                        RowLayout {
                            anchors.centerIn: parent; spacing: 8
                            Text { text: "󰐥"; font.family: "Symbols Nerd Font"; font.pixelSize: 13; color: Colors.colError }
                            Text { text: "Power Off"; font.family: "Geist"; font.pixelSize: 12; font.bold: true; color: Colors.colError }
                        }
                        MouseArea {
                            id: shutHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Qt.createQmlObject('import Quickshell.Io; Process { command: ["systemctl", "poweroff"]; running: true }', root)
                                PopupManager.closeAll()
                            }
                        }
                    }
                }
            }

            states: [
                State {
                    name: "visible"
                    when: pwrPopup.visible
                    PropertyChanges { target: pwrAnimContainer; scale: 1.0; opacity: 1.0 }
                },
                State {
                    name: "hidden"
                    when: !pwrPopup.visible
                    PropertyChanges { target: pwrAnimContainer; scale: 0.92; opacity: 0.0 }
                }
            ]

            transitions: [
                Transition {
                    from: "hidden"; to: "visible"
                    ParallelAnimation {
                        NumberAnimation { property: "scale"; duration: 220; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
                        NumberAnimation { property: "opacity"; duration: 180; easing.type: Easing.OutCubic }
                    }
                },
                Transition {
                    from: "visible"; to: "hidden"
                    ParallelAnimation {
                        NumberAnimation { property: "scale"; duration: 160; easing.type: Easing.InCubic }
                        NumberAnimation { property: "opacity"; duration: 150; easing.type: Easing.InCubic }
                    }
                }
            ]
        }
    }
}
