import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: root
    implicitHeight: 26
    implicitWidth: 28
    radius: 13
    color: kbdHover.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

    Behavior on color { ColorAnimation { duration: 150 } }

    property string layoutCode: "US"

    Process {
        id: layoutQueryProc
        command: ["niri", "msg", "--json", "keyboard-layouts"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let data = JSON.parse(text)
                    if (data && data.names && data.names.length > 0) {
                        let name = data.names[data.current_idx || 0] || "English (US)"
                        if (name.includes("US")) root.layoutCode = "US"
                        else if (name.includes("IN")) root.layoutCode = "IN"
                        else if (name.includes("Bengali") || name.includes("Bangla")) root.layoutCode = "BN"
                        else root.layoutCode = name.substring(0, 2).toUpperCase()
                    }
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: layoutQueryProc.running = true
    }

    Text {
        anchors.centerIn: parent
        text: root.layoutCode
        font.family: "Geist"
        font.pixelSize: 12
        font.bold: true
        color: kbdHover.containsMouse ? Colors.colPrimary : Colors.colText
    }

    MouseArea {
        id: kbdHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                switchLayoutProc.running = true
            } else {
                toggleProc.running = true
            }
        }
    }

    Process {
        id: switchLayoutProc
        command: ["niri", "msg", "action", "switch-layout", "next"]
        onExited: layoutQueryProc.running = true
    }

    Process {
        id: toggleProc
        command: ["/home/masum/dotfiles/quickshell/scripts/toggle-keyboard.sh"]
    }
}
