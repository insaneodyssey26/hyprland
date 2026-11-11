import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    delegate: Component {
        PanelWindow {
            id: cornersWindow
            required property var modelData

            screen: modelData
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            color: "transparent"

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.namespace: "aether-display-corners"
            exclusionMode: ExclusionMode.Ignore
            mask: Region {}

            readonly property real barH: 38
            readonly property real r: 14

            Shape {
                anchors {
                    top: parent.top
                    topMargin: cornersWindow.barH
                    left: parent.left
                }
                width: cornersWindow.r
                height: cornersWindow.r

                ShapePath {
                    fillColor: "#000000"
                    strokeColor: "transparent"
                    startX: 0
                    startY: 0

                    PathLine { x: cornersWindow.r; y: 0 }
                    PathArc {
                        x: 0
                        y: cornersWindow.r
                        radiusX: cornersWindow.r
                        radiusY: cornersWindow.r
                        direction: PathArc.Counterclockwise
                    }
                    PathLine { x: 0; y: 0 }
                }
            }

            Shape {
                anchors {
                    top: parent.top
                    topMargin: cornersWindow.barH
                    right: parent.right
                }
                width: cornersWindow.r
                height: cornersWindow.r

                ShapePath {
                    fillColor: "#000000"
                    strokeColor: "transparent"
                    startX: cornersWindow.r
                    startY: 0

                    PathLine { x: 0; y: 0 }
                    PathArc {
                        x: cornersWindow.r
                        y: cornersWindow.r
                        radiusX: cornersWindow.r
                        radiusY: cornersWindow.r
                        direction: PathArc.Clockwise
                    }
                    PathLine { x: cornersWindow.r; y: 0 }
                }
            }

            Shape {
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                }
                width: cornersWindow.r
                height: cornersWindow.r

                ShapePath {
                    fillColor: "#000000"
                    strokeColor: "transparent"
                    startX: 0
                    startY: cornersWindow.r

                    PathLine { x: cornersWindow.r; y: cornersWindow.r }
                    PathArc {
                        x: 0
                        y: 0
                        radiusX: cornersWindow.r
                        radiusY: cornersWindow.r
                        direction: PathArc.Clockwise
                    }
                    PathLine { x: 0; y: cornersWindow.r }
                }
            }

            Shape {
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }
                width: cornersWindow.r
                height: cornersWindow.r

                ShapePath {
                    fillColor: "#000000"
                    strokeColor: "transparent"
                    startX: cornersWindow.r
                    startY: cornersWindow.r

                    PathLine { x: 0; y: cornersWindow.r }
                    PathArc {
                        x: cornersWindow.r
                        y: 0
                        radiusX: cornersWindow.r
                        radiusY: cornersWindow.r
                        direction: PathArc.Counterclockwise
                    }
                    PathLine { x: cornersWindow.r; y: cornersWindow.r }
                }
            }
        }
    }
}
