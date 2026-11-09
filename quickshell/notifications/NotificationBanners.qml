import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../theme"

PanelWindow {
    id: bannerWindow

    anchors {
        top: true
        right: true
    }
    implicitWidth: 460
    implicitHeight: 650
    color: "transparent"

    // Crucial: Overlay layer and Ignore exclusion mode ensures it overlays directly on top of windows
    // without altering Niri tiling geometries or moving active windows!
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "aether-notification-banners"
    exclusionMode: ExclusionMode.Ignore

    visible: NotificationManager.toastModel.count > 0 && !NotificationManager.drawerOpen

    ListView {
        id: toastListView
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 52
            rightMargin: 16
        }
        width: 420
        height: 560
        spacing: 10
        clip: false
        interactive: false

        model: NotificationManager.toastModel

        // 1. ADD TRANSITION: New incoming toast slides smoothly in from off-screen right (+440px -> 0)
        add: Transition {
            NumberAnimation {
                property: "x"
                from: 440
                to: 0
                duration: 320
                easing.type: Easing.OutBack
                easing.overshoot: 1.12
            }
            NumberAnimation {
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        // 2. DISPLACED TRANSITION: Existing cards smoothly shift down on the Y axis to make room
        displaced: Transition {
            NumberAnimation {
                properties: "y"
                duration: 260
                easing.type: Easing.OutCubic
            }
        }

        delegate: Item {
            id: cardWrapper
            required property var model
            required property int index

            property var noti: model.notiRef
            property bool isDismissing: false

            width: toastListView.width
            implicitHeight: popupCard.implicitHeight + 8

            function triggerDismiss() {
                if (isDismissing) return
                isDismissing = true
                dismissAnim.start()
            }

            // Smooth exit animation
            ParallelAnimation {
                id: dismissAnim
                NumberAnimation {
                    target: popupCard
                    property: "x"
                    to: 450
                    duration: 260
                    easing.type: Easing.InCubic
                }
                NumberAnimation {
                    target: popupCard
                    property: "opacity"
                    to: 0.0
                    duration: 220
                    easing.type: Easing.InCubic
                }
                onFinished: {
                    NotificationManager.removeToastById(cardWrapper.model.notiId)
                }
            }

            Rectangle {
                id: popupCard
                width: parent.width
                implicitHeight: bannerLayout.implicitHeight + 20
                radius: 16
                color: Qt.rgba(14/255, 14/255, 16/255, 0.98)
                // Border removed per user request: clean borderless dark glass surface
                border.width: 0

                // Auto-dismiss this specific notification after 5.5 seconds
                Timer {
                    interval: 5500
                    running: !cardWrapper.isDismissing
                    onTriggered: {
                        cardWrapper.triggerDismiss()
                    }
                }

                ColumnLayout {
                    id: bannerLayout
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        leftMargin: 16
                        rightMargin: 16
                        topMargin: 10
                    }
                    spacing: 0

                    // Top header row: App Icon, App Name (prominent & bigger), Dismiss Button
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "󱅫"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 16
                            color: Colors.colPrimary
                        }

                        Text {
                            text: (cardWrapper.noti && cardWrapper.noti.appName) ? cardWrapper.noti.appName : "Notification"
                            font.family: "Geist"
                            font.pixelSize: 14
                            font.bold: true
                            color: Colors.colPrimary
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        // Big, Easy-to-Click Dismiss Target (26px x 26px pill)
                        Rectangle {
                            id: dismissBtn
                            Layout.preferredWidth: 26
                            Layout.preferredHeight: 26
                            radius: 13
                            color: dismissHover.containsMouse ? Qt.rgba(Colors.colError.r, Colors.colError.g, Colors.colError.b, 0.25) : Qt.rgba(1, 1, 1, 0.08)

                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                font.family: "Geist"
                                font.pixelSize: 13
                                font.bold: true
                                color: dismissHover.containsMouse ? Colors.colError : Colors.colTextMuted
                            }

                            MouseArea {
                                id: dismissHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                preventStealing: true
                                onClicked: (mouse) => {
                                    mouse.accepted = true
                                    cardWrapper.triggerDismiss()
                                }
                            }
                        }
                    }

                    // Gap between Header and Summary (3px)
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 3
                    }

                    // Summary Title
                    Text {
                        Layout.fillWidth: true
                        text: (cardWrapper.noti && cardWrapper.noti.summary) ? cardWrapper.noti.summary : ""
                        font.family: "Geist"
                        font.pixelSize: 14
                        font.bold: true
                        color: Colors.colText
                        wrapMode: Text.Wrap
                    }

                    // Gap between title and body (2px)
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 2
                        visible: cardWrapper.noti && cardWrapper.noti.body !== ""
                    }

                    // Body
                    Text {
                        Layout.fillWidth: true
                        visible: cardWrapper.noti && cardWrapper.noti.body !== ""
                        text: (cardWrapper.noti && cardWrapper.noti.body) ? cardWrapper.noti.body : ""
                        font.family: "Geist"
                        font.pixelSize: 12
                        color: Colors.colTextMuted
                        wrapMode: Text.Wrap
                        maximumLineCount: 5
                        elide: Text.ElideRight
                    }
                }

                // Card click area: opens full drawer when clicking the body (not the dismiss button)
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    z: -1
                    onClicked: {
                        cardWrapper.triggerDismiss()
                        NotificationManager.drawerOpen = true
                    }
                }
            }
        }
    }
}
