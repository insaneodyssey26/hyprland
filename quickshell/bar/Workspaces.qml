import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services"

RowLayout {
    id: root
    spacing: 8

    ActiveWindowPill {}

    Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 14
        color: Qt.rgba(1, 1, 1, 0.16)
    }

    RowLayout {
        id: wsRow
        spacing: 7

        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            propagateComposedEvents: true
            onWheel: (wheel) => {
                if (wheel.angleDelta.y > 0) {
                    Niri.focusWorkspaceDown()
                } else if (wheel.angleDelta.y < 0) {
                    Niri.focusWorkspaceUp()
                }
            }
        }

        Repeater {
            model: Niri.workspaces.length > 0 ? Niri.workspaces : [{idx: 1, is_active: true}]

            Rectangle {
                id: wsDot
                property bool isActive: modelData.idx === Niri.activeWorkspaceIndex
                property bool isOccupied: modelData.active_window_id !== null && modelData.active_window_id !== undefined

                Layout.preferredWidth: isActive ? 22 : (dotMouse.containsMouse ? 12 : (isOccupied ? 8 : 6))
                Layout.preferredHeight: 7
                radius: 3.5
                Layout.alignment: Qt.AlignVCenter

                Behavior on Layout.preferredWidth {
                    NumberAnimation { duration: 240; easing.type: Easing.OutQuint }
                }

                color: {
                    if (isActive) return "#ffffff"
                    if (dotMouse.containsMouse) return Qt.rgba(1, 1, 1, 0.75)
                    if (isOccupied) return Qt.rgba(Colors.colText.r, Colors.colText.g, Colors.colText.b, 0.55)
                    return Qt.rgba(1, 1, 1, 0.25)
                }

                Behavior on color {
                    ColorAnimation { duration: 180 }
                }

                MouseArea {
                    id: dotMouse
                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Niri.focusWorkspace(modelData.idx)
                }
            }
        }
    }

    Rectangle {
        visible: mediaPill.visible
        Layout.preferredWidth: 1
        Layout.preferredHeight: 14
        color: Qt.rgba(1, 1, 1, 0.16)
    }

    MediaPill {
        id: mediaPill
    }
}
