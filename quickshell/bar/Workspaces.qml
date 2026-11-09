import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services"

Item {
    id: root
    implicitHeight: 22
    implicitWidth: row.implicitWidth

    property real targetX: 0
    property real targetWidth: 20

    // Smooth sliding active capsule indicator
    Rectangle {
        id: indicator
        y: 1
        height: parent.height - 2
        radius: 10
        color: Colors.colPrimary

        x: root.targetX
        width: root.targetWidth

        Behavior on x {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }

        Behavior on width {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            model: Niri.workspaces.length > 0 ? Niri.workspaces : [{idx: 1, is_active: true}]

            Item {
                id: wsItem
                property bool isActive: modelData.idx === Niri.activeWorkspaceIndex
                property bool isOccupied: modelData.active_window_id !== null && modelData.active_window_id !== undefined

                Layout.preferredWidth: isActive ? 22 : 18
                Layout.preferredHeight: 20

                Behavior on Layout.preferredWidth {
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                }

                onIsActiveChanged: {
                    if (isActive) {
                        root.targetX = wsItem.x + row.x
                        root.targetWidth = wsItem.width
                    }
                }

                Component.onCompleted: {
                    if (isActive) {
                        root.targetX = wsItem.x + row.x
                        root.targetWidth = wsItem.width
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: modelData.idx
                    font.family: "Geist"
                    font.pixelSize: 11
                    font.bold: true
                    color: wsItem.isActive ? Colors.colOnPrimary : (wsItem.isOccupied ? Colors.colText : Colors.colTextMuted)
                    opacity: wsItem.isActive ? 1.0 : (wsItem.isOccupied ? 0.9 : 0.4)
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Niri.focusWorkspace(modelData.idx)
                }
            }
        }
    }
}
