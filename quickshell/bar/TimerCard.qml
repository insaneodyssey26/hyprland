import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../theme"
import "../services"

Rectangle {
    id: root
    implicitWidth: 340
    implicitHeight: mainLayout.implicitHeight + 28
    radius: 16
    color: "#000000"
    border.color: "transparent"
    border.width: 0

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        // Card Header
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            Layout.leftMargin: 4
            Layout.rightMargin: 4
            spacing: 8

            Text {
                text: "󱫌"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 15
                color: Colors.colPrimary
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: "Timer & Stopwatch"
                font.family: "Geist"
                font.pixelSize: 13
                font.bold: true
                color: Colors.colText
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            // Polished Badge with Geist font
            Rectangle {
                visible: TimerService.isActive
                implicitWidth: badgeLabel.implicitWidth + 14
                implicitHeight: 22
                radius: 11
                color: TimerService.isFinished ? Qt.rgba(Colors.colError.r, Colors.colError.g, Colors.colError.b, 0.2) : Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.15)
                border.color: TimerService.isFinished ? Qt.rgba(Colors.colError.r, Colors.colError.g, Colors.colError.b, 0.4) : Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.3)
                border.width: 0

                Text {
                    id: badgeLabel
                    anchors.centerIn: parent
                    text: TimerService.isFinished ? "Finished" : (TimerService.isRunning ? (TimerService.mode === "stopwatch" ? "Stopwatch" : "Active") : "Paused")
                    font.family: "Geist"
                    font.pixelSize: 11
                    font.bold: true
                    color: TimerService.isFinished ? Colors.colError : Colors.colPrimary
                }
            }
        }

        // Active Timer Hero Card (Solid primary accent hero with dynamic contrast text)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: TimerService.isActive ? 76 : 0
            visible: TimerService.isActive
            radius: 12
            color: TimerService.isFinished ? Colors.colError : (TimerService.isRunning ? Colors.colPrimary : Qt.rgba(1, 1, 1, 0.12))
            border.width: 0
            clip: true

            Behavior on Layout.preferredHeight { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 150 } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 0

                    Text {
                        text: TimerService.displayTime
                        font.family: "Literation Mono Ligature"
                        font.pixelSize: 32
                        font.bold: true
                        color: TimerService.isFinished ? Colors.colOnError : (TimerService.isRunning ? Colors.colOnPrimary : "#ffffff")
                        verticalAlignment: Text.AlignVCenter
                        topPadding: 2
                    }

                    Text {
                        text: TimerService.mode === "timer" ? ("Target: " + TimerService.formatDuration(TimerService.durationSec)) : "Elapsed stopwatch time"
                        font.family: "Geist"
                        font.pixelSize: 11
                        font.bold: true
                        color: TimerService.isFinished ? Colors.colOnError : (TimerService.isRunning ? Colors.colOnPrimary : Qt.rgba(1, 1, 1, 0.7))
                        opacity: 0.85
                    }
                }

                // Action Buttons Group (Properly sized and centered)
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 8

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: playHover.containsMouse ? (TimerService.isRunning ? Qt.rgba(0, 0, 0, 0.25) : Qt.rgba(1, 1, 1, 0.25)) : (TimerService.isRunning ? Qt.rgba(0, 0, 0, 0.15) : Qt.rgba(1, 1, 1, 0.12))
                        border.width: 0

                        Text {
                            anchors.centerIn: parent
                            text: TimerService.isRunning ? "󰏤" : "󰐊"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 15
                            color: TimerService.isFinished ? Colors.colOnError : (TimerService.isRunning ? Colors.colOnPrimary : "#ffffff")
                        }
                        MouseArea {
                            id: playHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: TimerService.togglePause()
                        }
                    }

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: resetHover.containsMouse ? (TimerService.isRunning ? Qt.rgba(0, 0, 0, 0.25) : Qt.rgba(1, 1, 1, 0.25)) : (TimerService.isRunning ? Qt.rgba(0, 0, 0, 0.15) : Qt.rgba(1, 1, 1, 0.12))
                        border.width: 0

                        Text {
                            anchors.centerIn: parent
                            text: "󰑐"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 14
                            color: TimerService.isFinished ? Colors.colOnError : (TimerService.isRunning ? Colors.colOnPrimary : "#ffffff")
                        }
                        MouseArea {
                            id: resetHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: TimerService.reset()
                        }
                    }
                }
            }
        }

        // Custom Input Box
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            radius: 10
            color: Qt.rgba(1, 1, 1, 0.06)
            border.color: inputField.activeFocus ? Colors.colPrimary : Qt.rgba(1, 1, 1, 0.12)
            border.width: 0

            Behavior on border.color { ColorAnimation { duration: 150 } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: "󰔛"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 14
                    color: inputField.activeFocus ? Colors.colPrimary : Colors.colTextMuted
                    Layout.alignment: Qt.AlignVCenter
                }

                TextInput {
                    id: inputField
                    Layout.fillWidth: true
                    font.family: "Geist"
                    font.pixelSize: 13
                    color: Colors.colText
                    clip: true

                    Text {
                        anchors.fill: parent
                        visible: !inputField.text && !inputField.inputMethodComposing
                        text: "Custom duration (e.g. 25m, 45s, 10)..."
                        color: Qt.rgba(1, 1, 1, 0.35)
                        font.family: "Geist"
                        font.pixelSize: 12
                        verticalAlignment: Text.AlignVCenter
                    }

                    onAccepted: {
                        if (TimerService.parseAndStart(text)) {
                            text = ""
                            PopupManager.closeAll()
                        }
                    }
                }

                Rectangle {
                    visible: inputField.text.length > 0
                    width: 22; height: 22; radius: 6
                    color: submitHover.containsMouse ? Colors.colPrimary : Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.2)

                    Text {
                        anchors.centerIn: parent
                        text: "↵"
                        font.family: "Geist"
                        font.pixelSize: 12
                        font.bold: true
                        color: submitHover.containsMouse ? "#000000" : Colors.colPrimary
                    }

                    MouseArea {
                        id: submitHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (TimerService.parseAndStart(inputField.text)) {
                                inputField.text = ""
                                PopupManager.closeAll()
                            }
                        }
                    }
                }
            }
        }

        // Section Divider
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 2
            Layout.bottomMargin: 2
            spacing: 8

            Text {
                text: "PRESETS"
                font.family: "Geist"
                font.pixelSize: 10
                font.bold: true
                color: Qt.rgba(1, 1, 1, 0.4)
                font.letterSpacing: 0.8
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(1, 1, 1, 0.08)
            }
        }

        // Presets Grid (Comfortable cards with icons and Geist typography)
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 8
            columnSpacing: 8

            readonly property var presets: [
                { title: "25 min", sub: "Pomodoro Focus", dur: 1500, icon: "󰔛" },
                { title: "5 min", sub: "Quick Rest", dur: 300, icon: "󱎫" },
                { title: "15 min", sub: "Short Break", dur: 900, icon: "󱎫" },
                { title: "45 min", sub: "Deep Work", dur: 2700, icon: "󰔛" },
                { title: "1 hour", sub: "Extended", dur: 3600, icon: "󰥔" },
                { title: "Stopwatch", sub: "Count Up", dur: 0, icon: "󰥔", isStopwatch: true }
            ]

            Repeater {
                model: parent.presets

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    radius: 10
                    color: btnHover.containsMouse ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.12) : Qt.rgba(1, 1, 1, 0.04)
                    border.color: btnHover.containsMouse ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.3) : Qt.rgba(1, 1, 1, 0.08)
                    border.width: 0

                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Text {
                            text: modelData.icon
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 15
                            color: btnHover.containsMouse ? Colors.colPrimary : Colors.colTextMuted
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: modelData.title
                                font.family: "Geist"
                                font.pixelSize: 12
                                font.bold: true
                                color: btnHover.containsMouse ? "#ffffff" : Colors.colText
                            }

                            Text {
                                text: modelData.sub
                                font.family: "Geist"
                                font.pixelSize: 10
                                color: Colors.colTextMuted
                            }
                        }
                    }

                    MouseArea {
                        id: btnHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.isStopwatch) {
                                TimerService.startStopwatch()
                            } else {
                                TimerService.startTimer(modelData.dur)
                            }
                            PopupManager.closeAll()
                        }
                    }
                }
            }
        }
    }
}
