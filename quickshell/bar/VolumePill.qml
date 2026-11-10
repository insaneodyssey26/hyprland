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

    Process {
        id: setVolProc
    }

    Process {
        id: setMuteProc
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
    }

    Process {
        id: setSinkProc
    }

    Process {
        id: pavuProc
        command: ["pavucontrol"]
    }

    function setVolumePercent(val) {
        let clamped = Math.max(0, Math.min(100, Math.round(val)))
        root.vol = clamped
        root.isMuted = false
        setVolProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (clamped / 100).toFixed(2)]
        setVolProc.running = true
    }

    function toggleMute() {
        root.isMuted = !root.isMuted
        setMuteProc.running = true
    }

    function setSink(sinkId) {
        setSinkProc.command = ["wpctl", "set-default", "" + sinkId]
        setSinkProc.running = true
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
            font.pixelSize: 14
            color: root.isMuted ? Colors.colError : Colors.colPrimary
        }

        Text {
            text: root.isMuted ? "Muted" : (Math.round(root.vol) + "%")
            font.family: "Geist"
            font.pixelSize: 13
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
        implicitWidth: 340
        implicitHeight: mainCol.implicitHeight + 28
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
            scale: 0.94
            opacity: 0.0

            Rectangle {
                anchors.fill: parent
                radius: 16
                color: "#000000"
                border.color: "transparent"
                border.width: 0

                ColumnLayout {
                    id: mainCol
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
                            text: root.isMuted ? "󰝟" : "󰕾"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 16
                            color: Colors.colPrimary
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            text: "Audio Output"
                            font.family: "Geist"
                            font.pixelSize: 14
                            font.bold: true
                            color: Colors.colText
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: root.isMuted ? "Muted" : (Math.round(root.vol) + "%")
                            font.family: "Geist"
                            font.pixelSize: 12
                            font.bold: true
                            color: root.isMuted ? Colors.colError : Colors.colPrimary
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    // Interactive Volume Slider
                    Rectangle {
                        id: sliderTrack
                        Layout.fillWidth: true
                        Layout.preferredHeight: 22
                        radius: 11
                        color: Qt.rgba(1, 1, 1, 0.08)

                        Rectangle {
                            height: parent.height
                            radius: 11
                            color: root.isMuted ? Colors.colError : Colors.colPrimary
                            width: Math.min(sliderTrack.width, Math.max(0, (root.vol / 100) * sliderTrack.width))
                        }

                        Rectangle {
                            width: 14
                            height: 14
                            radius: 7
                            anchors.verticalCenter: parent.verticalCenter
                            x: Math.max(0, Math.min(sliderTrack.width - 14, (root.vol / 100) * sliderTrack.width - 7))
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

                    // Section Divider
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 2
                        Layout.bottomMargin: 2
                        spacing: 8

                        Text {
                            text: "OUTPUT DEVICES"
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

                        Text {
                            text: root.audioSinks.length + " connected"
                            font.family: "Geist"
                            font.pixelSize: 10
                            color: Qt.rgba(1, 1, 1, 0.35)
                        }
                    }

                    // Devices ListView
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: root.audioSinks

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                radius: 10
                                color: modelData.active ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.12) : (sinkHover.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.03))
                                border.color: modelData.active ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.35) : Qt.rgba(1, 1, 1, 0.06)
                                border.width: 0

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
                                            text: modelData.name
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
                    }

                    // Section Divider
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Qt.rgba(1, 1, 1, 0.08)
                    }

                    // Actions Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            radius: 8
                            color: muteHover.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.05)
                            border.color: "transparent"; border.width: 0

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 8
                                Text { text: root.isMuted ? "󰝟" : "󰕾"; font.family: "Symbols Nerd Font"; font.pixelSize: 13; color: Colors.colPrimary }
                                Text { text: root.isMuted ? "Unmute" : "Mute"; font.family: "Geist"; font.pixelSize: 12; font.bold: true; color: Colors.colText }
                            }

                            MouseArea {
                                id: muteHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: root.toggleMute()
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            radius: 8
                            color: pavuHover.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.05)
                            border.color: "transparent"; border.width: 0

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 8
                                Text { text: "󰓃"; font.family: "Symbols Nerd Font"; font.pixelSize: 13; color: Colors.colPrimary }
                                Text { text: "Mixer"; font.family: "Geist"; font.pixelSize: 12; font.bold: true; color: Colors.colText }
                            }

                            MouseArea {
                                id: pavuHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    pavuProc.running = true
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
                    PropertyChanges { target: volAnimContainer; scale: 0.94; opacity: 0.0 }
                }
            ]

            transitions: [
                Transition {
                    from: "hidden"; to: "visible"
                    ParallelAnimation {
                        NumberAnimation { property: "scale"; duration: 160; easing.type: Easing.OutQuint }
                        NumberAnimation { property: "opacity"; duration: 140; easing.type: Easing.OutCubic }
                    }
                },
                Transition {
                    from: "visible"; to: "hidden"
                    ParallelAnimation {
                        NumberAnimation { property: "scale"; duration: 120; easing.type: Easing.InCubic }
                        NumberAnimation { property: "opacity"; duration: 100; easing.type: Easing.InCubic }
                    }
                }
            ]
        }
    }
}
