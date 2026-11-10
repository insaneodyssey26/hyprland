import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "../theme"
import "../services"

Rectangle {
    id: root
    implicitHeight: 28
    implicitWidth: batRow.implicitWidth + 14
    radius: 14
    color: (batHover.containsMouse || PopupManager.isPopupOpen("battery")) ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

    Behavior on color { ColorAnimation { duration: 150 } }

    Process {
        id: rogProc
        command: ["rog-control-center"]
    }

    property real pct: UPower.displayDevice ? (UPower.displayDevice.percentage * 100) : 100
    property bool charging: UPower.displayDevice ? (UPower.displayDevice.state === UPowerDeviceState.Charging) : false

    function getBatteryIcon(pct, isCharging) {
        if (isCharging) {
            if (pct >= 95) return "󰂅"
            if (pct >= 80) return "󰂋"
            if (pct >= 60) return "󰂊"
            if (pct >= 40) return "󰂉"
            if (pct >= 20) return "󰂇"
            return "󰢜"
        } else {
            if (pct >= 95) return "󰁹"
            if (pct >= 85) return "󰂂"
            if (pct >= 75) return "󰂁"
            if (pct >= 65) return "󰂀"
            if (pct >= 55) return "󰁿"
            if (pct >= 45) return "󰁾"
            if (pct >= 35) return "󰁽"
            if (pct >= 25) return "󰁼"
            if (pct >= 15) return "󰁻"
            return "󰁺"
        }
    }

    RowLayout {
        id: batRow
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: root.getBatteryIcon(root.pct, root.charging)
            font.family: "Symbols Nerd Font"
            font.pixelSize: 14
            color: root.pct < 20 ? Colors.colError : (root.charging ? Colors.colPrimary : (root.pct >= 80 ? Colors.colPrimary : Colors.colText))
        }

        Text {
            text: Math.round(root.pct) + "%"
            font.family: "Geist"
            font.pixelSize: 13
            font.bold: true
            color: Colors.colText
        }
    }

    MouseArea {
        id: batHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: PopupManager.openPopup("battery")
    }

    // Battery & Power Profile Popup
    PopupWindow {
        id: batPopup
        anchor {
            item: root
            edges: Edges.Bottom
            gravity: Edges.Bottom
            margins.top: 8
        }
        implicitWidth: 260
        implicitHeight: 180
        visible: PopupManager.isPopupOpen("battery")
        grabFocus: true
        onVisibleChanged: {
            if (!visible && PopupManager.activePopup === "battery") {
                PopupManager.closeAll()
            }
        }
        color: "transparent"

        Item {
            id: batAnimContainer
            anchors.fill: parent
            scale: 0.92
            opacity: 0.0

            Rectangle {
                anchors.fill: parent
                radius: 18
                color: "#000000"
                border.color: "transparent"
                border.width: 0

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Battery Status"
                            font.family: "Geist"
                            font.pixelSize: 14
                            font.bold: true
                            color: Colors.colText
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: Math.round(root.pct) + "%"
                            font.family: "Geist"
                            font.pixelSize: 13
                            font.bold: true
                            color: Colors.colPrimary
                        }
                    }

                    // Battery bar
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 12
                        radius: 6
                        color: Qt.rgba(1, 1, 1, 0.1)

                        Rectangle {
                            height: parent.height
                            radius: 6
                            color: root.pct < 20 ? Colors.colError : Colors.colPrimary
                            width: (root.pct / 100) * parent.width
                        }
                    }

                    // Health and Charging state
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        radius: 8
                        color: Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            Text {
                                text: root.charging ? "󱐋" : "󰁹"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 15
                                color: Colors.colPrimary
                            }
                            Text {
                                text: root.charging ? "Charging AC connected" : "Discharging on battery"
                                font.family: "Geist"
                                font.pixelSize: 12
                                font.bold: true
                                color: Colors.colText
                            }
                        }
                    }

                    // Asus ROG Control / Power quick toggle
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        radius: 8
                        color: rogHover.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: "󰌢"; font.family: "Symbols Nerd Font"; font.pixelSize: 13; color: Colors.colPrimary }
                            Text { text: "ROG Control Center"; font.family: "Geist"; font.pixelSize: 12; font.bold: true; color: Colors.colText }
                        }

                        MouseArea {
                            id: rogHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                rogProc.running = true
                                PopupManager.closeAll()
                            }
                        }
                    }
                }
            }

            states: [
                State {
                    name: "visible"
                    when: batPopup.visible
                    PropertyChanges { target: batAnimContainer; scale: 1.0; opacity: 1.0 }
                },
                State {
                    name: "hidden"
                    when: !batPopup.visible
                    PropertyChanges { target: batAnimContainer; scale: 0.92; opacity: 0.0 }
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
