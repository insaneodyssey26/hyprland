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
import "system"
import "clipboard"
import "emoji"
import "session"
import "wallpaper"
import "tasks"
import "projects"
import "finder"
import "osd"
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

    IpcHandler {
        target: "notifications"
        function toggle() {
            NotificationManager.toggleDrawer()
        }
        function open() {
            NotificationManager.drawerOpen = true
        }
        function close() {
            NotificationManager.drawerOpen = false
        }
    }

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

    SystemControls {
        id: sysControls
    }

    IpcHandler {
        target: "audio"
        function toggle(): void {
            PopupManager.openPopup("volume")
        }
        function open(): void {
            if (!PopupManager.isPopupOpen("volume")) {
                PopupManager.openPopup("volume")
            }
        }
        function close(): void {
            if (PopupManager.isPopupOpen("volume")) {
                PopupManager.closeAll()
            }
        }
    }

    IpcHandler {
        target: "controls"
        function toggle() {
            sysControls.toggle()
        }
        function open() {
            sysControls.open()
        }
        function close() {
            sysControls.close()
        }
    }

    ClipboardManager {
        id: clipManager
    }

    IpcHandler {
        target: "clipboard"
        function toggle() {
            clipManager.toggle()
        }
        function open() {
            clipManager.open()
        }
        function close() {
            clipManager.close()
        }
    }

    EmojiPicker {
        id: emojiPicker
    }

    IpcHandler {
        target: "emoji"
        function toggle() {
            emojiPicker.toggle()
        }
        function open() {
            emojiPicker.open()
        }
        function close() {
            emojiPicker.close()
        }
    }

    SessionMenu {
        id: sessionMenu
    }

    IpcHandler {
        target: "session"
        function toggle() {
            sessionMenu.toggle()
        }
        function open() {
            sessionMenu.open()
        }
        function close() {
            sessionMenu.close()
        }
    }

    WallpaperPicker {
        id: wallpaperPicker
    }

    IpcHandler {
        target: "wallpaper"
        function toggle() {
            wallpaperPicker.toggle()
        }
        function open() {
            wallpaperPicker.open()
        }
        function close() {
            wallpaperPicker.close()
        }
    }

    TaskKiller {
        id: taskKiller
    }

    IpcHandler {
        target: "tasks"
        function toggle() {
            taskKiller.toggle()
        }
        function open() {
            taskKiller.open()
        }
        function close() {
            taskKiller.close()
        }
    }

    ProjectLauncher {
        id: projectLauncher
    }

    IpcHandler {
        target: "projects"
        function toggle() {
            projectLauncher.toggle()
        }
        function open() {
            projectLauncher.open()
        }
        function close() {
            projectLauncher.close()
        }
    }

    FileFinder {
        id: fileFinder
    }

    IpcHandler {
        target: "finder"
        function toggle() {
            fileFinder.toggle()
        }
        function open() {
            fileFinder.open()
        }
        function close() {
            fileFinder.close()
        }
    }

    OsdOverlay {
        id: osdOverlay
    }

    IpcHandler {
        target: "osd"
        function volume() {
            osdOverlay.showVolume()
        }
        function brightness() {
            osdOverlay.showBrightness()
        }
        function mic() {
            osdOverlay.showMic()
        }
    }
}
