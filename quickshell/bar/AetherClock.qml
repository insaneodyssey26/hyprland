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
        interval: 200
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
        color: (mouseArea.containsMouse || PopupManager.isPopupOpen("calendar")) ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: "󰅐"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 13
            color: Colors.colPrimary
            Layout.alignment: Qt.AlignVCenter
        }

        RowLayout {
            spacing: 2
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: root.timeStr
                font.family: "Geist"
                font.pixelSize: 13
                font.bold: true
                color: Colors.colText
                Layout.alignment: Qt.AlignBaseline
            }

            Text {
                text: root.secStr
                font.family: "Geist"
                font.pixelSize: 10
                font.bold: true
                color: Colors.colPrimary
                opacity: 0.85
                Layout.alignment: Qt.AlignBaseline
            }
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 11
            color: Qt.rgba(1, 1, 1, 0.16)
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: root.dateStr
            font.family: "Geist"
            font.pixelSize: 12
            font.bold: true
            color: Colors.colText
            Layout.alignment: Qt.AlignVCenter
        }

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
                font.pixelSize: 13
                color: Colors.colPrimary
            }

            Text {
                text: WeatherService.temp
                font.family: "Geist"
                font.pixelSize: 12
                font.bold: true
                color: Colors.colText
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: PopupManager.openPopup("calendar")
    }

    // Native Calendar Popup
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

            AetherCalendar {
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
}
