import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"

Item {
    id: root
    implicitWidth: isPlaying ? (barsRow.implicitWidth + 8) : 0
    implicitHeight: 20
    visible: opacity > 0
    opacity: isPlaying ? 1.0 : 0.0
    clip: true

    Behavior on opacity {
        NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
    }
    Behavior on implicitWidth {
        NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
    }

    property bool isPlaying: false
    property color barColor: Colors.colPrimary
    property var levels: [0, 0, 0, 0, 0, 0, 0, 0]

    Process {
        id: cavaProc
        command: ["cava", "-p", "/home/masum/dotfiles/quickshell/bar/cava.conf"]
        running: root.isPlaying

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(";");
                if (parts.length >= 8) {
                    let newLevels = [];
                    for (let i = 0; i < 8; i++) {
                        let val = parseInt(parts[i], 10);
                        newLevels.push(isNaN(val) ? 0 : Math.min(100, Math.max(0, val)));
                    }
                    root.levels = newLevels;
                }
            }
        }
    }

    onIsPlayingChanged: {
        if (!isPlaying) {
            levels = [0, 0, 0, 0, 0, 0, 0, 0];
        }
    }

    Row {
        id: barsRow
        anchors.centerIn: parent
        spacing: 3
        height: 14

        Repeater {
            model: 8

            Rectangle {
                id: bar
                width: 3.5
                radius: 1.75
                color: root.barColor
                anchors.bottom: parent.bottom

                readonly property real minH: 3
                readonly property real maxH: 14
                readonly property real targetH: {
                    let lvl = (root.levels && root.levels.length > index) ? root.levels[index] : 0;
                    return minH + (maxH - minH) * (lvl / 100.0);
                }

                height: targetH

                Behavior on height {
                    NumberAnimation {
                        duration: 80
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }
    }
}
