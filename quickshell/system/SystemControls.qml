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
    property int sunsetTemp: 3500
    property var sysState: ({
        speaker: true,
        mic: true,
        sunset: false,
        wifi: true,
        bluetooth: false,
        firewall: false,
        camera: false,
        sunset_temp: 3500
    })

    readonly property var controlItems: [
        { id: "speaker", title: "Speaker", iconActive: "󰓃", iconInactive: "󰝟", action: "toggle_speaker" },
        { id: "mic", title: "Microphone", iconActive: "", iconInactive: "", action: "toggle_mic" },
        { id: "wifi", title: "Wi-Fi", iconActive: "", iconInactive: "󰤮", action: "toggle_wifi" },
        { id: "bluetooth", title: "Bluetooth", iconActive: "", iconInactive: "󰂲", action: "toggle_bluetooth" },
        { id: "sunset", title: "Night Light", iconActive: "󰖔", iconInactive: "󰖙", action: "toggle_sunset" },
        { id: "camera", title: "Camera", iconActive: "󰄀", iconInactive: "󰄟", action: "toggle_camera" },
        { id: "firewall", title: "Firewall (UFW)", iconActive: "󰒓", iconInactive: "󰒓", action: "toggle_firewall" }
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
                    let parsed = JSON.parse(text.trim())
                    root.sysState = parsed
                    if (parsed.sunset_temp) root.sunsetTemp = parsed.sunset_temp
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

    function adjustNightLight(delta) {
        let newTemp = Math.max(1000, Math.min(6400, root.sunsetTemp + delta))
        root.sunsetTemp = newTemp
        actionProc.command = ["/home/masum/dotfiles/quickshell/scripts/sys-control.sh", "set_sunset_temp", newTemp.toString()]
        actionProc.running = true
    }

    function triggerItem(item) {
        if (!item) return
        let nextState = !root.sysState[item.id]
        root.sysState[item.id] = nextState

        actionProc.command = ["/home/masum/dotfiles/quickshell/scripts/sys-control.sh", item.action]
        actionProc.running = true

        let displayIcon = nextState ? item.iconActive : item.iconInactive
        let stateStr = nextState ? "Enabled" : "Disabled"
        if (item.id === "speaker") stateStr = nextState ? "Unmuted" : "Muted"
        if (item.id === "mic") stateStr = nextState ? "Unmuted" : "Muted"
        if (item.id === "sunset" && nextState) stateStr = root.sunsetTemp + "K"

        root.close()

        osdOverlay.showToast(displayIcon, item.title, stateStr)
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
                    property bool isSunset: modelData.id === "sunset"

                    color: isSelected ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.16)
                                      : (itemHover.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")

                    Behavior on color { ColorAnimation { duration: 120 } }

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
                        onWheel: (wheel) => {
                            if (delegateItem.isSunset) {
                                if (wheel.angleDelta.y > 0) {
                                    root.adjustNightLight(-250)
                                } else if (wheel.angleDelta.y < 0) {
                                    root.adjustNightLight(250)
                                }
                            }
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12

                        Text {
                            text: delegateItem.isActive ? modelData.iconActive : modelData.iconInactive
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

                        RowLayout {
                            visible: delegateItem.isSunset
                            spacing: 6
                            Layout.alignment: Qt.AlignVCenter

                            Rectangle {
                                width: 24
                                height: 24
                                radius: 5
                                color: plusArea.containsMouse ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(1, 1, 1, 0.08)

                                Behavior on color { ColorAnimation { duration: 100 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: "+"
                                    font.family: "Geist"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: Colors.colText
                                }

                                MouseArea {
                                    id: plusArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    preventStealing: true
                                    propagateComposedEvents: false
                                    onClicked: {
                                        root.adjustNightLight(-250)
                                    }
                                }
                            }

                            Text {
                                text: root.sunsetTemp + "K"
                                font.family: "Geist"
                                font.pixelSize: 11
                                font.bold: true
                                color: delegateItem.isActive ? Colors.colPrimary : Colors.colTextMuted
                            }

                            Rectangle {
                                width: 24
                                height: 24
                                radius: 5
                                color: minusArea.containsMouse ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(1, 1, 1, 0.08)

                                Behavior on color { ColorAnimation { duration: 100 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: "−"
                                    font.family: "Geist"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: Colors.colText
                                }

                                MouseArea {
                                    id: minusArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    preventStealing: true
                                    propagateComposedEvents: false
                                    onClicked: {
                                        root.adjustNightLight(250)
                                    }
                                }
                            }
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
                } else if (event.key === Qt.Key_Left) {
                    let cur = root.controlItems[root.selectedIndex]
                    if (cur && cur.id === "sunset") {
                        root.adjustNightLight(-250)
                        event.accepted = true
                    }
                } else if (event.key === Qt.Key_Right) {
                    let cur = root.controlItems[root.selectedIndex]
                    if (cur && cur.id === "sunset") {
                        root.adjustNightLight(250)
                        event.accepted = true
                    }
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    root.triggerSelected()
                    event.accepted = true
                }
            }
        }
    }
}
