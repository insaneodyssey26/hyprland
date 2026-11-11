import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

Variants {
    model: Quickshell.screens

    delegate: Component {
        Item {
            id: edgeTriggers
            required property var modelData

            PanelWindow {
                id: leftTriggerWindow
                screen: edgeTriggers.modelData
                anchors {
                    top: true
                    bottom: true
                    left: true
                }
                implicitWidth: 2
                color: "transparent"
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                WlrLayershell.namespace: "aether-edge-left"
                exclusionMode: ExclusionMode.Ignore

                Process {
                    id: focusLeftProc
                    command: ["niri", "msg", "action", "focus-column-left"]
                }

                Timer {
                    id: cooldownTimerLeft
                    interval: 300
                    repeat: false
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        if (!cooldownTimerLeft.running) {
                            focusLeftProc.running = true
                            cooldownTimerLeft.start()
                        }
                    }
                }
            }

            PanelWindow {
                id: rightTriggerWindow
                screen: edgeTriggers.modelData
                anchors {
                    top: true
                    bottom: true
                    right: true
                }
                implicitWidth: 2
                color: "transparent"
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                WlrLayershell.namespace: "aether-edge-right"
                exclusionMode: ExclusionMode.Ignore

                Process {
                    id: focusRightProc
                    command: ["niri", "msg", "action", "focus-column-right"]
                }

                Timer {
                    id: cooldownTimerRight
                    interval: 300
                    repeat: false
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        if (!cooldownTimerRight.running) {
                            focusRightProc.running = true
                            cooldownTimerRight.start()
                        }
                    }
                }
            }
        }
    }
}
