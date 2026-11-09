import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    implicitWidth: 320
    implicitHeight: 330
    radius: 18
    color: "#000000"
    border.color: "transparent"
    border.width: 0

    property date viewingDate: new Date()
    property date today: new Date()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        // Month & Navigation Header
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: Qt.formatDateTime(root.viewingDate, "MMMM yyyy")
                font.family: "Geist"
                font.pixelSize: 16
                font.bold: true
                color: Colors.colText
            }

            Item { Layout.fillWidth: true }

            // Prev month button
            Rectangle {
                width: 28; height: 28; radius: 14
                color: prevMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.05)
                Text {
                    anchors.centerIn: parent
                    text: "‹"
                    font.family: "Geist"
                    font.pixelSize: 18
                    font.bold: true
                    color: Colors.colText
                }
                MouseArea {
                    id: prevMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        let d = new Date(root.viewingDate)
                        d.setMonth(d.getMonth() - 1)
                        root.viewingDate = d
                    }
                }
            }

            // Next month button
            Rectangle {
                width: 28; height: 28; radius: 14
                color: nextMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.05)
                Text {
                    anchors.centerIn: parent
                    text: "›"
                    font.family: "Geist"
                    font.pixelSize: 18
                    font.bold: true
                    color: Colors.colText
                }
                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        let d = new Date(root.viewingDate)
                        d.setMonth(d.getMonth() + 1)
                        root.viewingDate = d
                    }
                }
            }
        }

        // Days of week header
        RowLayout {
            Layout.fillWidth: true
            spacing: 0
            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                Item {
                    Layout.fillWidth: true
                    height: 22
                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.family: "Geist"
                        font.pixelSize: 12
                        font.bold: true
                        color: Colors.colPrimary
                        opacity: 0.8
                    }
                }
            }
        }

        // Calendar Days Grid
        GridLayout {
            id: daysGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 7
            rowSpacing: 4
            columnSpacing: 0

            Repeater {
                model: 42 // 6 weeks * 7 days
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Calculate day number
                    property var dayInfo: {
                        let year = root.viewingDate.getFullYear()
                        let month = root.viewingDate.getMonth()
                        let firstDayIndex = new Date(year, month, 1).getDay()
                        // convert Sunday=0 to Monday=0
                        let startOffset = (firstDayIndex === 0 ? 6 : firstDayIndex - 1)
                        let daysInMonth = new Date(year, month + 1, 0).getDate()
                        let daysInPrevMonth = new Date(year, month, 0).getDate()

                        let dayNum = index - startOffset + 1
                        let isCurrentMonth = dayNum >= 1 && dayNum <= daysInMonth

                        if (dayNum < 1) {
                            return { num: daysInPrevMonth + dayNum, cur: false, isToday: false }
                        } else if (dayNum > daysInMonth) {
                            return { num: dayNum - daysInMonth, cur: false, isToday: false }
                        } else {
                            let isT = root.today.getFullYear() === year &&
                                      root.today.getMonth() === month &&
                                      root.today.getDate() === dayNum
                            return { num: dayNum, cur: true, isToday: isT }
                        }
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 28; height: 28
                        radius: 14
                        color: parent.dayInfo.isToday ? Colors.colPrimary : (dayMouse.containsMouse ? Qt.rgba(1,1,1,0.12) : "transparent")

                        Text {
                            anchors.centerIn: parent
                            text: parent.parent.dayInfo.num
                            font.family: "Geist"
                            font.pixelSize: 12
                            font.bold: parent.parent.dayInfo.isToday
                            color: parent.parent.dayInfo.isToday ? Colors.colOnPrimary : (parent.parent.dayInfo.cur ? Colors.colText : Colors.colOutline)
                            opacity: parent.parent.dayInfo.cur ? 1.0 : 0.4
                        }
                    }

                    MouseArea {
                        id: dayMouse
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
            }
        }
    }
}
