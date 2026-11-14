import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../theme"

Rectangle {
    id: root
    visible: SystemTray.items.values.length > 0
    implicitHeight: 26
    implicitWidth: visible ? (trayRow.implicitWidth + 10) : 0
    radius: 13
    color: Qt.rgba(1, 1, 1, 0.10)
    border.color: Qt.rgba(1, 1, 1, 0.08)
    border.width: 1

    Behavior on implicitWidth {
        NumberAnimation { duration: 150 }
    }

    RowLayout {
        id: trayRow
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: SystemTray.items

            delegate: Rectangle {
                id: itemRect
                required property var modelData
                property var trayItem: modelData

                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                radius: 10
                color: (itemHover.containsMouse || menuAnchor.visible) ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                IconImage {
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    source: itemRect.trayItem ? (itemRect.trayItem.icon || "") : ""
                }

                QsMenuAnchor {
                    id: menuAnchor
                    anchor {
                        item: itemRect
                        edges: Edges.Bottom
                        gravity: Edges.Bottom
                    }
                    menu: itemRect.trayItem ? itemRect.trayItem.menu : null
                }

                MouseArea {
                    id: itemHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    onClicked: (mouse) => {
                        if (!itemRect.trayItem) return;
                        if (mouse.button === Qt.RightButton) {
                            if (itemRect.trayItem.hasMenu && menuAnchor.menu) {
                                menuAnchor.open();
                            } else {
                                itemRect.trayItem.secondaryActivate();
                            }
                        } else if (mouse.button === Qt.MiddleButton) {
                            itemRect.trayItem.secondaryActivate();
                        } else {
                            itemRect.trayItem.activate();
                        }
                    }

                    onWheel: (wheel) => {
                        if (itemRect.trayItem) {
                            itemRect.trayItem.scroll(wheel.angleDelta.y / 120, false);
                        }
                    }
                }
            }
        }
    }
}
