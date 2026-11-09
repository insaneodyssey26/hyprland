import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"
import "../services"

Rectangle {
    id: root
    implicitHeight: 28
    implicitWidth: volRow.implicitWidth + 14
    radius: 14
    color: (volHover.containsMouse || PopupManager.isPopupOpen("volume")) ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

    property real vol: 40.0
    property bool isMuted: false

    // Periodically sync volume directly from Pipewire via wpctl
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: getVolProcess.running = true
    }

    Process {
        id: getVolProcess
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                let str = text.trim()
                root.isMuted = str.includes("[MUTED]")
                let match = str.match(/Volume:\s+([0-9.]+)/)
                if (match && match[1]) {
                    root.vol = Math.round(parseFloat(match[1]) * 100)
                }
            }
        }
    }

    function setVolumePercent(val) {
        let clamped = Math.max(0, Math.min(100, Math.round(val)))
        root.vol = clamped
        root.isMuted = false
        Qt.createQmlObject('import Quickshell.Io; Process { command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "' + (clamped / 100).toFixed(2) + '"]; running: true }', root)
    }

    function toggleMute() {
        root.isMuted = !root.isMuted
        Qt.createQmlObject('import Quickshell.Io; Process { command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]; running: true }', root)
    }

    RowLayout {
        id: volRow
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: root.isMuted ? "󰝟" : (root.vol > 50 ? "󰕾" : (root.vol > 0 ? "󰖀" : "󰕿"))
            font.family: "Symbols Nerd Font"
            font.pixelSize: 13
            color: root.isMuted ? Colors.colError : Colors.colPrimary
        }

        Text {
            text: root.isMuted ? "Muted" : (Math.round(root.vol) + "%")
            font.family: "Geist"
            font.pixelSize: 12
            font.bold: true
            color: Colors.colText
        }
    }

    MouseArea {
        id: volHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: PopupManager.openPopup("volume")
        onWheel: (wheel) => {
            let delta = wheel.angleDelta.y > 0 ? 5 : -5
            root.setVolumePercent(root.vol + delta)
        }
    }

    // Volume & Audio Output Interactive Popup
    PopupWindow {
        id: volPopup
        anchor {
            item: root
            edges: Edges.Bottom
            gravity: Edges.Bottom
            margins.top: 8
        }
        implicitWidth: 260
        implicitHeight: 180
        visible: PopupManager.isPopupOpen("volume")
        grabFocus: true
        onVisibleChanged: {
            if (!visible && PopupManager.activePopup === "volume") {
                PopupManager.closeAll()
            }
        }
        color: "transparent"

        Item {
            id: volAnimContainer
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
                    anchors.margins: 16
                    spacing: 14

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Audio Output"
                            font.family: "Geist"
                            font.pixelSize: 14
                            font.bold: true
                            color: Colors.colText
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.isMuted ? "Muted" : (Math.round(root.vol) + "%")
                            font.family: "Geist"
                            font.pixelSize: 12
                            font.bold: true
                            color: Colors.colPrimary
                        }
                    }

                    // Interactive Drag & Click Volume Slider
                    Rectangle {
                        id: sliderTrack
                        Layout.fillWidth: true
                        Layout.preferredHeight: 22
                        radius: 11
                        color: Qt.rgba(1, 1, 1, 0.1)

                        // Filled bar
                        Rectangle {
                            height: parent.height
                            radius: 11
                            color: root.isMuted ? Colors.colError : Colors.colPrimary
                            width: Math.min(sliderTrack.width, Math.max(0, (root.vol / 100) * sliderTrack.width))
                        }

                        // Knob handle
                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            anchors.verticalCenter: parent.verticalCenter
                            x: Math.max(0, Math.min(sliderTrack.width - 16, (root.vol / 100) * sliderTrack.width - 8))
                            color: "#ffffff"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            preventStealing: true
                            onClicked: (mouse) => {
                                let ratio = mouse.x / sliderTrack.width
                                root.setVolumePercent(ratio * 100)
                            }
                            onPositionChanged: (mouse) => {
                                if (pressed) {
                                    let ratio = Math.max(0, Math.min(1, mouse.x / sliderTrack.width))
                                    root.setVolumePercent(ratio * 100)
                                }
                            }
                        }
                    }

                    // Bottom Row: Mute Toggle & Pavucontrol
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            radius: 8
                            color: muteHover.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08)

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text { text: root.isMuted ? "󰝟" : "󰕾"; font.family: "Symbols Nerd Font"; font.pixelSize: 13; color: Colors.colPrimary }
                                Text { text: root.isMuted ? "Unmute" : "Mute"; font.family: "Geist"; font.pixelSize: 12; font.bold: true; color: Colors.colText }
                            }

                            MouseArea {
                                id: muteHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.toggleMute()
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            radius: 8
                            color: pavuHover.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08)

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text { text: "󰓃"; font.family: "Symbols Nerd Font"; font.pixelSize: 13; color: Colors.colPrimary }
                                Text { text: "Mixer"; font.family: "Geist"; font.pixelSize: 12; font.bold: true; color: Colors.colText }
                            }

                            MouseArea {
                                id: pavuHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    Qt.createQmlObject('import Quickshell.Io; Process { command: ["pavucontrol"]; running: true }', root)
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
                    when: volPopup.visible
                    PropertyChanges { target: volAnimContainer; scale: 1.0; opacity: 1.0 }
                },
                State {
                    name: "hidden"
                    when: !volPopup.visible
                    PropertyChanges { target: volAnimContainer; scale: 0.92; opacity: 0.0 }
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
