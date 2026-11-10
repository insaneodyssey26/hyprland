import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../theme"

PanelWindow {
    id: drawerWindow

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "aether-notification-drawer"
    exclusionMode: ExclusionMode.Ignore

    // Window is visible when drawer is open OR while animating back out
    visible: NotificationManager.drawerOpen || drawerBody.x < (drawerWindow.width - 5)

    // Full-screen backdrop area: covers the screen to the left of the drawer.
    // Clicking anywhere in this area closes the drawer!
    MouseArea {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: drawerBody.left
        }
        hoverEnabled: false
        cursorShape: Qt.ArrowCursor
        onClicked: {
            NotificationManager.drawerOpen = false
        }
    }

    // Top margin transparent click-to-close area (above drawer)
    MouseArea {
        anchors {
            top: parent.top
            bottom: drawerBody.top
            left: drawerBody.left
            right: parent.right
        }
        hoverEnabled: false
        cursorShape: Qt.ArrowCursor
        onClicked: {
            NotificationManager.drawerOpen = false
        }
    }

    // Bottom margin transparent click-to-close area (below drawer)
    MouseArea {
        anchors {
            top: drawerBody.bottom
            bottom: parent.bottom
            left: drawerBody.left
            right: parent.right
        }
        hoverEnabled: false
        cursorShape: Qt.ArrowCursor
        onClicked: {
            NotificationManager.drawerOpen = false
        }
    }

    // Right margin transparent click-to-close area
    MouseArea {
        anchors {
            top: drawerBody.top
            bottom: drawerBody.bottom
            left: drawerBody.right
            right: parent.right
        }
        hoverEnabled: false
        cursorShape: Qt.ArrowCursor
        onClicked: {
            NotificationManager.drawerOpen = false
        }
    }

    // Sliding Drawer Glass Container
    Rectangle {
        id: drawerBody
        anchors {
            top: parent.top
            bottom: parent.bottom
            topMargin: 52
            bottomMargin: 14
        }
        width: 400
        radius: 20
        color: "#000000"
        border.color: "transparent"
        border.width: 0

        // Initialize strictly off-screen to the right (x: drawerWindow.width + 10)
        x: drawerWindow.width > 0 ? (NotificationManager.drawerOpen ? (drawerWindow.width - width - 14) : (drawerWindow.width + 20)) : 2000

        Behavior on x {
            NumberAnimation {
                duration: 280
                easing.type: NotificationManager.drawerOpen ? Easing.OutBack : Easing.InCubic
                easing.overshoot: 1.05
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            // Header: Title, Count Badge, DND toggle, Clear All
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                spacing: 8

                Text {
                    text: "Notifications"
                    font.family: "Geist"
                    font.pixelSize: 16
                    font.bold: true
                    color: Colors.colText
                }

                Rectangle {
                    visible: NotificationManager.count > 0
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 18
                    radius: 9
                    color: Colors.colPrimary
                    Text {
                        anchors.centerIn: parent
                        text: NotificationManager.count
                        font.family: "Geist"
                        font.pixelSize: 11
                        font.bold: true
                        color: Colors.colBackground
                    }
                }

                Item { Layout.fillWidth: true }

                // DND Toggle Button
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: NotificationManager.dndActive ? Qt.rgba(Colors.colError.r, Colors.colError.g, Colors.colError.b, 0.3) : (dndHover.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.06))
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: NotificationManager.dndActive ? "󰂛" : "󰂚"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 14
                        color: NotificationManager.dndActive ? Colors.colError : Colors.colText
                    }
                    MouseArea {
                        id: dndHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NotificationManager.toggleDnd()
                    }
                }

                // Clear All Button (Pill with icon and text for absolute clarity)
                Rectangle {
                    visible: NotificationManager.count > 0
                    implicitHeight: 32
                    implicitWidth: clearRow.implicitWidth + 18
                    radius: 16
                    color: clearHover.containsMouse ? Qt.rgba(Colors.colError.r, Colors.colError.g, Colors.colError.b, 0.28) : Qt.rgba(1, 1, 1, 0.08)
                    border.color: clearHover.containsMouse ? Colors.colError : Qt.rgba(1, 1, 1, 0.12)
                    border.width: 0
                    Behavior on color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        id: clearRow
                        anchors.centerIn: parent
                        spacing: 5
                        Text {
                            text: "󰅖"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 12
                            color: clearHover.containsMouse ? Colors.colError : Colors.colTextMuted
                        }
                        Text {
                            text: "Clear"
                            font.family: "Geist"
                            font.pixelSize: 11
                            font.bold: true
                            color: clearHover.containsMouse ? Colors.colError : Colors.colTextMuted
                        }
                    }

                    MouseArea {
                        id: clearHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NotificationManager.clearAll()
                    }
                }
            }

            // Divider line directly beneath the header
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(1, 1, 1, 0.08)
            }

            // Empty state placeholder (takes remaining height and centers content)
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: NotificationManager.count === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "󰂜"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 38
                        color: Qt.rgba(1, 1, 1, 0.2)
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No Notifications"
                        font.family: "Geist"
                        font.pixelSize: 13
                        font.bold: true
                        color: Qt.rgba(1, 1, 1, 0.4)
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "You're all caught up!"
                        font.family: "Geist"
                        font.pixelSize: 11
                        color: Qt.rgba(1, 1, 1, 0.25)
                    }
                }
            }

            // Notification History Scrollable List
            ScrollView {
                id: notiScroll
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: NotificationManager.count > 0
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ListView {
                    id: notiList
                    width: notiScroll.width
                    model: NotificationManager.server.trackedNotifications
                    spacing: 8

                    delegate: Rectangle {
                        id: card
                        required property var modelData

                        width: notiList.width
                        implicitHeight: col.implicitHeight + 20
                        radius: 12
                        color: Qt.rgba(1, 1, 1, 0.06)
                        border.color: "transparent"
                        border.width: 0

                        ColumnLayout {
                            id: col
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                                margins: 12
                            }
                            spacing: 5

                            // Top row: App Name + Timestamp + Big Easy-to-Click Dismiss button
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: card.modelData.appName || "System"
                                    font.family: "Geist"
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: Colors.colPrimary
                                    elide: Text.ElideRight
                                    Layout.maximumWidth: 160
                                }

                                Item { Layout.fillWidth: true }

                                // Dismiss single notification button
                                Rectangle {
                                    width: 26
                                    height: 26
                                    radius: 13
                                    color: closeSingleHover.containsMouse ? Qt.rgba(255/255, 60/255, 60/255, 0.25) : Qt.rgba(1, 1, 1, 0.08)
                                    border.color: closeSingleHover.containsMouse ? Colors.colError : "transparent"
                                    border.width: 0

                                    Behavior on color { ColorAnimation { duration: 120 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰅖"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 13
                                        color: closeSingleHover.containsMouse ? Colors.colError : Colors.colTextMuted
                                    }

                                    MouseArea {
                                        id: closeSingleHover
                                        anchors.fill: parent
                                        anchors.margins: -6
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: NotificationManager.dismissNoti(card.modelData)
                                    }
                                }
                            }

                            // Summary / Headline
                            Text {
                                Layout.fillWidth: true
                                text: card.modelData.summary || ""
                                font.family: "Geist"
                                font.pixelSize: 13
                                font.bold: true
                                color: Colors.colText
                                wrapMode: Text.Wrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }

                            // Body text
                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: card.modelData.body || ""
                                font.family: "Geist"
                                font.pixelSize: 13
                                lineHeight: 1.2
                                color: Colors.colTextMuted
                                wrapMode: Text.Wrap
                                maximumLineCount: 4
                                elide: Text.ElideRight
                            }

                            // Actions row if any
                            RowLayout {
                                Layout.fillWidth: true
                                visible: card.modelData.actions && card.modelData.actions.length > 0
                                spacing: 6

                                Repeater {
                                    model: card.modelData.actions || []
                                    delegate: Rectangle {
                                        required property var modelData
                                        implicitHeight: 24
                                        implicitWidth: actText.implicitWidth + 14
                                        radius: 6
                                        color: Qt.rgba(1, 1, 1, 0.1)

                                        Text {
                                            id: actText
                                            anchors.centerIn: parent
                                            text: modelData.text
                                            font.family: "Geist"
                                            font.pixelSize: 11
                                            color: Colors.colText
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: modelData.invoke()
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
}
