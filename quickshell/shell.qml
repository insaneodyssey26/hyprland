import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "bar"
import "theme"
import "notifications"
import "launcher"
import "services"

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: aetherBarContainer
                required property var modelData

                screen: modelData
                anchors {
                    top: true
                    left: true
                    right: true
                }
                implicitHeight: 51
                color: "transparent"

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                WlrLayershell.namespace: "aether-bar"
                WlrLayershell.exclusionMode: ExclusionMode.Normal
                WlrLayershell.exclusiveZone: 38

                Rectangle {
                    id: mainBar
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    height: 38
                    color: Qt.rgba(14/255, 14/255, 16/255, 0.96)

                    Item {
                        anchors.fill: parent
                        anchors.leftMargin: 18
                        anchors.rightMargin: 18

                        AetherWorkspaces {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        AetherClock {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        AetherStatus {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Shape {
                    id: leftFillet
                    anchors {
                        top: mainBar.bottom
                        left: parent.left
                    }
                    width: 13
                    height: 13

                    ShapePath {
                        fillColor: Qt.rgba(14/255, 14/255, 16/255, 0.96)
                        strokeColor: "transparent"
                        startX: 0
                        startY: 0

                        PathLine { x: 13; y: 0 }
                        PathArc {
                            x: 0
                            y: 13
                            radiusX: 13
                            radiusY: 13
                            direction: PathArc.Counterclockwise
                        }
                        PathLine { x: 0; y: 0 }
                    }
                }

                Shape {
                    id: rightFillet
                    anchors {
                        top: mainBar.bottom
                        right: parent.right
                    }
                    width: 13
                    height: 13

                    ShapePath {
                        fillColor: Qt.rgba(14/255, 14/255, 16/255, 0.96)
                        strokeColor: "transparent"
                        startX: 13
                        startY: 0

                        PathLine { x: 0; y: 0 }
                        PathArc {
                            x: 13
                            y: 13
                            radiusX: 13
                            radiusY: 13
                            direction: PathArc.Clockwise
                        }
                        PathLine { x: 13; y: 0 }
                    }
                }
            }
        }
    }

    NotificationDrawer {}
    NotificationBanners {}

    AppLauncher {
        id: mainLauncher
        Component.onCompleted: {
            PopupManager.launcherRef = mainLauncher
        }
    }

    IpcHandler {
        target: "launcher"
        function toggle() {
            mainLauncher.toggle()
        }
        function open() {
            mainLauncher.open()
        }
        function close() {
            mainLauncher.close()
        }
    }
}
