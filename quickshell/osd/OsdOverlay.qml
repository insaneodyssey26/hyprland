import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../theme"

PanelWindow {
    id: root

    property bool isShown: false
    property string iconText: "󰕾"
    property real value: 0.5
    property string labelText: "Volume"
    property string valueText: "50%"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "aether-osd"
    exclusionMode: ExclusionMode.Ignore

    anchors {
        bottom: true
    }
    margins.bottom: 60

    implicitWidth: 260
    implicitHeight: 64

    color: "transparent"
    visible: root.isShown || osdPill.opacity > 0.0

    Timer {
        id: hideTimer
        interval: 1600
        repeat: false
        onTriggered: root.isShown = false
    }

    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                let txt = text.trim()
                let isMuted = txt.includes("[MUTED]")
                let match = txt.match(/Volume:\s+([0-9\.]+)/)
                let vol = match ? parseFloat(match[1]) : 0.0
                root.value = Math.min(1.0, Math.max(0.0, vol))
                root.labelText = isMuted ? "Volume (Muted)" : "Volume"
                root.iconText = isMuted ? "󰝟" : (vol > 0.6 ? "󰕾" : (vol > 0.2 ? "󰖀" : "󰕿"))
                root.valueText = isMuted ? "0%" : Math.round(root.value * 100) + "%"
                root.show()
            }
        }
    }

    Process {
        id: brightProc
        command: ["bash", "-c", "brightnessctl -m | cut -d, -f4 | tr -d '%'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let b = parseInt(text.trim(), 10) || 0
                root.value = Math.min(1.0, Math.max(0.0, b / 100.0))
                root.labelText = "Brightness"
                root.iconText = b > 60 ? "󰃠" : (b > 30 ? "󰃟" : "󰃞")
                root.valueText = b + "%"
                root.show()
            }
        }
    }

    Process {
        id: micProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]
        stdout: StdioCollector {
            onStreamFinished: {
                let txt = text.trim()
                let isMuted = txt.includes("[MUTED]")
                let match = txt.match(/Volume:\s+([0-9\.]+)/)
                let vol = match ? parseFloat(match[1]) : 0.0
                root.value = isMuted ? 0.0 : Math.min(1.0, Math.max(0.0, vol))
                root.labelText = isMuted ? "Microphone (Muted)" : "Microphone"
                root.iconText = isMuted ? "󰍭" : "󰍬"
                root.valueText = isMuted ? "Muted" : Math.round(vol * 100) + "%"
                root.show()
            }
        }
    }

    function showVolume() {
        volProc.running = true
    }

    function showBrightness() {
        brightProc.running = true
    }

    function showMic() {
        micProc.running = true
    }

    function show() {
        root.isShown = true
        hideTimer.restart()
    }

    Rectangle {
        id: osdPill
        anchors.fill: parent
        radius: 18
        color: "#000000"
        border.color: "transparent"
        border.width: 0

        scale: root.isShown ? 1.0 : 0.90
        opacity: root.isShown ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation { duration: 180; easing.type: Easing.OutQuint }
        }
        Behavior on opacity {
            NumberAnimation { duration: 160 }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            Text {
                text: root.iconText
                font.family: "Symbols Nerd Font"
                font.pixelSize: 20
                color: Colors.colPrimary
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                Layout.alignment: Qt.AlignVCenter

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: root.labelText
                        font.family: "Geist"
                        font.pixelSize: 12
                        font.bold: true
                        color: Colors.colText
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.valueText
                        font.family: "Geist"
                        font.pixelSize: 11
                        font.bold: true
                        color: Colors.colTextMuted
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 6
                    radius: 3
                    color: Qt.rgba(1, 1, 1, 0.10)

                    Rectangle {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        width: parent.width * root.value
                        radius: 3
                        color: Colors.colPrimary

                        Behavior on width {
                            NumberAnimation { duration: 120; easing.type: Easing.OutQuint }
                        }
                    }
                }
            }
        }
    }
}
