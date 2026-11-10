import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    delegate: Component {
        PanelWindow {
            id: bottomCornersWindow

            anchors {
                bottom: true
                left: true
                right: true
            }
            implicitHeight: 14
            color: "transparent"

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.namespace: "aether-bottom-corners"
            exclusionMode: ExclusionMode.Ignore

            Shape {
                id: bottomLeftFillet
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                }
                width: 14
                height: 14

                ShapePath {
                    fillColor: "#000000"
                    strokeColor: "transparent"
                    startX: 0
                    startY: 14

                    PathLine { x: 14; y: 14 }
                    PathArc {
                        x: 0
                        y: 0
                        radiusX: 14
                        radiusY: 14
                        direction: PathArc.Clockwise
                    }
                    PathLine { x: 0; y: 14 }
                }
            }

            Shape {
                id: bottomRightFillet
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }
                width: 14
                height: 14

                ShapePath {
                    fillColor: "#000000"
                    strokeColor: "transparent"
                    startX: 14
                    startY: 14

                    PathLine { x: 0; y: 14 }
                    PathArc {
                        x: 14
                        y: 0
                        radiusX: 14
                        radiusY: 14
                        direction: PathArc.Counterclockwise
                    }
                    PathLine { x: 14; y: 14 }
                }
            }
        }
    }
}
