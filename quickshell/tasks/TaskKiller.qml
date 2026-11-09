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
    property var processList: []

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "aether-tasks"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: root.isOpen || taskCard.opacity > 0.0

    Process {
        id: psProc
        command: ["bash", "-c", "ps x -o pid,%mem,comm --sort=-%mem | head -n 60"]
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n")
                let res = []
                for (let i = 1; i < lines.length; i++) {
                    let line = lines[i].trim()
                    if (!line) continue
                    let parts = line.split(/\s+/)
                    if (parts.length >= 3) {
                        let pid = parts[0]
                        let mem = parts[1]
                        let comm = parts.slice(2).join(" ")
                        res.push({ pid: pid, mem: mem, comm: comm })
                    }
                }
                root.processList = res
            }
        }
    }

    Process {
        id: killProc
        onExited: {
            psProc.running = true
        }
    }

    readonly property var filteredProcesses: {
        let q = root.query.trim().toLowerCase()
        if (!q) {
            return root.processList
        }
        let matches = []
        for (let i = 0; i < root.processList.length; i++) {
            let item = root.processList[i]
            if (item.comm.toLowerCase().includes(q) || item.pid.includes(q)) {
                matches.push(item)
            }
        }
        return matches
    }

    onIsOpenChanged: {
        if (root.isOpen) {
            root.query = ""
            root.selectedIndex = 0
            psProc.running = true
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

    function killSelected() {
        if (root.filteredProcesses.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < root.filteredProcesses.length) {
            killProcess(root.filteredProcesses[root.selectedIndex])
        }
    }

    function killProcess(item) {
        if (!item) return
        killProc.command = ["kill", "-9", item.pid]
        killProc.running = true
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
        id: taskCard
        width: 520
        height: Math.min(480, Math.max(90, 72 + root.filteredProcesses.length * 44))
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
                    text: "󰆴"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 18
                    color: Colors.colError
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
                        text: "Search processes to terminate..."
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
                            if (root.filteredProcesses.length > 0) {
                                if (root.selectedIndex < root.filteredProcesses.length - 1) {
                                    root.selectedIndex += 1
                                    processView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                                } else {
                                    root.selectedIndex = 0
                                    processView.positionViewAtIndex(0, ListView.Beginning)
                                }
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            if (root.filteredProcesses.length > 0) {
                                if (root.selectedIndex > 0) {
                                    root.selectedIndex -= 1
                                    processView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                                } else {
                                    root.selectedIndex = root.filteredProcesses.length - 1
                                    processView.positionViewAtIndex(root.selectedIndex, ListView.End)
                                }
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Delete) {
                            root.killSelected()
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
                id: processView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                currentIndex: root.selectedIndex
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 120
                model: root.filteredProcesses

                delegate: Rectangle {
                    id: delegateItem
                    width: processView.width
                    height: 40
                    radius: 10

                    property bool isSelected: index === root.selectedIndex

                    color: isSelected ? Qt.rgba(Colors.colError.r, Colors.colError.g, Colors.colError.b, 0.16)
                                      : (itemHover.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")

                    Behavior on color { ColorAnimation { duration: 120 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 12

                        Text {
                            text: modelData.pid
                            font.family: "Geist"
                            font.pixelSize: 12
                            font.bold: true
                            color: Colors.colTextMuted
                            Layout.preferredWidth: 50
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.comm
                            font.family: "Geist"
                            font.pixelSize: 13
                            font.bold: true
                            color: isSelected ? "#ffffff" : Colors.colText
                            elide: Text.ElideRight
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Rectangle {
                            Layout.preferredHeight: 22
                            Layout.preferredWidth: 50
                            radius: 6
                            color: Qt.rgba(1, 1, 1, 0.06)
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                anchors.centerIn: parent
                                text: modelData.mem + "%"
                                font.family: "Geist"
                                font.pixelSize: 11
                                font.bold: true
                                color: parseFloat(modelData.mem) > 5.0 ? Colors.colError : Colors.colTextMuted
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 26
                            Layout.preferredHeight: 26
                            radius: 6
                            color: killBtnHover.containsMouse ? Qt.rgba(Colors.colError.r, Colors.colError.g, Colors.colError.b, 0.25) : "transparent"
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 12
                                color: killBtnHover.containsMouse ? Colors.colError : Colors.colTextMuted
                            }

                            MouseArea {
                                id: killBtnHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.killProcess(modelData)
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: itemHover
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 35
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.selectedIndex = index
                            root.killProcess(modelData)
                        }
                    }
                }
            }
        }
    }
}
