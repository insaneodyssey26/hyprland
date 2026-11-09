import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import "../theme"

Rectangle {
    id: root
    implicitHeight: 28
    implicitWidth: sysRow.implicitWidth + 16
    radius: 14
    color: (sysHover.containsMouse || sysPopup.visible) ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.04)

    Behavior on color { ColorAnimation { duration: 150 } }

    SystemMonitor {
        id: sysMon
    }

    RowLayout {
        id: sysRow
        anchors.centerIn: parent
        spacing: 9

        // CPU
        RowLayout {
            spacing: 4
            Text {
                text: "󰍛"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 13
                color: Colors.colPrimary
            }
            Text {
                text: sysMon.cpuUsage + "%"
                font.family: "Geist"
                font.pixelSize: 12
                font.bold: true
                color: Colors.colText
            }
        }

        // Battery
        RowLayout {
            spacing: 4
            property real pct: UPower.displayDevice ? (UPower.displayDevice.percentage * 100) : 100
            property bool charging: UPower.displayDevice ? (UPower.displayDevice.state === UPowerDeviceState.Charging) : false

            Text {
                text: parent.charging ? "󰂄" : (parent.pct > 80 ? "󰁹" : (parent.pct > 50 ? "󰁾" : (parent.pct > 20 ? "󰁼" : "󰁺")))
                font.family: "Symbols Nerd Font"
                font.pixelSize: 13
                color: parent.pct < 20 ? Colors.colError : Colors.colPrimary
            }

            Text {
                text: Math.round(parent.pct) + "%"
                font.family: "Geist"
                font.pixelSize: 12
                font.bold: true
                color: Colors.colText
            }
        }
    }

    MouseArea {
        id: sysHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: sysPopup.visible = !sysPopup.visible
    }

    // Telemetry Popup details
    PopupWindow {
        id: sysPopup
        anchor {
            item: root
            edges: Edges.Bottom
            gravity: Edges.Bottom
            margins.top: 8
        }
        implicitWidth: 280
        implicitHeight: 250
        visible: false
        grabFocus: true
        color: "transparent"

        Item {
            id: sysAnimContainer
            anchors.fill: parent
            scale: 0.92
            opacity: 0.0

            Rectangle {
                anchors.fill: parent
                radius: 18
                color: Qt.rgba(Colors.colSurface.r, Colors.colSurface.g, Colors.colSurface.b, 0.96)
                border.color: Qt.rgba(1, 1, 1, 0.15)
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "System Telemetry"
                            font.family: "Geist"
                            font.pixelSize: 15
                            font.bold: true
                            color: Colors.colText
                        }
                        Item { Layout.fillWidth: true }
                        // Quick btop launcher
                        Rectangle {
                            width: 26; height: 26; radius: 13
                            color: btopHover.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.06)
                            Text {
                                anchors.centerIn: parent
                                text: "󰓅"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 13
                                color: Colors.colPrimary
                            }
                            MouseArea {
                                id: btopHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    Qt.createQmlObject('import Quickshell.Io; Process { command: ["foot", "-e", "btop"]; running: true }', root)
                                    sysPopup.visible = false
                                }
                            }
                        }
                    }

                    // CPU Metric
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Processor Load"; font.family: "Geist"; font.pixelSize: 12; color: Colors.colTextMuted }
                            Item { Layout.fillWidth: true }
                            Text { text: sysMon.cpuUsage + "%"; font.family: "Geist"; font.pixelSize: 12; font.bold: true; color: Colors.colText }
                        }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 5; radius: 3; color: Qt.rgba(1, 1, 1, 0.1)
                            Rectangle { height: parent.height; radius: 3; color: Colors.colPrimary; width: (sysMon.cpuUsage / 100) * parent.width }
                        }
                    }

                    // RAM Metric
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Memory Active"; font.family: "Geist"; font.pixelSize: 12; color: Colors.colTextMuted }
                            Item { Layout.fillWidth: true }
                            Text { text: sysMon.memStr; font.family: "Geist"; font.pixelSize: 12; font.bold: true; color: Colors.colText }
                        }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 5; radius: 3; color: Qt.rgba(1, 1, 1, 0.1)
                            Rectangle { height: parent.height; radius: 3; color: Colors.colSecondary; width: (sysMon.memUsage / 100) * parent.width }
                        }
                    }

                    // Thermal & Battery State
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 32; radius: 8
                            color: Qt.rgba(1, 1, 1, 0.06)
                            RowLayout {
                                anchors.centerIn: parent; spacing: 6
                                Text { text: "󰔏"; font.family: "Symbols Nerd Font"; font.pixelSize: 13; color: Colors.colPrimary }
                                Text { text: (sysMon.tempC > 0 ? sysMon.tempC + "°C" : "Normal"); font.family: "Geist"; font.pixelSize: 12; font.bold: true; color: Colors.colText }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 32; radius: 8
                            color: Qt.rgba(1, 1, 1, 0.06)
                            RowLayout {
                                anchors.centerIn: parent; spacing: 6
                                Text { text: "󱐋"; font.family: "Symbols Nerd Font"; font.pixelSize: 13; color: Colors.colPrimary }
                                Text {
                                    text: UPower.displayDevice ? (UPower.displayDevice.state === UPowerDeviceState.Charging ? "Charging" : "Discharging") : "AC"
                                    font.family: "Geist"; font.pixelSize: 12; font.bold: true; color: Colors.colText
                                }
                            }
                        }
                    }
                }
            }

            states: [
                State {
                    name: "visible"
                    when: sysPopup.visible
                    PropertyChanges { target: sysAnimContainer; scale: 1.0; opacity: 1.0 }
                },
                State {
                    name: "hidden"
                    when: !sysPopup.visible
                    PropertyChanges { target: sysAnimContainer; scale: 0.92; opacity: 0.0 }
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
