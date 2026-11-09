import QtQuick
import QtQuick.Layouts
import "../theme"

RowLayout {
    id: root
    spacing: 8

    CpuTempPill {
        Layout.leftMargin: 2
    }

    Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 14
        color: Qt.rgba(1, 1, 1, 0.16)
    }

    VolumePill {}

    Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 14
        color: Qt.rgba(1, 1, 1, 0.16)
    }

    BatteryPill {}

    Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 14
        color: Qt.rgba(1, 1, 1, 0.16)
    }

    WifiPill {}

    Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 14
        color: Qt.rgba(1, 1, 1, 0.16)
    }

    RowLayout {
        spacing: 4
        KeyboardPill {}
        NotificationPill {}
        PowerPill {}
    }
}
