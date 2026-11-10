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

    function focusInput() {
        inputField.forceActiveFocus()
    }

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
                    font.pixelSize: 10
                    font.bold: true
                    color: TimerService.isFinished ? Colors.colError : Colors.colPrimary
                }
            }
        }

        Rectangle {
            id: heroCard
            Layout.fillWidth: true
            Layout.preferredHeight: TimerService.isActive ? 76 : 0
            visible: TimerService.isActive
            radius: 14
            color: TimerService.isFinished ? Colors.colError : (TimerService.isRunning ? Colors.colPrimary : Qt.rgba(1, 1, 1, 0.12))
            border.color: "transparent"
            border.width: 0
            clip: true

            Behavior on Layout.preferredHeight { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 200 } }

            Item {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 16

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: TimerService.displayTime
                        font.family: "Geist"
                        font.pixelSize: 28
                        font.bold: true
                        color: TimerService.isFinished ? Colors.colOnError : (TimerService.isRunning ? Colors.colOnPrimary : "#ffffff")
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

                RowLayout {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    // Play/Pause button
                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: playHover.containsMouse ? (TimerService.isRunning ? Qt.rgba(0, 0, 0, 0.28) : Qt.rgba(1, 1, 1, 0.25)) : (TimerService.isRunning ? Qt.rgba(0, 0, 0, 0.18) : Qt.rgba(1, 1, 1, 0.12))

                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text: TimerService.isRunning ? "󰏤" : "󰐊"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 14
                            color: TimerService.isFinished ? Colors.colOnError : (TimerService.isRunning ? Colors.colOnPrimary : "#ffffff")
                        }

                        MouseArea {
                            id: playHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: TimerService.togglePause()
                        }
                    }

                    // Reset / Clear button
                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: resetHover.containsMouse ? (TimerService.isRunning ? Qt.rgba(0, 0, 0, 0.28) : Qt.rgba(1, 1, 1, 0.25)) : (TimerService.isRunning ? Qt.rgba(0, 0, 0, 0.18) : Qt.rgba(1, 1, 1, 0.12))

                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text: "󰜉"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 14
                            color: TimerService.isFinished ? Colors.colOnError : (TimerService.isRunning ? Colors.colOnPrimary : "#ffffff")
                        }

                        MouseArea {
                            id: resetHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: TimerService.reset()
                        }
                    }
                }
            }
        }

        // Custom Duration Input Box
        Rectangle {
            id: inputBox
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            radius: 10
            color: Qt.rgba(1, 1, 1, 0.06)
            border.color: inputField.activeFocus ? Colors.colPrimary : Qt.rgba(1, 1, 1, 0.12)
            border.width: 1

            Behavior on border.color { ColorAnimation { duration: 150 } }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.IBeamCursor
                onClicked: inputField.forceActiveFocus()
            }

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
                    selectByMouse: true

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
                color: Colors.colTextMuted
                opacity: 0.6
                Layout.alignment: Qt.AlignVCenter
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(1, 1, 1, 0.08)
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // Preset Grid (2 columns: Stopwatch, 5m, 10m, 15m, 25m Pomodoro, 30m)
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 8
            rowSpacing: 8

            Repeater {
                model: [
                    { label: "Stopwatch", dur: 0, icon: "󱫌", sub: "Count up" },
                    { label: "5 Minutes", dur: 300, icon: "󱎫", sub: "Quick break" },
                    { label: "10 Minutes", dur: 600, icon: "󱎫", sub: "Short session" },
                    { label: "15 Minutes", dur: 900, icon: "󱎫", sub: "Coffee break" },
                    { label: "25 Minutes", dur: 1500, icon: "󱫌", sub: "Pomodoro" },
                    { label: "30 Minutes", dur: 1800, icon: "󱎫", sub: "Deep work" }
                ]

                delegate: Rectangle {
                    id: presetCard
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    radius: 10

                    property bool isThisRunning: (modelData.dur === 0 && TimerService.mode === "stopwatch" && TimerService.isRunning) ||
                                                 (modelData.dur > 0 && TimerService.mode === "timer" && TimerService.durationSec === modelData.dur && TimerService.isRunning)

                    color: isThisRunning ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.16)
                                         : (cardHover.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.04))
                    border.color: isThisRunning ? Colors.colPrimary : "transparent"
                    border.width: isThisRunning ? 1 : 0

                    Behavior on color { ColorAnimation { duration: 140 } }
                    Behavior on border.color { ColorAnimation { duration: 140 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            width: 28; height: 28; radius: 8
                            color: presetCard.isThisRunning ? Colors.colPrimary : (cardHover.containsMouse ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(1, 1, 1, 0.06))

                            Behavior on color { ColorAnimation { duration: 140 } }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 13
                                color: presetCard.isThisRunning ? "#000000" : Colors.colPrimary
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                text: modelData.label
                                font.family: "Geist"
                                font.pixelSize: 12
                                font.bold: true
                                color: presetCard.isThisRunning ? Colors.colPrimary : Colors.colText
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
                        id: cardHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.dur === 0) {
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
