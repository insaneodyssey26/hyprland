import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    implicitHeight: 28
    implicitWidth: textLabel.implicitWidth + 24
    radius: 14
    color: Qt.rgba(Colors.colSurface.r, Colors.colSurface.g, Colors.colSurface.b, 0.72)
    border.color: Qt.rgba(1, 1, 1, 0.08)
    border.width: 1

    property string currentTime: ""
    property string currentDate: ""

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            let now = new Date()
            root.currentTime = Qt.formatDateTime(now, "hh:mm:ss")
            root.currentDate = Qt.formatDateTime(now, "ddd, MMM dd")
        }
    }

    RowLayout {
        id: textLabel
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.currentTime
            font.family: "Geist"
            font.pixelSize: 13
            font.bold: true
            color: Colors.colText
        }

        Text {
            text: "•"
            font.pixelSize: 10
            color: Colors.colOutline
            opacity: 0.6
        }

        Text {
            text: root.currentDate
            font.family: "Geist"
            font.pixelSize: 12
            font.bold: false
            color: Colors.colTextMuted
        }
    }
}
