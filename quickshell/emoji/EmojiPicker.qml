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
    property var allEmojis: []

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "aether-emoji"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: root.isOpen || emojiCard.opacity > 0.0

    FileView {
        id: emojiFile
        path: Quickshell.env("HOME") + "/dotfiles/quickshell/emoji/emojis.txt"
        onLoaded: root.parseEmojis(text())
    }

    FileView {
        id: recentFile
        path: Quickshell.env("HOME") + "/.local/state/aether-emoji-history.txt"
        onLoaded: root.loadRecents(text())
    }

    property var recentList: []

    function loadRecents(content) {
        if (!content) return
        let lines = content.split("\n")
        let res = []
        for (let i = 0; i < lines.length; i++) {
            let l = lines[i].trim()
            if (!l) continue
            let parts = l.split(" ")
            if (parts.length >= 2) {
                res.push({ emoji: parts[0], name: parts.slice(1).join(" ") })
            }
        }
        root.recentList = res
    }

    function parseEmojis(content) {
        if (!content) return
        let lines = content.split("\n")
        let items = []
        let seen = {}

        for (let r = 0; r < root.recentList.length; r++) {
            let rec = root.recentList[r]
            if (!seen[rec.emoji]) {
                seen[rec.emoji] = true
                items.push({ emoji: rec.emoji, name: rec.name, recent: true })
            }
        }

        for (let i = 0; i < lines.length; i++) {
            let line = lines[i].trim()
            if (!line) continue
            let spaceIdx = line.indexOf(" ")
            if (spaceIdx === -1) continue
            let em = line.slice(0, spaceIdx)
            let nm = line.slice(spaceIdx + 1)
            if (!seen[em]) {
                seen[em] = true
                items.push({ emoji: em, name: nm, recent: false })
            }
        }
        root.allEmojis = items
    }

    readonly property var filteredEmojis: {
        let q = root.query.trim().toLowerCase()
        if (!q) {
            return root.allEmojis.slice(0, 60)
        }
        let matches = []
        for (let i = 0; i < root.allEmojis.length; i++) {
            let item = root.allEmojis[i]
            if (item.name.toLowerCase().includes(q) || item.emoji.includes(q)) {
                matches.push(item)
                if (matches.length >= 60) break
            }
        }
        return matches
    }

    onIsOpenChanged: {
        if (root.isOpen) {
            root.query = ""
            root.selectedIndex = 0
            if (root.allEmojis.length === 0) {
                if (recentFile.text()) root.loadRecents(recentFile.text())
                if (emojiFile.text()) root.parseEmojis(emojiFile.text())
            }
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

    function copySelected() {
        if (root.filteredEmojis.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < root.filteredEmojis.length) {
            copyItem(root.filteredEmojis[root.selectedIndex])
        }
    }

    function copyItem(item) {
        if (!item) return
        copyProc.command = ["wl-copy", item.emoji]
        copyProc.running = true
        root.close()
    }

    Process {
        id: copyProc
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
        id: emojiCard
        width: 540
        height: Math.min(490, Math.max(90, 72 + root.filteredEmojis.length * 48))
        anchors.centerIn: parent
        radius: 16
        color: "#000000"
        border.color: "transparent"
        border.width: 0

        scale: root.isOpen ? 1.0 : 0.95
        opacity: root.isOpen ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation { duration: 220; easing.type: Easing.OutQuint }
        }
        Behavior on opacity {
            NumberAnimation { duration: 180 }
        }
        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.OutQuint }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6

            // Search Bar Header
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                spacing: 10

                Text {
                    text: "󰞅"
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
                        text: "Search emojis..."
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
                    }

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Escape) {
                            root.close()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down) {
                            if (root.filteredEmojis.length > 0) {
                                root.selectedIndex = (root.selectedIndex + 1) % root.filteredEmojis.length
                                resultsView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            if (root.filteredEmojis.length > 0) {
                                root.selectedIndex = (root.selectedIndex - 1 + root.filteredEmojis.length) % root.filteredEmojis.length
                                resultsView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.copySelected()
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

            // Results List
            ListView {
                id: resultsView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                model: root.filteredEmojis

                delegate: Rectangle {
                    id: delegateItem
                    width: resultsView.width
                    height: 44
                    radius: 10

                    property bool isSelected: index === root.selectedIndex

                    color: isSelected ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.16)
                                      : (rowHover.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")

                    Behavior on color { ColorAnimation { duration: 120 } }

                    MouseArea {
                        id: rowHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: {
                            root.selectedIndex = index
                        }
                        onClicked: {
                            root.selectedIndex = index
                            root.copyItem(modelData)
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 12

                        // Emoji preview icon
                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 8
                            color: Qt.rgba(1, 1, 1, 0.06)
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                anchors.centerIn: parent
                                text: modelData.emoji
                                font.pixelSize: 18
                            }
                        }

                        // Emoji description
                        Text {
                            Layout.fillWidth: true
                            text: modelData.name
                            font.family: "Geist"
                            font.pixelSize: 13
                            font.bold: true
                            color: isSelected ? "#ffffff" : Colors.colText
                            elide: Text.ElideRight
                            Layout.alignment: Qt.AlignVCenter
                        }

                        // Recent indicator
                        Text {
                            text: modelData.recent ? "recent" : ""
                            font.family: "Geist"
                            font.pixelSize: 11
                            color: Colors.colTextMuted
                            opacity: 0.6
                            visible: modelData.recent
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }
            }
        }
    }
}
