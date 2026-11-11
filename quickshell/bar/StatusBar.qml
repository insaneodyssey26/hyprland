import QtQuick
import QtQuick.Layouts
import "../theme"

RowLayout {
    id: root
    spacing: 8

    Rectangle {
        Layout.alignment: Qt.AlignVCenter
        implicitHeight: 26
        implicitWidth: hardwareRow.implicitWidth + 14
        radius: 13
        color: Qt.rgba(1, 1, 1, 0.10)
        border.color: Qt.rgba(1, 1, 1, 0.08)
        border.width: 1

        RowLayout {
            id: hardwareRow
            anchors.centerIn: parent
            spacing: 2

            CpuTempPill {}

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 12
                color: Qt.rgba(1, 1, 1, 0.14)
            }

            VolumePill {}

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 12
                color: Qt.rgba(1, 1, 1, 0.14)
            }

            BatteryPill {}

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 12
                color: Qt.rgba(1, 1, 1, 0.14)
            }

            WifiPill {}
        }
    }

    Rectangle {
        Layout.alignment: Qt.AlignVCenter
        implicitHeight: 26
        implicitWidth: actionsRow.implicitWidth + 10
        radius: 13
        color: Qt.rgba(1, 1, 1, 0.10)
        border.color: Qt.rgba(1, 1, 1, 0.08)
        border.width: 1

        RowLayout {
            id: actionsRow
            anchors.centerIn: parent
            spacing: 2

            KeyboardPill {}
            NotificationPill {}
            PowerPill {}
        }
    }
}
