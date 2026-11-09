import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"
import "../services"

Rectangle {
    id: root
    implicitHeight: 28
    // Stable fixed width avoids layout jitter on speed changes
    implicitWidth: 72
    radius: 14
    color: (wifiHover.containsMouse || PopupManager.isPopupOpen("wifi")) ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

    Behavior on color { ColorAnimation { duration: 150 } }

    Process {
        id: nmtuiProc
        command: ["kitty", "-e", "nmtui"]
    }

    Process {
        id: wifiToggleProc
    }

    NetworkService {
        id: net
    }

    RowLayout {
        id: wifiRow
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Text {
            Layout.preferredWidth: 16
            horizontalAlignment: Text.AlignHCenter
            text: {
                if (!net.isConnected) return "󰤮"
                if (net.signalStrength > 75) return "󰤨"
                if (net.signalStrength > 50) return "󰤥"
                if (net.signalStrength > 25) return "󰤢"
                return "󰤟"
            }
            font.family: "Symbols Nerd Font"
            font.pixelSize: 13
            color: net.isConnected ? Colors.colPrimary : Colors.colError
        }

        // Live Internet Speed Display (replacing SSID text)
        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignLeft
            text: net.speedStr
            font.family: "Geist"
            font.pixelSize: 12
            font.bold: true
            color: Colors.colText
        }
    }

    MouseArea {
        id: wifiHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: PopupManager.openPopup("wifi")
    }

    // WiFi Control Popup
    PopupWindow {
        id: wifiPopup
        anchor {
            item: root
            edges: Edges.Bottom
            gravity: Edges.Bottom
            margins.top: 8
        }
        implicitWidth: 260
        implicitHeight: 210
        visible: PopupManager.isPopupOpen("wifi")
        grabFocus: true
        onVisibleChanged: {
            if (!visible && PopupManager.activePopup === "wifi") {
                PopupManager.closeAll()
            }
        }
        color: "transparent"

        Item {
            id: wifiAnimContainer
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

                    // Title & Active status
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Wireless Network"
                            font.family: "Geist"
                            font.pixelSize: 14
                            font.bold: true
                            color: Colors.colText
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: net.isConnected ? (net.signalStrength + "%") : "Off"
                            font.family: "Geist"
                            font.pixelSize: 12
                            color: Colors.colPrimary
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        radius: 10
                        color: Qt.rgba(1, 1, 1, 0.06)

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8
                            Text {
                                text: net.isConnected ? "󰤨" : "󰤮"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 15
                                color: Colors.colPrimary
                            }
                            Text {
                                text: net.activeSsid
                                font.family: "Geist"
                                font.pixelSize: 13
                                font.bold: true
                                color: Colors.colText
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }
                    }

                    // Quick Actions
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        // Open nmtui in foot
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            radius: 8
                            color: nmtuiHover.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08)

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 8
                                Text { text: "󰄬"; font.family: "Symbols Nerd Font"; font.pixelSize: 12; color: Colors.colPrimary }
                                Text { text: "Manage Connections (nmtui)"; font.family: "Geist"; font.pixelSize: 12; font.bold: true; color: Colors.colText }
                            }

                            MouseArea {
                                id: nmtuiHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    nmtuiProc.running = true
                                    PopupManager.closeAll()
                                }
                            }
                        }

                        // Toggle Radio (nmcli radio wifi)
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            radius: 8
                            color: radioHover.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08)

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 8
                                Text { text: "󰖪"; font.family: "Symbols Nerd Font"; font.pixelSize: 12; color: Colors.colPrimary }
                                Text { text: "Toggle Wi-Fi Power"; font.family: "Geist"; font.pixelSize: 12; font.bold: true; color: Colors.colText }
                            }

                            MouseArea {
                                id: radioHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    wifiToggleProc.command = ["nmcli", "radio", "wifi", (net.isConnected ? "off" : "on")]
                                    wifiToggleProc.running = true
                                    PopupManager.closeAll()
                                }
                            }
                        }
                    }
                }
            }

            states: [
                State {
                    name: "visible"
                    when: wifiPopup.visible
                    PropertyChanges { target: wifiAnimContainer; scale: 1.0; opacity: 1.0 }
                },
                State {
                    name: "hidden"
                    when: !wifiPopup.visible
                    PropertyChanges { target: wifiAnimContainer; scale: 0.92; opacity: 0.0 }
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
