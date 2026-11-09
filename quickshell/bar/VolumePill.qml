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
    property var audioSinks: []

    Timer {
        interval: 1200
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            getVolProcess.running = true
            if (PopupManager.isPopupOpen("volume")) {
                getSinksProcess.running = true
            }
        }
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

    Process {
        id: getSinksProcess
        command: ["/home/masum/dotfiles/scripts/audio-sinks.py"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let parsed = JSON.parse(text.trim())
                    if (Array.isArray(parsed)) {
                        root.audioSinks = parsed
                    }
                } catch(e) {}
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

    function setSink(sinkId) {
        Qt.createQmlObject('import Quickshell.Io; Process { command: ["wpctl", "set-default", "' + sinkId + '"]; running: true }', root)
        Qt.createQmlObject('import Quickshell.Io; Process { command: ["/home/masum/dotfiles/scripts/osd.sh", "volume"]; running: true }', root)
        getSinksProcess.running = true
        getVolProcess.running = true
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
        onClicked: {
            getSinksProcess.running = true
            PopupManager.openPopup("volume")
        }
        onWheel: (wheel) => {
            let delta = wheel.angleDelta.y > 0 ? 5 : -5
            root.setVolumePercent(root.vol + delta)
        }
    }

    PopupWindow {
        id: volPopup
        anchor {
            item: root
            edges: Edges.Bottom
            gravity: Edges.Bottom
            margins.top: 8
        }
        implicitWidth: 360
        implicitHeight: Math.min(480, 210 + Math.max(1, root.audioSinks.length) * 56)
        visible: PopupManager.isPopupOpen("volume")
        grabFocus: true
        onVisibleChanged: {
            if (!visible && PopupManager.activePopup === "volume") {
                PopupManager.closeAll()
            } else if (visible) {
                getSinksProcess.running = true
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
                    anchors.margins: 18
                    spacing: 14

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Audio Output"
                            font.family: "Geist"
                            font.pixelSize: 15
                            font.bold: true
                            color: Colors.colText
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.isMuted ? "Muted" : (Math.round(root.vol) + "%")
                            font.family: "Geist"
                            font.pixelSize: 13
                            font.bold: true
                            color: Colors.colPrimary
                        }
                    }

                    // Slider Track
                    Rectangle {
                        id: sliderTrack
                        Layout.fillWidth: true
                        Layout.preferredHeight: 24
                        radius: 12
                        color: Qt.rgba(1, 1, 1, 0.1)

                        Rectangle {
                            height: parent.height
                            radius: 12
                            color: root.isMuted ? Colors.colError : Colors.colPrimary
                            width: Math.min(sliderTrack.width, Math.max(0, (root.vol / 100) * sliderTrack.width))
                        }

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
                                let ratio = Math.max(0, Math.min(1, mouse.x / sliderTrack.width))
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

                    // Audio Devices List Header
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        Text {
                            text: "OUTPUT DEVICES"
                            font.family: "Geist"
                            font.pixelSize: 11
                            font.bold: true
                            color: Qt.rgba(1, 1, 1, 0.45)
                            font.letterSpacing: 0.8
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.audioSinks.length + " connected"
                            font.family: "Geist"
                            font.pixelSize: 11
                            color: Qt.rgba(1, 1, 1, 0.35)
                        }
                    }

                    // Devices ListView
                    ListView {
                        id: sinksList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 6
                        model: root.audioSinks

                        delegate: Rectangle {
                            id: sinkItem
                            width: sinksList.width
                            height: 48
                            radius: 10
                            color: modelData.active ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.12) : (sinkHover.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.03))
                            border.color: modelData.active ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.35) : Qt.rgba(1, 1, 1, 0.06)
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 12

                                Rectangle {
                                    width: 32
                                    height: 32
                                    radius: 16
                                    color: modelData.active ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.2) : Qt.rgba(1, 1, 1, 0.06)
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.icon || "󰕾"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 15
                                        color: modelData.active ? Colors.colPrimary : Colors.colTextMuted
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: modelData.displayName || modelData.name
                                        font.family: "Geist"
                                        font.pixelSize: 13
                                        font.bold: modelData.active
                                        color: modelData.active ? "#ffffff" : Colors.colText
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: modelData.active ? "Active Output" : "Available"
                                        font.family: "Geist"
                                        font.pixelSize: 10
                                        color: modelData.active ? Colors.colPrimary : Qt.rgba(1, 1, 1, 0.4)
                                    }
                                }

                                Text {
                                    visible: modelData.active
                                    text: ""
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 13
                                    color: Colors.colPrimary
                                }
                            }

                            MouseArea {
                                id: sinkHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.setSink(modelData.id)
                            }
                        }
                    }

                    // Quick Actions
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            radius: 10
                            color: muteHover.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08)

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 7
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
                            Layout.preferredHeight: 36
                            radius: 10
                            color: pavuHover.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08)

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 7
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
