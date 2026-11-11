import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"
import "../services"

Rectangle {
    id: root
    implicitHeight: 26
    implicitWidth: tempRow.implicitWidth + 14
    radius: 13
    color: (tempHover.containsMouse || PopupManager.isPopupOpen("cpu")) ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

    Behavior on color { ColorAnimation { duration: 150 } }

    Process {
        id: btopProc
        command: ["kitty", "-e", "btop"]
    }

    Process {
        id: wlCopyProc
    }

    SystemMonitor {
        id: sysMon
    }

    RowLayout {
        id: tempRow
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: "󰔏"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 13
            color: sysMon.tempC >= 75 ? Colors.colError : Colors.colPrimary
        }

        Text {
            text: (sysMon.tempC > 0 ? sysMon.tempC + "°C" : "48°C")
            font.family: "Geist"
            font.pixelSize: 12
            font.bold: true
            color: Colors.colText
        }
    }

    MouseArea {
        id: tempHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: PopupManager.openPopup("cpu")
    }

    // Telemetry Popup with Comprehensive System Metrics
    PopupWindow {
        id: sysPopup
        anchor {
            item: root
            edges: Edges.Bottom
            gravity: Edges.Bottom
            margins.top: 8
        }
        implicitWidth: 320
        implicitHeight: 410
        visible: PopupManager.isPopupOpen("cpu")
        grabFocus: true
        onVisibleChanged: {
            if (!visible && PopupManager.activePopup === "cpu") {
                PopupManager.closeAll()
            }
        }
        color: "transparent"

        Item {
            id: sysAnimContainer
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
                    anchors.margins: 18
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            spacing: 1
                            Text {
                                text: "System Telemetry"
                                font.family: "Geist"
                                font.pixelSize: 15
                                font.bold: true
                                color: Colors.colText
                            }
                            Text {
                                text: sysMon.cpuModel + " (" + sysMon.coreCount + " threads)"
                                font.family: "Geist"
                                font.pixelSize: 11
                                color: Colors.colTextMuted
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Btop launcher
                        Rectangle {
                            width: 28; height: 28; radius: 13
                            color: btopHover.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08)
                            Text {
                                anchors.centerIn: parent
                                text: "󰓅"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 14
                                color: Colors.colPrimary
                            }
                            MouseArea {
                                id: btopHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    btopProc.running = true
                                    PopupManager.closeAll()
                                }
                            }
                        }
                    }

                    // CPU
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Processor Usage"; font.family: "Geist"; font.pixelSize: 12; color: Colors.colTextMuted }
                            Item { Layout.fillWidth: true }
                            Text { text: sysMon.cpuUsage + "%"; font.family: "Geist"; font.pixelSize: 12; font.bold: true; color: Colors.colText }
                        }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 6; radius: 3; color: Qt.rgba(1, 1, 1, 0.1)
                            Rectangle { height: parent.height; radius: 3; color: Colors.colPrimary; width: (sysMon.cpuUsage / 100) * parent.width }
                        }
                    }

                    // Memory
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
                            Layout.fillWidth: true; Layout.preferredHeight: 6; radius: 3; color: Qt.rgba(1, 1, 1, 0.1)
                            Rectangle { height: parent.height; radius: 3; color: Colors.colSecondary; width: (sysMon.memUsage / 100) * parent.width }
                        }
                    }

                    // GPU
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        RowLayout {
                            Layout.fillWidth: true
                            RowLayout {
                                spacing: 4
                                Text { text: "󰢮"; font.family: "Symbols Nerd Font"; font.pixelSize: 12; color: Colors.colPrimary }
                                Text { text: sysMon.gpuName; font.family: "Geist"; font.pixelSize: 12; color: Colors.colTextMuted }
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: (sysMon.gpuUsage > 0 ? sysMon.gpuUsage + "%" : "0%") + " · " + (sysMon.gpuTemp > 0 ? sysMon.gpuTemp + "°C" : "Idle")
                                font.family: "Geist"
                                font.pixelSize: 12
                                font.bold: true
                                color: Colors.colText
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 6; radius: 3; color: Qt.rgba(1, 1, 1, 0.1)
                            Rectangle { height: parent.height; radius: 3; color: Colors.colPrimary; width: (sysMon.gpuUsage / 100) * parent.width }
                        }
                    }

                    // Storage
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Disk NVMe (/)"; font.family: "Geist"; font.pixelSize: 12; color: Colors.colTextMuted }
                            Item { Layout.fillWidth: true }
                            Text { text: sysMon.diskDetailStr + " (" + sysMon.diskUsageStr + ")"; font.family: "Geist"; font.pixelSize: 12; font.bold: true; color: Colors.colText }
                        }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 6; radius: 3; color: Qt.rgba(1, 1, 1, 0.1)
                            Rectangle { height: parent.height; radius: 3; color: Colors.colOutline; width: (sysMon.diskUsagePct / 100) * parent.width }
                        }
                    }

                    // Fan & IP Address
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            radius: 8
                            color: Qt.rgba(1, 1, 1, 0.08)

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text { text: "󰈐"; font.family: "Symbols Nerd Font"; font.pixelSize: 13; color: Colors.colPrimary }
                                Text {
                                    text: "Fan: " + (sysMon.fanRpm > 0 ? sysMon.fanRpm + " RPM" : "Quiet")
                                    font.family: "Geist"
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: Colors.colText
                                }
                            }
                        }

                        Rectangle {
                            id: ipPill
                            property bool copied: false
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            radius: 8
                            color: ipHover.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.08)

                            Behavior on color { ColorAnimation { duration: 150 } }

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text {
                                    text: ipPill.copied ? "󰄬" : "󰩟"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 13
                                    color: ipPill.copied ? "#50fa7b" : Colors.colPrimary
                                }
                                Text {
                                    text: ipPill.copied ? "Copied!" : sysMon.localIp
                                    font.family: "Geist"
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: ipPill.copied ? "#50fa7b" : Colors.colText
                                }
                            }

                            MouseArea {
                                id: ipHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    wlCopyProc.command = ["wl-copy", "" + sysMon.localIp]
                                    wlCopyProc.running = true
                                    ipPill.copied = true
                                    copyTimer.restart()
                                }
                            }

                            Timer {
                                id: copyTimer
                                interval: 1800
                                onTriggered: ipPill.copied = false
                            }
                        }
                    }

                    // System Uptime
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        radius: 8
                        color: Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: "󰥔"; font.family: "Symbols Nerd Font"; font.pixelSize: 13; color: Colors.colPrimary }
                            Text {
                                text: sysMon.uptimeStr
                                font.family: "Geist"
                                font.pixelSize: 11
                                font.bold: true
                                color: Colors.colText
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
