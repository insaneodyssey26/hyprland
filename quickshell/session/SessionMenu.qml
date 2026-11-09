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

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "aether-session"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: root.isOpen || sessionCard.opacity > 0.0

    readonly property var sessionItems: [
        { label: "Lock", icon: "󰌾", action: "lock", desc: "Lock desktop session" },
        { label: "Power Off", icon: "󰐥", action: "poweroff", desc: "Shut down system" },
        { label: "Reboot", icon: "󰜉", action: "reboot", desc: "Restart computer" },
        { label: "Log Out", icon: "󰍃", action: "logout", desc: "Terminate user session" }
    ]

    function toggle() {
        root.isOpen = !root.isOpen
    }

    function open() {
        root.isOpen = true
    }

    function close() {
        root.isOpen = false
    }

    onIsOpenChanged: {
        if (root.isOpen) {
            root.selectedIndex = 0
            keyHandler.forceActiveFocus()
        }
    }

    function triggerSelected() {
        if (root.selectedIndex >= 0 && root.selectedIndex < root.sessionItems.length) {
            triggerAction(root.sessionItems[root.selectedIndex].action)
        }
    }

    function triggerAction(action) {
        root.close()
        if (action === "lock") {
            proc.command = ["loginctl", "lock-session"]
        } else if (action === "poweroff") {
            proc.command = ["systemctl", "poweroff"]
        } else if (action === "reboot") {
            proc.command = ["systemctl", "reboot"]
        } else if (action === "logout") {
            proc.command = ["loginctl", "terminate-user", Quickshell.env("USER")]
        }
        proc.running = true
    }

    Process {
        id: proc
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
        id: sessionCard
        width: 480
        height: 72 + root.sessionItems.length * 48
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
                    text: "󰐥"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 18
                    color: Colors.colPrimary
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: "System Session"
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
                id: sessionList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                model: root.sessionItems

                delegate: Rectangle {
                    id: delegateItem
                    width: sessionList.width
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
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 8
                            color: Qt.rgba(1, 1, 1, 0.06)
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 15
                                color: isSelected ? Colors.colPrimary : Colors.colTextMuted
                            }
                        }

                        Text {
                            text: modelData.label
                            font.family: "Geist"
                            font.pixelSize: 13
                            font.bold: true
                            color: isSelected ? "#ffffff" : Colors.colText
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: modelData.desc
                            font.family: "Geist"
                            font.pixelSize: 11
                            color: Colors.colTextMuted
                            opacity: 0.6
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
                            root.triggerAction(modelData.action)
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
                    root.selectedIndex = (root.selectedIndex + 1) % root.sessionItems.length
                    event.accepted = true
                } else if (event.key === Qt.Key_Up) {
                    root.selectedIndex = (root.selectedIndex - 1 + root.sessionItems.length) % root.sessionItems.length
                    event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    root.triggerSelected()
                    event.accepted = true
                }
            }
        }
    }
}
