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
    property int selectedIndex: 0
    property var wallpapers: []

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "aether-wallpaper"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: root.isOpen || wallCard.opacity > 0.0

    Process {
        id: listProc
        command: ["bash", "-c", "ls -1 /home/masum/dotfiles/wallpapers | grep -E '\\.(jpg|jpeg|png|webp)$'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n")
                let res = []
                for (let i = 0; i < lines.length; i++) {
                    let file = lines[i].trim()
                    if (file) {
                        res.push({
                            name: file.replace(/\.[^/.]+$/, "").replace(/[-_]/g, " "),
                            file: file,
                            path: "/home/masum/dotfiles/wallpapers/" + file
                        })
                    }
                }
                root.wallpapers = res
            }
        }
    }

    Process {
        id: applyProc
    }

    onIsOpenChanged: {
        if (root.isOpen) {
            root.selectedIndex = 0
            listProc.running = true
            keyHandler.forceActiveFocus()
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

    function selectWallpaper(item) {
        if (!item) return
        root.close()
        applyProc.command = ["bash", "/home/masum/dotfiles/scripts/theme.sh", item.path]
        applyProc.running = true
    }

    function triggerSelected() {
        if (root.wallpapers.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < root.wallpapers.length) {
            selectWallpaper(root.wallpapers[root.selectedIndex])
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
        id: wallCard
        width: 620
        height: 520
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
                    text: "󰸉"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 18
                    color: Colors.colPrimary
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: "Select Wallpaper"
                    Layout.fillWidth: true
                    font.family: "Geist"
                    font.pixelSize: 14
                    font.bold: true
                    color: Colors.colText
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
                id: wallList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                boundsBehavior: Flickable.StopAtBounds
                currentIndex: root.selectedIndex
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 120
                model: root.wallpapers

                delegate: Rectangle {
                    id: delegateItem
                    width: wallList.width
                    height: 52
                    radius: 10

                    property bool isSelected: index === root.selectedIndex

                    color: isSelected ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.16)
                                      : (itemHover.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")

                    Behavior on color { ColorAnimation { duration: 120 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 12
                        spacing: 12

                        Rectangle {
                            Layout.preferredWidth: 64
                            Layout.preferredHeight: 38
                            radius: 6
                            color: Qt.rgba(1, 1, 1, 0.08)
                            clip: true
                            Layout.alignment: Qt.AlignVCenter

                            Image {
                                anchors.fill: parent
                                source: "file://" + modelData.path
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                            }
                        }

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
                            root.selectWallpaper(modelData)
                        }
                    }
                }
            }
        }

        Item {
            id: keyHandler
            focus: root.isOpen
            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape) {
                    root.close()
                    event.accepted = true
                } else if (event.key === Qt.Key_Down) {
                    if (root.wallpapers.length > 0) {
                        if (root.selectedIndex < root.wallpapers.length - 1) {
                            root.selectedIndex += 1
                            wallList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                        } else {
                            root.selectedIndex = 0
                            wallList.positionViewAtIndex(0, ListView.Beginning)
                        }
                    }
                    event.accepted = true
                } else if (event.key === Qt.Key_Up) {
                    if (root.wallpapers.length > 0) {
                        if (root.selectedIndex > 0) {
                            root.selectedIndex -= 1
                            wallList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                        } else {
                            root.selectedIndex = root.wallpapers.length - 1
                            wallList.positionViewAtIndex(root.selectedIndex, ListView.End)
                        }
                    }
                    event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    root.triggerSelected()
                    event.accepted = true
                }
            }
        }
    }
}
