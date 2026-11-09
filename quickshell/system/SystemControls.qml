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
    property var sysState: ({
        speaker: true,
        mic: true,
        sunset: false,
        wifi: true,
        bluetooth: false,
        firewall: false,
        camera: false
    })

    readonly property var controlItems: [
        { id: "speaker", title: "Speaker", icon: "󰓃", action: "toggle_speaker" },
        { id: "mic", title: "Microphone", icon: "", action: "toggle_mic" },
        { id: "wifi", title: "Wi-Fi", icon: "", action: "toggle_wifi" },
        { id: "bluetooth", title: "Bluetooth", icon: "", action: "toggle_bluetooth" },
        { id: "sunset", title: "Night Light", icon: "󰖔", action: "toggle_sunset" },
        { id: "camera", title: "Camera", icon: "󰄀", action: "toggle_camera" },
        { id: "firewall", title: "Firewall (UFW)", icon: "󰒓", action: "toggle_firewall" }
    ]

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "aether-sys-controls"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: root.isOpen || controlCard.opacity > 0.0

    Process {
        id: statusProc
        command: ["/home/masum/dotfiles/quickshell/scripts/sys-control.sh", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.sysState = JSON.parse(text.trim())
                } catch (e) {}
            }
        }
    }

    Process {
        id: actionProc
        onExited: {
            refreshTimer.start()
        }
    }

    Timer {
        id: refreshTimer
        interval: 180
        onTriggered: statusProc.running = true
    }

    function open() {
        root.selectedIndex = 0
        root.isOpen = true
        statusProc.running = true
        keyHandler.forceActiveFocus()
    }

    function close() {
        root.isOpen = false
    }

    function toggle() {
        if (root.isOpen) close()
        else open()
    }

    function triggerSelected() {
        if (root.selectedIndex >= 0 && root.selectedIndex < root.controlItems.length) {
            triggerItem(root.controlItems[root.selectedIndex])
        }
    }

    function triggerItem(item) {
        if (!item) return
        root.sysState[item.id] = !root.sysState[item.id]
        actionProc.command = ["/home/masum/dotfiles/quickshell/scripts/sys-control.sh", item.action]
        actionProc.running = true
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
        id: controlCard
        width: 480
        height: 72 + root.controlItems.length * 44
        anchors.centerIn: parent
        radius: 16
        color: "#000000"
        border.color: "transparent"
        border.width: 0

        scale: root.isOpen ? 1.0 : 0.95
        opacity: root.isOpen ? 1.0 : 0.0

        Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutQuint } }
        Behavior on opacity { NumberAnimation { duration: 180 } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6

            // Header
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                spacing: 10

                Text {
                    text: "󰒓"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 16
                    color: Colors.colPrimary
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: "System Controls"
                    font.family: "Geist"
                    font.pixelSize: 14
                    font.bold: true
                    color: Colors.colText
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }

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

            // Clean list matching Mod+D
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                model: root.controlItems

                delegate: Rectangle {
                    id: delegateItem
                    width: listView.width
                    height: 42
                    radius: 10

                    property bool isSelected: index === root.selectedIndex
                    property bool isActive: Boolean(root.sysState[modelData.id])

                    color: isSelected ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.16)
                                      : (itemHover.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")

                    Behavior on color { ColorAnimation { duration: 120 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12

                        Text {
                            text: modelData.icon
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 16
                            color: delegateItem.isActive ? Colors.colPrimary : Colors.colTextMuted
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.title
                            font.family: "Geist"
                            font.pixelSize: 13
                            font.bold: true
                            color: isSelected ? "#ffffff" : Colors.colText
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            text: delegateItem.isActive ? "Active" : "Disabled"
                            font.family: "Geist"
                            font.pixelSize: 11
                            font.bold: true
                            color: delegateItem.isActive ? Colors.colPrimary : Colors.colTextMuted
                            opacity: delegateItem.isActive ? 1.0 : 0.5
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    MouseArea {
                        id: itemHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: {
                            root.selectedIndex = index
                        }
                        onClicked: {
                            root.selectedIndex = index
                            root.triggerItem(modelData)
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
                    root.selectedIndex = (root.selectedIndex + 1) % root.controlItems.length
                    event.accepted = true
                } else if (event.key === Qt.Key_Up) {
                    root.selectedIndex = (root.selectedIndex - 1 + root.controlItems.length) % root.controlItems.length
                    event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    root.triggerSelected()
                    event.accepted = true
                }
            }
        }
    }
}
