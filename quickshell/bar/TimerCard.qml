import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../theme"
import "../services"

Rectangle {
    id: root
    implicitWidth: 340
    implicitHeight: 380
    radius: 18
    color: Qt.rgba(Colors.colSurface.r, Colors.colSurface.g, Colors.colSurface.b, 0.96)
    border.color: Qt.rgba(1, 1, 1, 0.16)
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 14

        // Top Header
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Timer & Stopwatch"
                font.family: "Geist"
                font.pixelSize: 15
                font.bold: true
                color: Colors.colText
            }

            Item { Layout.fillWidth: true }

            // Status Badge
            Rectangle {
                visible: TimerService.isActive
                implicitWidth: statusText.implicitWidth + 14
                implicitHeight: 22
                radius: 11
                color: TimerService.isFinished ? Qt.rgba(Colors.colError.r, Colors.colError.g, Colors.colError.b, 0.2) : (TimerService.isRunning ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.15) : Qt.rgba(1, 1, 1, 0.08))

                Text {
                    id: statusText
                    anchors.centerIn: parent
                    text: TimerService.isFinished ? "FINISHED" : (TimerService.isRunning ? (TimerService.mode === "stopwatch" ? "STOPWATCH" : "COUNTDOWN") : "PAUSED")
                    font.family: "Geist"
                    font.pixelSize: 10
                    font.bold: true
                    color: TimerService.isFinished ? Colors.colError : Colors.colPrimary
                }
            }
        }

        // Active Display Banner (When Running or Paused)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: TimerService.isActive ? 84 : 0
            visible: TimerService.isActive
            radius: 14
            color: Qt.rgba(1, 1, 1, 0.04)
            border.color: TimerService.isFinished ? Colors.colError : (TimerService.isRunning ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.3) : Qt.rgba(1, 1, 1, 0.1))
            clip: true

            Behavior on Layout.preferredHeight { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                Text {
                    text: TimerService.isFinished ? "󰔛" : (TimerService.mode === "stopwatch" ? "󰥔" : (TimerService.isRunning ? "󱎫" : "󰏤"))
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 28
                    color: TimerService.isFinished ? Colors.colError : Colors.colPrimary
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: TimerService.displayTime
                        font.family: "Literation Mono Ligature"
                        font.pixelSize: 28
                        font.bold: true
                        color: TimerService.isFinished ? Colors.colError : Colors.colText
                    }

                    Text {
                        text: TimerService.mode === "timer" ? ("Initial: " + TimerService.formatDuration(TimerService.durationSec)) : "Elapsed duration"
                        font.family: "Geist"
                        font.pixelSize: 11
                        color: Colors.colTextMuted
                    }
                }

                // Controls: Pause / Play & Reset
                RowLayout {
                    spacing: 6

                    Rectangle {
                        width: 32; height: 32; radius: 16
                        color: btnPlayHover.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.08)
                        Text {
                            anchors.centerIn: parent
                            text: TimerService.isRunning ? "󰏤" : "󰐊"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 13
                            color: Colors.colPrimary
                        }
                        MouseArea {
                            id: btnPlayHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: TimerService.togglePause()
                        }
                    }

                    Rectangle {
                        width: 32; height: 32; radius: 16
                        color: btnResetHover.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.08)
                        Text {
                            anchors.centerIn: parent
                            text: "󰑐"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 13
                            color: Colors.colError
                        }
                        MouseArea {
                            id: btnResetHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
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
            border.color: customField.activeFocus ? Colors.colPrimary : Qt.rgba(1, 1, 1, 0.12)
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: "󱫌"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 14
                    color: Colors.colPrimary
                }

                TextInput {
                    id: customField
                    Layout.fillWidth: true
                    font.family: "Geist"
                    font.pixelSize: 13
                    color: Colors.colText
                    clip: true

                    Text {
                        anchors.fill: parent
                        visible: !customField.text && !customField.inputMethodComposing
                        text: "Custom time (e.g. 25m, 45s, 1h 30m)..."
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
                    width: 24; height: 24; radius: 6
                    visible: customField.text.length > 0
                    color: startHover.containsMouse ? Colors.colPrimary : Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.2)

                    Text {
                        anchors.centerIn: parent
                        text: "󰌑"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 11
                        color: startHover.containsMouse ? "#000000" : Colors.colPrimary
                    }

                    MouseArea {
                        id: startHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (TimerService.parseAndStart(customField.text)) {
                                customField.text = ""
                                PopupManager.closeAll()
                            }
                        }
                    }
                }
            }
        }

        // Section Label
        Text {
            text: "PRESETS"
            font.family: "Geist"
            font.pixelSize: 10
            font.bold: true
            color: Qt.rgba(1, 1, 1, 0.45)
            font.letterSpacing: 0.8
        }

        // Presets Grid
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 8
            columnSpacing: 8

            readonly property var presets: [
                { title: "Pomodoro", dur: 1500, label: "25 min focus", icon: "󰔛" },
                { title: "Short Break", dur: 300, label: "5 min rest", icon: "󱎫" },
                { title: "Long Break", dur: 900, label: "15 min rest", icon: "󱎫" },
                { title: "Deep Work", dur: 2700, label: "45 min focus", icon: "󰔛" },
                { title: "1 Hour", dur: 3600, label: "60 min timer", icon: "󰥔" },
                { title: "Stopwatch", dur: 0, label: "Count up", icon: "󰥔", isStopwatch: true }
            ]

            Repeater {
                model: parent.presets

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    radius: 10
                    color: itemHover.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.04)
                    border.color: itemHover.containsMouse ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(1, 1, 1, 0.08)
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Text {
                            text: modelData.icon
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 16
                            color: Colors.colPrimary
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: modelData.title
                                font.family: "Geist"
                                font.pixelSize: 12
                                font.bold: true
                                color: Colors.colText
                            }

                            Text {
                                text: modelData.label
                                font.family: "Geist"
                                font.pixelSize: 10
                                color: Colors.colTextMuted
                            }
                        }
                    }

                    MouseArea {
                        id: itemHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
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
