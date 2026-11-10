import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"
import "../services"

Item {
    id: root
    implicitHeight: 28
    implicitWidth: content.implicitWidth + 14

    property string timeStr: ""
    property string secStr: ""
    property string dateStr: ""

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            let now = new Date()
            root.timeStr = Qt.formatDateTime(now, "hh:mm")
            root.secStr = Qt.formatDateTime(now, "ss")
            root.dateStr = Qt.formatDateTime(now, "ddd, MMM d")
        }
    }

    Rectangle {
        id: bgPill
        anchors.fill: parent
        radius: 14
        color: (clockHover.containsMouse || dateHover.containsMouse || timerActiveHover.containsMouse || PopupManager.isPopupOpen("calendar") || PopupManager.isPopupOpen("timer")) ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 8

        // CLOCK SECTION (Click opens Timer & Stopwatch)
        Item {
            id: clockSection
            Layout.alignment: Qt.AlignVCenter
            implicitHeight: 22
            implicitWidth: clockInnerRow.implicitWidth

            RowLayout {
                id: clockInnerRow
                anchors.centerIn: parent
                spacing: 5

                Text {
                    text: "󰅐"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 14
                    color: PopupManager.isPopupOpen("timer") ? Colors.colPrimary : Colors.colTextMuted
                    Layout.alignment: Qt.AlignVCenter
                }

                RowLayout {
                    spacing: 2
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: root.timeStr
                        font.family: "Geist"
                        font.pixelSize: 14
                        font.bold: true
                        color: Colors.colText
                        Layout.alignment: Qt.AlignBaseline
                    }

                    Text {
                        text: root.secStr
                        font.family: "Geist"
                        font.pixelSize: 11
                        font.bold: true
                        color: Colors.colPrimary
                        opacity: 0.85
                        Layout.alignment: Qt.AlignBaseline
                    }
                }
            }

            MouseArea {
                id: clockHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: PopupManager.openPopup("timer")
            }
        }

        // DYNAMIC ACTIVE TIMER / STOPWATCH PILL (Appears after clock when running)
        Rectangle {
            id: activeTimerPill
            Layout.alignment: Qt.AlignVCenter
            visible: TimerService.isActive
            implicitHeight: 24
            implicitWidth: (TimerService.displayTime.length > 5 ? 82 : 62)
            radius: 12
            color: TimerService.isFinished ? Colors.colError : (TimerService.isRunning ? Colors.colPrimary : Qt.rgba(1, 1, 1, 0.16))
            border.width: 0

            Behavior on implicitWidth { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 1
                text: TimerService.displayTime
                font.family: "Literation Mono Ligature"
                font.pixelSize: 13
                font.bold: true
                color: TimerService.isFinished ? Colors.colOnError : (TimerService.isRunning ? Colors.colOnPrimary : "#ffffff")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: timerActiveHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        TimerService.reset()
                    } else {
                        TimerService.togglePause()
                    }
                }
                onWheel: (wheel) => {
                    let delta = wheel.angleDelta.y > 0 ? 60 : -60
                    TimerService.adjustTime(delta)
                }
            }
        }

        // Divider
        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 11
            color: Qt.rgba(1, 1, 1, 0.16)
            Layout.alignment: Qt.AlignVCenter
        }

        // DATE SECTION (Click opens Calendar)
        Item {
            id: dateSection
            Layout.alignment: Qt.AlignVCenter
            implicitHeight: 22
            implicitWidth: dateLabel.implicitWidth

            Text {
                id: dateLabel
                anchors.centerIn: parent
                text: root.dateStr
                font.family: "Geist"
                font.pixelSize: 13
                font.bold: true
                color: PopupManager.isPopupOpen("calendar") ? Colors.colPrimary : Colors.colText
            }

            MouseArea {
                id: dateHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: PopupManager.openPopup("calendar")
            }
        }

        // WEATHER SECTION
        Rectangle {
            visible: WeatherService.isLoaded
            Layout.preferredWidth: 1
            Layout.preferredHeight: 11
            color: Qt.rgba(1, 1, 1, 0.16)
            Layout.alignment: Qt.AlignVCenter
        }

        RowLayout {
            visible: WeatherService.isLoaded
            spacing: 5
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: WeatherService.icon
                font.family: "Symbols Nerd Font"
                font.pixelSize: 14
                color: Colors.colPrimary
            }

            Text {
                text: WeatherService.temp
                font.family: "Geist"
                font.pixelSize: 13
                font.bold: true
                color: Colors.colText
            }
        }
    }

    // Native Calendar Popup (Triggered by Date)
    PopupWindow {
        id: calPopup
        anchor {
            item: root
            edges: Edges.Bottom
            gravity: Edges.Bottom
            margins.top: 8
        }
        implicitWidth: 320
        implicitHeight: 330
        visible: PopupManager.isPopupOpen("calendar")
        grabFocus: true
        onVisibleChanged: {
            if (!visible && PopupManager.activePopup === "calendar") {
                PopupManager.closeAll()
            }
        }
        color: "transparent"

        Item {
            id: animContainer
            anchors.fill: parent
            scale: 0.92
            opacity: 0.0

            Calendar {
                anchors.fill: parent
            }

            states: [
                State {
                    name: "visible"
                    when: calPopup.visible
                    PropertyChanges { target: animContainer; scale: 1.0; opacity: 1.0 }
                },
                State {
                    name: "hidden"
                    when: !calPopup.visible
                    PropertyChanges { target: animContainer; scale: 0.92; opacity: 0.0 }
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

    // Native Timer & Stopwatch Popup (Triggered by Clock)
    PopupWindow {
        id: timerPopup
        anchor {
            item: root
            edges: Edges.Bottom
            gravity: Edges.Bottom
            margins.top: 8
        }
        implicitWidth: 340
        implicitHeight: TimerService.isActive ? 420 : 340
        visible: PopupManager.isPopupOpen("timer")
        grabFocus: true
        onVisibleChanged: {
            if (!visible && PopupManager.activePopup === "timer") {
                PopupManager.closeAll()
            }
        }
        color: "transparent"

        Behavior on implicitHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        Item {
            id: timerAnimContainer
            anchors.fill: parent
            scale: 0.92
            opacity: 0.0

            TimerCard {
                anchors.fill: parent
            }

            states: [
                State {
                    name: "visible"
                    when: timerPopup.visible
                    PropertyChanges { target: timerAnimContainer; scale: 1.0; opacity: 1.0 }
                },
                State {
                    name: "hidden"
                    when: !timerPopup.visible
                    PropertyChanges { target: timerAnimContainer; scale: 0.92; opacity: 0.0 }
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
