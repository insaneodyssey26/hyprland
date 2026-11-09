import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import "../theme"

RowLayout {
    id: root
    spacing: 12
    Layout.rightMargin: 4

    // Volume
    RowLayout {
        spacing: 4
        property real vol: Pipewire.defaultAudioSink ? (Pipewire.defaultAudioSink.audio.volume * 100) : 0
        property bool isMuted: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio.muted : false

        Text {
            text: parent.isMuted ? "󰝟" : (parent.vol > 50 ? "󰕾" : (parent.vol > 0 ? "󰖀" : "󰕿"))
            font.family: "Symbols Nerd Font"
            font.pixelSize: 12
            color: parent.isMuted ? Colors.colError : Colors.colTextMuted
        }

        Text {
            text: Math.round(parent.vol) + "%"
            font.family: "Geist"
            font.pixelSize: 11
            font.bold: true
            color: Colors.colText
        }
    }

    // Battery
    RowLayout {
        spacing: 4
        property var displayDevice: UPower.displayDevice
        property real batteryLevel: displayDevice ? displayDevice.percentage * 100 : 100
        property bool isCharging: displayDevice ? (displayDevice.state === UPowerDeviceState.Charging || displayDevice.state === UPowerDeviceState.FullyCharged) : false

        Text {
            text: parent.isCharging ? "󱐋" : (parent.batteryLevel > 80 ? "" : (parent.batteryLevel > 40 ? "" : ""))
            font.family: "Symbols Nerd Font"
            font.pixelSize: 12
            color: parent.isCharging ? Colors.colPrimary : (parent.batteryLevel < 20 ? Colors.colError : Colors.colTextMuted)
        }

        Text {
            text: Math.round(parent.batteryLevel) + "%"
            font.family: "Geist"
            font.pixelSize: 11
            font.bold: true
            color: Colors.colText
        }
    }

    // Power Trigger
    Text {
        text: ""
        font.family: "Symbols Nerd Font"
        font.pixelSize: 12
        color: Colors.colError
        opacity: 0.8

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                Qt.createQmlObject('import Quickshell.Io; Process { command: ["/home/masum/dotfiles/scripts/power.sh"]; running: true }', root)
            }
        }
    }
}
