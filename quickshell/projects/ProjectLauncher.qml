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
    property var projectList: []
    property var selectedProject: null
    property int editorChoiceIndex: 0

    readonly property var editorOptions: [
        { name: "VS Code", icon: "󰨞", cmd: "code", desc: "Open in Visual Studio Code" },
        { name: "Zed", icon: "Z", cmd: "zeditor", desc: "Open in Zed Editor" }
    ]

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "aether-projects"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: root.isOpen || projCard.opacity > 0.0

    Process {
        id: scanProc
        command: ["bash", "-c", "find ~/Projects ~/\"Repos (Arch)\" /mnt/windows/Repositories -mindepth 1 -maxdepth 1 -type d -not -name 'node_modules' -printf '%T@ %p\\n' 2>/dev/null | sort -rn | cut -d' ' -f2-"]
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n")
                let res = []
                let seen = {}
                for (let i = 0; i < lines.length; i++) {
                    let path = lines[i].trim()
                    if (!path) continue
                    let name = path.split("/").pop()
                    if (!seen[name]) {
                        seen[name] = true
                        res.push({ name: name, path: path })
                    }
                }
                root.projectList = res
            }
        }
    }

    Process {
        id: launchProc
    }

    readonly property var filteredProjects: {
        let q = root.query.trim().toLowerCase()
        if (!q) {
            return root.projectList
        }
        let matches = []
        for (let i = 0; i < root.projectList.length; i++) {
            let item = root.projectList[i]
            if (item.name.toLowerCase().includes(q) || item.path.toLowerCase().includes(q)) {
                matches.push(item)
            }
        }
        return matches
    }

    onIsOpenChanged: {
        if (root.isOpen) {
            root.query = ""
            root.selectedIndex = 0
            root.selectedProject = null
            root.editorChoiceIndex = 0
            scanProc.running = true
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
        root.selectedProject = null
    }

    function chooseProject(item) {
        if (!item) return
        root.selectedProject = item
        root.editorChoiceIndex = 0
        editorKeyHandler.forceActiveFocus()
    }

    function launchWithEditor(cmd) {
        if (!root.selectedProject) return
        root.close()
        launchProc.command = [cmd, root.selectedProject.path]
        launchProc.running = true
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
        id: projCard
        width: root.selectedProject !== null ? 420 : 580
        height: root.selectedProject !== null ? 176 : Math.min(500, Math.max(90, 72 + root.filteredProjects.length * 48))
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
        Behavior on width {
            NumberAnimation { duration: 200; easing.type: Easing.OutQuint }
        }
        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.OutQuint }
        }

        // STEP 1: Project Picker View
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6
            visible: root.selectedProject === null

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                spacing: 10

                Text {
                    text: "󰨞"
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
                        text: "Search code projects..."
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
                            if (root.filteredProjects.length > 0) {
                                if (root.selectedIndex < root.filteredProjects.length - 1) {
                                    root.selectedIndex += 1
                                    projView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                                } else {
                                    root.selectedIndex = 0
                                    projView.positionViewAtIndex(0, ListView.Beginning)
                                }
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            if (root.filteredProjects.length > 0) {
                                if (root.selectedIndex > 0) {
                                    root.selectedIndex -= 1
                                    projView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                                } else {
                                    root.selectedIndex = root.filteredProjects.length - 1
                                    projView.positionViewAtIndex(root.selectedIndex, ListView.End)
                                }
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (root.filteredProjects.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < root.filteredProjects.length) {
                                root.chooseProject(root.filteredProjects[root.selectedIndex])
                            }
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
                id: projView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                currentIndex: root.selectedIndex
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 120
                model: root.filteredProjects

                delegate: Rectangle {
                    id: delegateItem
                    width: projView.width
                    height: 46
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
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 8
                            color: Qt.rgba(1, 1, 1, 0.06)
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                anchors.centerIn: parent
                                text: "󰉓"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 16
                                color: isSelected ? Colors.colPrimary : Colors.colTextMuted
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
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
                            text: "󰅂"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 13
                            color: isSelected ? Colors.colPrimary : Colors.colTextMuted
                            opacity: isSelected ? 1.0 : 0.4
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
                            root.chooseProject(modelData)
                        }
                    }
                }
            }
        }

        // STEP 2: Editor Selection View (VS Code vs Zed)
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6
            visible: root.selectedProject !== null

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                spacing: 10

                Text {
                    text: "󰅁"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 16
                    color: Colors.colPrimary
                    Layout.alignment: Qt.AlignVCenter

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.selectedProject = null
                            searchInput.forceActiveFocus()
                        }
                    }
                }

                Text {
                    text: "Open with Editor"
                    font.family: "Geist"
                    font.pixelSize: 14
                    font.bold: true
                    color: Colors.colText
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
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
                id: editorListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                boundsBehavior: Flickable.StopAtBounds
                currentIndex: root.editorChoiceIndex
                model: root.editorOptions

                delegate: Rectangle {
                    id: editorDelegate
                    width: editorListView.width
                    height: 46
                    radius: 10

                    property bool isSelected: index === root.editorChoiceIndex

                    color: isSelected ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.16)
                                      : (edHover.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")

                    Behavior on color { ColorAnimation { duration: 120 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 12

                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 8
                            color: Qt.rgba(1, 1, 1, 0.06)
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                font.family: modelData.icon.length === 1 ? "Geist" : "Symbols Nerd Font"
                                font.pixelSize: modelData.icon.length === 1 ? 14 : 16
                                font.bold: true
                                color: isSelected ? Colors.colPrimary : Colors.colTextMuted
                            }
                        }

                        Text {
                            text: modelData.name
                            font.family: "Geist"
                            font.pixelSize: 13
                            font.bold: true
                            color: isSelected ? "#ffffff" : Colors.colText
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            radius: 5
                            color: Qt.rgba(1, 1, 1, 0.08)
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                anchors.centerIn: parent
                                text: index === 0 ? "1" : "2"
                                font.family: "Geist"
                                font.pixelSize: 11
                                font.bold: true
                                color: isSelected ? Colors.colPrimary : Colors.colTextMuted
                            }
                        }
                    }

                    MouseArea {
                        id: edHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.editorChoiceIndex = index
                            root.launchWithEditor(modelData.cmd)
                        }
                    }
                }
            }
        }

        Item {
            id: editorKeyHandler
            focus: root.selectedProject !== null
            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape || event.key === Qt.Key_Backspace) {
                    root.selectedProject = null
                    searchInput.forceActiveFocus()
                    event.accepted = true
                } else if (event.key === Qt.Key_Down) {
                    root.editorChoiceIndex = (root.editorChoiceIndex + 1) % root.editorOptions.length
                    event.accepted = true
                } else if (event.key === Qt.Key_Up) {
                    root.editorChoiceIndex = (root.editorChoiceIndex - 1 + root.editorOptions.length) % root.editorOptions.length
                    event.accepted = true
                } else if (event.key === Qt.Key_1) {
                    root.launchWithEditor("code")
                    event.accepted = true
                } else if (event.key === Qt.Key_2) {
                    root.launchWithEditor("zeditor")
                    event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    root.launchWithEditor(root.editorOptions[root.editorChoiceIndex].cmd)
                    event.accepted = true
                }
            }
        }
    }
}
