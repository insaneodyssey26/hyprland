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

        add: Transition {
            NumberAnimation {
                property: "x"
                from: 440
                to: 0
                duration: 320
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

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
                implicitHeight: bannerLayout.implicitHeight + 24
                radius: 16
                color: "#000000"
                border.color: "transparent"
                border.width: 0

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
                        leftMargin: 18
                        rightMargin: 18
                        topMargin: 14
                    }
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 4
                        spacing: 8

                        Text {
                            text: (cardWrapper.noti && cardWrapper.noti.appName) ? cardWrapper.noti.appName : "System"
                            font.family: "Geist"
                            font.pixelSize: 13
                            font.bold: true
                            color: Colors.colPrimary
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            id: dismissBtn
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            radius: 12
                            color: dismissHover.containsMouse ? Qt.rgba(Colors.colError.r, Colors.colError.g, Colors.colError.b, 0.25) : Qt.rgba(1, 1, 1, 0.08)

                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                font.family: "Geist"
                                font.pixelSize: 12
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

                    Text {
                        Layout.fillWidth: true
                        text: (cardWrapper.noti && cardWrapper.noti.summary) ? cardWrapper.noti.summary : ""
                        font.family: "Geist"
                        font.pixelSize: 15
                        font.bold: true
                        color: Colors.colText
                        wrapMode: Text.Wrap
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: cardWrapper.noti && cardWrapper.noti.body !== ""
                        text: (cardWrapper.noti && cardWrapper.noti.body) ? cardWrapper.noti.body : ""
                        font.family: "Geist"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        lineHeight: 1.3
                        color: Colors.colText
                        wrapMode: Text.Wrap
                        maximumLineCount: 6
                        elide: Text.ElideRight
                    }
                }

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
