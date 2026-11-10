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
    property var clipHistory: []

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "aether-clipboard"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: root.isOpen || clipCard.opacity > 0.0

    Component.onCompleted: {
        listProc.running = true
    }

    Process {
        id: listProc
        command: ["/home/masum/dotfiles/quickshell/scripts/clip-control.py", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.clipHistory = JSON.parse(text.trim())
                } catch (e) {
                    root.clipHistory = []
                }
            }
        }
    }

    Process {
        id: actionProc
        onExited: {
            listProc.running = true
        }
    }

    property var filteredClips: {
        let q = root.query.trim().toLowerCase()
        if (q === "") return root.clipHistory

        return root.clipHistory.filter(item => {
            let prev = (item.preview || "").toLowerCase()
            return prev.includes(q)
        })
    }

    onFilteredClipsChanged: {
        root.selectedIndex = 0
    }

    function open() {
        root.query = ""
        root.selectedIndex = 0
        root.isOpen = true
        listProc.running = true
        searchInput.forceActiveFocus()
    }

    function close() {
        root.isOpen = false
        searchInput.focus = false
    }

    function toggle() {
        if (root.isOpen) close()
        else open()
    }

    function copySelected() {
        if (root.filteredClips.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < root.filteredClips.length) {
            let item = root.filteredClips[root.selectedIndex]
            copyItem(item)
        }
    }

    function copyItem(item) {
        if (!item) return
        if (item.is_binary && item.id) {
            actionProc.command = ["/home/masum/dotfiles/quickshell/scripts/clip-control.py", "decode", item.id]
        } else if (item.full_text) {
            actionProc.command = ["/home/masum/dotfiles/quickshell/scripts/clip-control.py", "copy_text", item.full_text]
        } else {
            actionProc.command = ["/home/masum/dotfiles/quickshell/scripts/clip-control.py", "decode", item.id]
        }
        actionProc.running = true
        root.close()
    }

    function togglePin(item) {
        if (!item) return
        actionProc.command = ["/home/masum/dotfiles/quickshell/scripts/clip-control.py", "toggle_pin", JSON.stringify(item)]
        actionProc.running = true
    }

    function deleteItem(item) {
        if (!item) return
        let rawLine = item.id + "\t" + item.preview
        actionProc.command = ["/home/masum/dotfiles/quickshell/scripts/clip-control.py", "delete", rawLine]
        actionProc.running = true
    }

    function deleteSelected() {
        if (root.filteredClips.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < root.filteredClips.length) {
            deleteItem(root.filteredClips[root.selectedIndex])
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

    // Floating Clipboard Card
    Rectangle {
        id: clipCard
        width: 560
        height: Math.min(490, Math.max(90, 72 + root.filteredClips.length * 52))
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
                    text: "󰅌"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 16
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
                        text: "Search clipboard history..."
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
                    }

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Escape) {
                            root.close()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down) {
                            if (root.filteredClips.length > 0) {
                                root.selectedIndex = (root.selectedIndex + 1) % root.filteredClips.length
                                resultsView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            if (root.filteredClips.length > 0) {
                                root.selectedIndex = (root.selectedIndex - 1 + root.filteredClips.length) % root.filteredClips.length
                                resultsView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier)) {
                            if (root.filteredClips.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < root.filteredClips.length) {
                                root.togglePin(root.filteredClips[root.selectedIndex])
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_Delete || (event.modifiers & Qt.ShiftModifier && event.key === Qt.Key_Delete)) {
                            root.deleteSelected()
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
                model: root.filteredClips

                delegate: Rectangle {
                    id: delegateItem
                    width: resultsView.width
                    height: 48
                    radius: 10

                    property bool isSelected: index === root.selectedIndex

                    color: isSelected ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.16)
                                      : (rowHover.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")

                    Behavior on color { ColorAnimation { duration: 120 } }

                    RowLayout {
                        id: rowContent
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 12

                        // Row clickable area (covers thumbnail + text)
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

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
                                spacing: 12

                                // Inline Thumbnail or Icon
                                Rectangle {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    radius: 8
                                    color: Qt.rgba(1, 1, 1, 0.06)
                                    clip: true
                                    Layout.alignment: Qt.AlignVCenter

                                    Image {
                                        anchors.fill: parent
                                        source: modelData.image_path ? ("file://" + modelData.image_path) : ""
                                        sourceSize.width: 64
                                        sourceSize.height: 64
                                        asynchronous: true
                                        visible: modelData.is_binary && status === Image.Ready
                                        fillMode: Image.PreserveAspectCrop
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        visible: !modelData.is_binary || !modelData.image_path
                                        text: modelData.is_binary ? "󰋩" : "󰈙"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 15
                                        color: isSelected ? Colors.colPrimary : Colors.colTextMuted
                                    }
                                }

                                // Text content
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.is_binary ? "Screenshot / Image" : modelData.preview
                                    font.family: "Geist"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: isSelected ? "#ffffff" : Colors.colText
                                    elide: Text.ElideRight
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }
                        }

                        // Action Buttons container
                        Row {
                            id: actionButtonsRow
                            spacing: 4
                            Layout.alignment: Qt.AlignVCenter

                            // Pin Action Button
                            Rectangle {
                                width: 30
                                height: 30
                                radius: 6
                                color: pinHover.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : (modelData.pinned ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.12) : "transparent")

                                Behavior on color { ColorAnimation { duration: 100 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.pinned ? "󰤱" : "󰤰"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 14
                                    color: modelData.pinned ? Colors.colPrimary : (pinHover.containsMouse ? "#ffffff" : Colors.colTextMuted)
                                    opacity: modelData.pinned || pinHover.containsMouse ? 1.0 : (rowHover.containsMouse ? 0.7 : 0.0)
                                }

                                MouseArea {
                                    id: pinHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.togglePin(modelData)
                                    }
                                }
                            }

                            // Delete Action Button
                            Rectangle {
                                width: 30
                                height: 30
                                radius: 6
                                color: delHover.containsMouse ? Qt.rgba(Colors.colError.r, Colors.colError.g, Colors.colError.b, 0.22) : "transparent"

                                Behavior on color { ColorAnimation { duration: 100 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰆴"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 14
                                    color: delHover.containsMouse ? Colors.colError : Colors.colTextMuted
                                    opacity: delHover.containsMouse ? 1.0 : (rowHover.containsMouse ? 0.7 : 0.0)
                                }

                                MouseArea {
                                    id: delHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.deleteItem(modelData)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
