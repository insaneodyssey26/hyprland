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
    property real brightnessVal: 50.0

    Timer {
        interval: 1200
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            getVolProcess.running = true
            getBrightProcess.running = true
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
        id: getBrightProcess
        command: ["bash", "-c", "brightnessctl -m | cut -d, -f4 | tr -d '%'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let b = parseInt(text.trim(), 10)
                if (!isNaN(b)) root.brightnessVal = b
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
        id: setBrightProc
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

    function setBrightnessPercent(val) {
        let clamped = Math.max(1, Math.min(100, Math.round(val)))
        root.brightnessVal = clamped
        setBrightProc.command = ["brightnessctl", "set", clamped + "%"]
        setBrightProc.running = true
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
            getBrightProcess.running = true
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
                getBrightProcess.running = true
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

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 26
                        Layout.leftMargin: 4
                        Layout.rightMargin: 4
                        spacing: 8

                        Text {
                            text: root.isMuted ? "󰝟" : "󰕾"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 15
                            color: Colors.colPrimary
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            text: "Volume"
                            font.family: "Geist"
                            font.pixelSize: 13
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

                    Rectangle {
                        id: sliderTrack
                        Layout.fillWidth: true
                        Layout.preferredHeight: 18
                        radius: 9
                        color: Qt.rgba(1, 1, 1, 0.08)

                        Rectangle {
                            height: parent.height
                            radius: 9
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

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 26
                        Layout.leftMargin: 4
                        Layout.rightMargin: 4
                        spacing: 8

                        Text {
                            text: root.brightnessVal > 60 ? "󰃠" : (root.brightnessVal > 30 ? "󰃟" : "󰃞")
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 15
                            color: Colors.colPrimary
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            text: "Brightness"
                            font.family: "Geist"
                            font.pixelSize: 13
                            font.bold: true
                            color: Colors.colText
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: Math.round(root.brightnessVal) + "%"
                            font.family: "Geist"
                            font.pixelSize: 12
                            font.bold: true
                            color: Colors.colPrimary
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    Rectangle {
                        id: brightTrack
                        Layout.fillWidth: true
                        Layout.preferredHeight: 18
                        radius: 9
                        color: Qt.rgba(1, 1, 1, 0.08)

                        Rectangle {
                            height: parent.height
                            radius: 9
                            color: Colors.colPrimary
                            width: Math.min(brightTrack.width, Math.max(0, (root.brightnessVal / 100) * brightTrack.width))
                        }

                        Rectangle {
                            width: 14
                            height: 14
                            radius: 7
                            anchors.verticalCenter: parent.verticalCenter
                            x: Math.max(0, Math.min(brightTrack.width - 14, (root.brightnessVal / 100) * brightTrack.width - 7))
                            color: "#ffffff"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            preventStealing: true
                            onClicked: (mouse) => {
                                let ratio = Math.max(0.01, Math.min(1, mouse.x / brightTrack.width))
                                root.setBrightnessPercent(ratio * 100)
                            }
                            onPositionChanged: (mouse) => {
                                if (pressed) {
                                    let ratio = Math.max(0.01, Math.min(1, mouse.x / brightTrack.width))
                                    root.setBrightnessPercent(ratio * 100)
                                }
                            }
                        }
                    }

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

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Repeater {
                            model: root.audioSinks

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 38
                                radius: 8
                                color: modelData.is_default ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.16)
                                                            : (sinkHover.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.04))
                                border.color: modelData.is_default ? Colors.colPrimary : "transparent"
                                border.width: modelData.is_default ? 1 : 0

                                Behavior on color { ColorAnimation { duration: 150 } }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 10

                                    Text {
                                        text: modelData.is_default ? "󰓃" : "󰕾"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 14
                                        color: modelData.is_default ? Colors.colPrimary : Colors.colTextMuted
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.name
                                        font.family: "Geist"
                                        font.pixelSize: 12
                                        font.bold: modelData.is_default
                                        color: modelData.is_default ? Colors.colPrimary : Colors.colText
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        visible: modelData.is_default
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

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Qt.rgba(1, 1, 1, 0.08)
                    }

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
