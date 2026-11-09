import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../theme"

PanelWindow {
    id: root

    property bool isOpen: false
    property string query: ""
    property int selectedIndex: 0
    property var searchResults: []
    property var recentFiles: []

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "aether-finder"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: root.isOpen || finderCard.opacity > 0.0

    Process {
        id: recentProc
        command: ["bash", "-c", "python3 -c \"import urllib.parse, os, re; p = os.path.expanduser('~/.local/share/recently-used.xbel'); matches = re.findall(r'href=\\\"file://([^\\\"]+)\\\"', open(p).read()) if os.path.exists(p) else []; seen = set(); res = []; [res.append(urllib.parse.unquote(m)) for m in reversed(matches) if urllib.parse.unquote(m) not in seen and os.path.exists(urllib.parse.unquote(m)) and not seen.add(urllib.parse.unquote(m)) and len(res) < 20]; print('\\n'.join(res))\""]
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n")
                let res = []
                for (let i = 0; i < lines.length; i++) {
                    let p = lines[i].trim()
                    if (!p) continue
                    let filename = p.split("/").pop()
                    let isDir = !filename.includes(".")
                    res.push({
                        name: filename,
                        path: p,
                        isDir: isDir,
                        isRecent: true
                    })
                }
                root.recentFiles = res
            }
        }
    }

    readonly property var displayList: {
        if (root.query.trim().length > 0) {
            return root.searchResults
        }
        return root.recentFiles
    }

    Process {
        id: findProc
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n")
                let res = []
                for (let i = 0; i < lines.length; i++) {
                    let p = lines[i].trim()
                    if (!p) continue
                    let filename = p.split("/").pop()
                    let isDir = !filename.includes(".")
                    res.push({
                        name: filename,
                        path: p,
                        isDir: isDir
                    })
                }
                root.searchResults = res
            }
        }
    }

    Timer {
        id: debounceTimer
        interval: 180
        repeat: false
        onTriggered: {
            let q = root.query.trim()
            if (!q) {
                root.searchResults = []
                return
            }
            findProc.command = [
                "bash", "-c",
                "fd --max-depth 4 -i -t f -t d --exclude 'node_modules' --exclude '.git' --exclude '.cache' --exclude 'build' '" + q.replace(/'/g, "") + "' ~ '/mnt/windows/Repositories' '/mnt/windows/Video' '/mnt/windows/Masum Ali' 2>/dev/null | head -n 40"
            ]
            findProc.running = true
        }
    }

    Process {
        id: openProc
    }

    onIsOpenChanged: {
        if (root.isOpen) {
            root.query = ""
            root.selectedIndex = 0
            root.searchResults = []
            recentProc.running = true
            searchInput.text = ""
            searchInput.forceActiveFocus()
        }
    }

    function toggle() {
        root.isOpen = !root.isOpen
    }

    function open() {
        root.isOpen = true
    }

    function close() {
        root.isOpen = false
    }

    function openItem(item) {
        if (!item) return
        root.close()
        openProc.command = ["xdg-open", item.path]
        openProc.running = true
    }

    function openSelected() {
        if (root.displayList.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < root.displayList.length) {
            openItem(root.displayList[root.selectedIndex])
        }
    }

    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: "#000000"
        opacity: root.isOpen ? 0.45 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 180 }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    Rectangle {
        id: finderCard
        width: 600
        height: Math.min(500, Math.max(90, 72 + root.displayList.length * 46))
        anchors.centerIn: parent
        radius: 16
        color: Qt.rgba(18/255, 18/255, 20/255, 0.88)
        border.color: Qt.rgba(1, 1, 1, 0.12)
        border.width: 1

        scale: root.isOpen ? 1.0 : 0.95
        opacity: root.isOpen ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation { duration: 220; easing.type: Easing.OutQuint }
        }
        Behavior on opacity {
            NumberAnimation { duration: 180 }
        }
        Behavior on height {
            NumberAnimation { duration: 180; easing.type: Easing.OutQuint }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                spacing: 10

                Text {
                    text: "󰈞"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 18
                    color: Colors.colPrimary
                    Layout.alignment: Qt.AlignVCenter
                }

                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    font.family: "Geist"
                    font.pixelSize: 14
                    font.bold: true
                    color: Colors.colText
                    clip: true

                    Text {
                        text: "Search files across your system..."
                        font.family: "Geist"
                        font.pixelSize: 14
                        font.bold: true
                        color: Colors.colTextMuted
                        opacity: 0.5
                        visible: !searchInput.text && !searchInput.inputMethodComposing
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    onTextChanged: {
                        root.query = text
                        root.selectedIndex = 0
                        debounceTimer.restart()
                    }

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Escape) {
                            root.close()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down) {
                            if (root.displayList.length > 0) {
                                if (root.selectedIndex < root.displayList.length - 1) {
                                    root.selectedIndex += 1
                                    finderList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                                } else {
                                    root.selectedIndex = 0
                                    finderList.positionViewAtIndex(0, ListView.Beginning)
                                }
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            if (root.displayList.length > 0) {
                                if (root.selectedIndex > 0) {
                                    root.selectedIndex -= 1
                                    finderList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                                } else {
                                    root.selectedIndex = root.displayList.length - 1
                                    finderList.positionViewAtIndex(root.selectedIndex, ListView.End)
                                }
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.openSelected()
                            event.accepted = true
                        }
                    }
                }

                Text {
                    text: "esc"
                    font.family: "Geist"
                    font.pixelSize: 11
                    color: Colors.colTextMuted
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(1, 1, 1, 0.08)
            }

            ListView {
                id: finderList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                currentIndex: root.selectedIndex
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 120
                model: root.displayList

                delegate: Rectangle {
                    id: delegateItem
                    width: finderList.width
                    height: 44
                    radius: 10

                    property bool isSelected: index === root.selectedIndex

                    color: isSelected ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.16)
                                      : (itemHover.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")

                    Behavior on color { ColorAnimation { duration: 120 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 12

                        Rectangle {
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30
                            radius: 6
                            color: Qt.rgba(1, 1, 1, 0.06)
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                anchors.centerIn: parent
                                text: modelData.isDir ? "󰉓" : "󰈔"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 15
                                color: isSelected ? Colors.colPrimary : Colors.colTextMuted
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                text: modelData.name
                                font.family: "Geist"
                                font.pixelSize: 13
                                font.bold: true
                                color: isSelected ? "#ffffff" : Colors.colText
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: modelData.path.replace(Quickshell.env("HOME"), "~")
                                font.family: "Geist"
                                font.pixelSize: 11
                                color: Colors.colTextMuted
                                opacity: 0.6
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }
                        }

                        Text {
                            text: modelData.isRecent ? "recent" : "󰅂"
                            font.family: modelData.isRecent ? "Geist" : "Symbols Nerd Font"
                            font.pixelSize: modelData.isRecent ? 11 : 13
                            color: isSelected ? Colors.colPrimary : Colors.colTextMuted
                            opacity: isSelected ? 1.0 : (modelData.isRecent ? 0.6 : 0.3)
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    MouseArea {
                        id: itemHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.selectedIndex = index
                            root.openItem(modelData)
                        }
                    }
                }
            }
        }
    }
}
