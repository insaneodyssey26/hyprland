import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"
import "../services"

Rectangle {
    id: root
    implicitHeight: 26
    implicitWidth: wifiRow.implicitWidth + 14
    radius: 13
    color: (wifiHover.containsMouse || PopupManager.isPopupOpen("wifi")) ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

    Behavior on color { ColorAnimation { duration: 150 } }

    property bool wifiExpanded: true
    property bool btExpanded: false
    property bool wifiRadioOn: true
    property bool btRadioOn: false
    property string activeWifiSsid: ""
    property var wifiNetworks: []
    property var btDevices: []

    Process {
        id: wirelessQueryProc
        command: ["python3", "/home/masum/dotfiles/scripts/wireless-devices.py"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (!data || data.trim() === "") return
                try {
                    let parsed = JSON.parse(data.trim())
                    if (parsed.wifi) {
                        root.wifiRadioOn = parsed.wifi.radio
                        root.activeWifiSsid = parsed.wifi.activeSsid || ""
                        root.wifiNetworks = parsed.wifi.networks || []
                    }
                    if (parsed.bt) {
                        root.btRadioOn = parsed.bt.powered
                        root.btDevices = parsed.bt.devices || []
                    }
                } catch(e) {}
            }
        }
    }

    Timer {
        interval: 8000
        running: wifiPopup.visible
        repeat: true
        onTriggered: {
            if (!wirelessQueryProc.running) {
                wirelessQueryProc.running = true
            }
        }
    }

    Process {
        id: cmdProc
        onExited: {
            wirelessQueryProc.running = true
        }
    }

    NetworkService {
        id: net
    }

    RowLayout {
        id: wifiRow
        anchors.centerIn: parent
        spacing: 5

        Text {
            horizontalAlignment: Text.AlignHCenter
            text: {
                if (!net.isConnected) return "󰤮"
                if (net.signalStrength > 75) return "󰤨"
                if (net.signalStrength > 50) return "󰤥"
                if (net.signalStrength > 25) return "󰤢"
                return "󰤟"
            }
            font.family: "Symbols Nerd Font"
            font.pixelSize: 13
            color: net.isConnected ? Colors.colPrimary : Colors.colError
        }

        Text {
            horizontalAlignment: Text.AlignLeft
            text: net.speedStr
            font.family: "Geist"
            font.pixelSize: 12
            font.bold: true
            color: Colors.colText
        }
    }

    MouseArea {
        id: wifiHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            PopupManager.openPopup("wifi")
            wirelessQueryProc.running = true
        }
    }

    PopupWindow {
        id: wifiPopup
        anchor {
            item: root
            edges: Edges.Bottom
            gravity: Edges.Bottom
            margins.top: 8
        }
        implicitWidth: 320
        implicitHeight: mainCardCol.implicitHeight + 36
        visible: PopupManager.isPopupOpen("wifi")
        grabFocus: true
        onVisibleChanged: {
            if (!visible && PopupManager.activePopup === "wifi") {
                PopupManager.closeAll()
            }
            if (visible) {
                wirelessQueryProc.running = true
            }
        }
        color: "transparent"

        Item {
            id: wifiAnimContainer
            anchors.fill: parent
            scale: 0.92
            opacity: 0.0

            Rectangle {
                anchors.fill: parent
                radius: 18
                color: "#000000"
                border.color: "transparent"
                border.width: 0

                ColumnLayout {
                    id: mainCardCol
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            width: 26
                            height: 26
                            radius: 13
                            color: Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.14)

                            Text {
                                anchors.centerIn: parent
                                text: "󰖩"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 14
                                color: Colors.colPrimary
                            }
                        }

                        Text {
                            text: "WIRELESS CENTER"
                            font.family: "Geist"
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 1.2
                            color: Colors.colTextMuted
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            implicitWidth: 28
                            implicitHeight: 28
                            radius: 14
                            color: nmtuiBtnMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.05)
                            border.color: Qt.rgba(1, 1, 1, 0.08)
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "󱘖"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 13
                                color: Colors.colText
                            }

                            MouseArea {
                                id: nmtuiBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    cmdProc.command = ["kitty", "-e", "nmtui"]
                                    cmdProc.running = true
                                    PopupManager.closeAll()
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: wifiSectionRect
                        Layout.fillWidth: true
                        implicitHeight: wifiHeaderWrap.implicitHeight + (root.wifiExpanded ? (wifiAccordionCol.implicitHeight + 14) : 0) + 16
                        radius: 12
                        color: Qt.rgba(1, 1, 1, 0.04)
                        border.color: Qt.rgba(1, 1, 1, 0.06)
                        border.width: 1
                        clip: true

                        Behavior on implicitHeight {
                            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            Item {
                                id: wifiHeaderWrap
                                Layout.fillWidth: true
                                implicitHeight: wifiHeaderRow.implicitHeight

                                RowLayout {
                                    id: wifiHeaderRow
                                    anchors.fill: parent
                                    spacing: 8

                                    Text {
                                        text: root.wifiRadioOn ? (net.isConnected ? "󰤨" : "󰤮") : "󰤮"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 14
                                        color: root.wifiRadioOn ? Colors.colPrimary : Colors.colTextMuted
                                    }

                                    Text {
                                        text: "Wi-Fi Networks"
                                        font.family: "Geist"
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: Colors.colText
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: root.wifiRadioOn ? (root.activeWifiSsid !== "" ? root.activeWifiSsid : "Disconnected") : "Off"
                                        font.family: "Geist"
                                        font.pixelSize: 11
                                        color: Colors.colTextMuted
                                        visible: !root.wifiExpanded
                                        elide: Text.ElideRight
                                        Layout.maximumWidth: 100
                                    }

                                    Rectangle {
                                        width: 32
                                        height: 18
                                        radius: 9
                                        color: root.wifiRadioOn ? Colors.colPrimary : Qt.rgba(1, 1, 1, 0.15)

                                        Behavior on color { ColorAnimation { duration: 150 } }

                                        Rectangle {
                                            width: 14
                                            height: 14
                                            radius: 7
                                            color: root.wifiRadioOn ? Colors.colOnPrimary : Colors.colTextMuted
                                            anchors.verticalCenter: parent.verticalCenter
                                            x: root.wifiRadioOn ? parent.width - width - 2 : 2
                                            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                cmdProc.command = ["nmcli", "radio", "wifi", (root.wifiRadioOn ? "off" : "on")]
                                                cmdProc.running = true
                                            }
                                        }
                                    }

                                    Text {
                                        text: root.wifiExpanded ? "󰅃" : "󰅀"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 12
                                        color: Colors.colTextMuted
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    anchors.rightMargin: 40
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.wifiExpanded = !root.wifiExpanded
                                }
                            }

                            ColumnLayout {
                                id: wifiAccordionCol
                                Layout.fillWidth: true
                                spacing: 4
                                opacity: root.wifiExpanded ? 1.0 : 0.0
                                visible: opacity > 0

                                Behavior on opacity {
                                    NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
                                }

                                Repeater {
                                    model: root.wifiNetworks.slice(0, 5)

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        radius: 7
                                        color: modelData.active ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.16)
                                                                : (netHover.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.03))
                                        border.color: modelData.active ? Colors.colPrimary : "transparent"
                                        border.width: modelData.active ? 1 : 0

                                        Behavior on color { ColorAnimation { duration: 120 } }

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 10
                                            anchors.rightMargin: 10
                                            spacing: 8

                                            Text {
                                                text: {
                                                    if (modelData.signal > 75) return "󰤨"
                                                    if (modelData.signal > 50) return "󰤥"
                                                    if (modelData.signal > 25) return "󰤢"
                                                    return "󰤟"
                                                }
                                                font.family: "Symbols Nerd Font"
                                                font.pixelSize: 13
                                                color: modelData.active ? Colors.colPrimary : Colors.colTextMuted
                                            }

                                            Text {
                                                text: modelData.ssid
                                                font.family: "Geist"
                                                font.pixelSize: 12
                                                font.bold: modelData.active
                                                color: modelData.active ? Colors.colPrimary : Colors.colText
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                visible: modelData.locked
                                                text: "󰌾"
                                                font.family: "Symbols Nerd Font"
                                                font.pixelSize: 11
                                                color: Colors.colTextMuted
                                            }

                                            Text {
                                                visible: modelData.active
                                                text: "󰄬"
                                                font.family: "Symbols Nerd Font"
                                                font.pixelSize: 12
                                                color: Colors.colPrimary
                                            }
                                        }

                                        MouseArea {
                                            id: netHover
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (!modelData.active) {
                                                    cmdProc.command = ["nmcli", "dev", "wifi", "connect", modelData.ssid]
                                                    cmdProc.running = true
                                                }
                                            }
                                        }
                                    }
                                }

                                Text {
                                    visible: root.wifiNetworks.length === 0
                                    text: root.wifiRadioOn ? "No networks in range" : "Wi-Fi is turned off"
                                    font.family: "Geist"
                                    font.pixelSize: 11
                                    color: Colors.colTextMuted
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.topMargin: 4
                                    Layout.bottomMargin: 4
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: btSectionRect
                        Layout.fillWidth: true
                        implicitHeight: btHeaderWrap.implicitHeight + (root.btExpanded ? (btAccordionCol.implicitHeight + 14) : 0) + 16
                        radius: 12
                        color: Qt.rgba(1, 1, 1, 0.04)
                        border.color: Qt.rgba(1, 1, 1, 0.06)
                        border.width: 1
                        clip: true

                        Behavior on implicitHeight {
                            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            Item {
                                id: btHeaderWrap
                                Layout.fillWidth: true
                                implicitHeight: btHeaderRow.implicitHeight

                                RowLayout {
                                    id: btHeaderRow
                                    anchors.fill: parent
                                    spacing: 8

                                    Text {
                                        text: root.btRadioOn ? "󰂯" : "󰂲"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 14
                                        color: root.btRadioOn ? Colors.colPrimary : Colors.colTextMuted
                                    }

                                    Text {
                                        text: "Bluetooth Devices"
                                        font.family: "Geist"
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: Colors.colText
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: {
                                            if (!root.btRadioOn) return "Off"
                                            for (let i = 0; i < root.btDevices.length; i++) {
                                                if (root.btDevices[i].connected) return root.btDevices[i].name
                                            }
                                            return "Disconnected"
                                        }
                                        font.family: "Geist"
                                        font.pixelSize: 11
                                        color: Colors.colTextMuted
                                        visible: !root.btExpanded
                                        elide: Text.ElideRight
                                        Layout.maximumWidth: 100
                                    }

                                    Rectangle {
                                        width: 32
                                        height: 18
                                        radius: 9
                                        color: root.btRadioOn ? Colors.colPrimary : Qt.rgba(1, 1, 1, 0.15)

                                        Behavior on color { ColorAnimation { duration: 150 } }

                                        Rectangle {
                                            width: 14
                                            height: 14
                                            radius: 7
                                            color: root.btRadioOn ? Colors.colOnPrimary : Colors.colTextMuted
                                            anchors.verticalCenter: parent.verticalCenter
                                            x: root.btRadioOn ? parent.width - width - 2 : 2
                                            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                let target = root.btRadioOn ? "off" : "on"
                                                root.btRadioOn = !root.btRadioOn
                                                cmdProc.command = ["python3", "/home/masum/dotfiles/scripts/wireless-devices.py", "toggle-bt", target]
                                                cmdProc.running = true
                                            }
                                        }
                                    }

                                    Text {
                                        text: root.btExpanded ? "󰅃" : "󰅀"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 12
                                        color: Colors.colTextMuted
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    anchors.rightMargin: 40
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.btExpanded = !root.btExpanded
                                }
                            }

                            ColumnLayout {
                                id: btAccordionCol
                                Layout.fillWidth: true
                                spacing: 4
                                opacity: root.btExpanded ? 1.0 : 0.0
                                visible: opacity > 0

                                Behavior on opacity {
                                    NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
                                }

                                Repeater {
                                    model: root.btDevices

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        radius: 7
                                        color: modelData.connected ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.16)
                                                                   : (btDevHover.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.03))
                                        border.color: modelData.connected ? Colors.colPrimary : "transparent"
                                        border.width: modelData.connected ? 1 : 0

                                        Behavior on color { ColorAnimation { duration: 120 } }

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 10
                                            anchors.rightMargin: 10
                                            spacing: 8

                                            Text {
                                                text: modelData.icon || "󰂯"
                                                font.family: "Symbols Nerd Font"
                                                font.pixelSize: 13
                                                color: modelData.connected ? Colors.colPrimary : Colors.colTextMuted
                                            }

                                            Text {
                                                text: modelData.name
                                                font.family: "Geist"
                                                font.pixelSize: 12
                                                font.bold: modelData.connected
                                                color: modelData.connected ? Colors.colPrimary : Colors.colText
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                text: modelData.connected ? "Connected" : "Disconnected"
                                                font.family: "Geist"
                                                font.pixelSize: 10
                                                color: modelData.connected ? Colors.colPrimary : Colors.colTextMuted
                                            }
                                        }

                                        MouseArea {
                                            id: btDevHover
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                let action = modelData.connected ? "disconnect" : "connect"
                                                cmdProc.command = ["bluetoothctl", action, modelData.mac]
                                                cmdProc.running = true
                                            }
                                        }
                                    }
                                }

                                Text {
                                    visible: root.btDevices.length === 0
                                    text: root.btRadioOn ? "No paired devices" : "Bluetooth is turned off"
                                    font.family: "Geist"
                                    font.pixelSize: 11
                                    color: Colors.colTextMuted
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.topMargin: 4
                                    Layout.bottomMargin: 4
                                }
                            }
                        }
                    }
                }
            }

            states: [
                State {
                    name: "visible"
                    when: wifiPopup.visible
                    PropertyChanges { target: wifiAnimContainer; scale: 1.0; opacity: 1.0 }
                },
                State {
                    name: "hidden"
                    when: !wifiPopup.visible
                    PropertyChanges { target: wifiAnimContainer; scale: 0.92; opacity: 0.0 }
                }
            ]

            transitions: [
                Transition {
                    from: "hidden"; to: "visible"
                    ParallelAnimation {
                        NumberAnimation { property: "scale"; duration: 220; easing.type: Easing.OutQuint }
                        NumberAnimation { property: "opacity"; duration: 180; easing.type: Easing.OutCubic }
                    }
                },
                Transition {
                    from: "visible"; to: "hidden"
                    ParallelAnimation {
                        NumberAnimation { property: "scale"; duration: 160; easing.type: Easing.InCubic }
                        NumberAnimation { property: "opacity"; duration: 150; easing.type: Easing.InCubic }
                    }
                }
            ]
        }
    }
}
