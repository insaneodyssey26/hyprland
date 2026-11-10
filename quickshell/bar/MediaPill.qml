import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import "../theme"
import "../services"

Rectangle {
    id: root
    implicitHeight: 28
    implicitWidth: mediaRow.implicitWidth + 16
    radius: 14
    color: (pillHoverArea.containsMouse || PopupManager.isPopupOpen("media")) ? Qt.rgba(1, 1, 1, 0.10) : "transparent"
    visible: activePlayer !== null && activePlayer.trackTitle !== ""

    Behavior on color { ColorAnimation { duration: 150 } }

    property var activePlayer: {
        for (let key in Mpris.players.values) {
            let p = Mpris.players.values[key]
            if (p.playbackState === MprisPlaybackState.Playing) return p
        }
        return Mpris.players.values[0] || null
    }

    Process {
        id: mediaCmdProc
    }

    RowLayout {
        id: mediaRow
        anchors.centerIn: parent
        spacing: 6

        Rectangle {
            width: 24
            height: 24
            radius: 12
            color: playIconMouse.containsMouse ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.22) : "transparent"

            Behavior on color { ColorAnimation { duration: 100 } }

            Text {
                anchors.centerIn: parent
                text: (activePlayer && activePlayer.playbackState === MprisPlaybackState.Playing) ? "󰎆" : "󰏤"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 14
                color: Colors.colPrimary
            }

            MouseArea {
                id: playIconMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (activePlayer) activePlayer.togglePlaying()
                }
            }
        }

        Item {
            id: titleContainer
            implicitWidth: Math.min(235, titleText.implicitWidth)
            implicitHeight: 22
            clip: true

            Text {
                id: titleText
                anchors.verticalCenter: parent.verticalCenter
                text: activePlayer ? (activePlayer.trackTitle || "") : ""
                font.family: "Geist"
                font.pixelSize: 13
                font.bold: true
                color: pillHoverArea.containsMouse ? Colors.colPrimary : Colors.colText

                Behavior on color { ColorAnimation { duration: 120 } }

                readonly property real overflowDist: Math.max(0, implicitWidth - titleContainer.width)
                x: 0

                SequentialAnimation on x {
                    id: marqueeAnim
                    running: titleText.overflowDist > 0 && pillHoverArea.containsMouse
                    loops: Animation.Infinite
                    PauseAnimation { duration: 600 }
                    NumberAnimation {
                        to: -titleText.overflowDist
                        duration: Math.max(1200, titleText.overflowDist * 28)
                        easing.type: Easing.Linear
                    }
                    PauseAnimation { duration: 1200 }
                    NumberAnimation {
                        to: 0
                        duration: Math.max(1200, titleText.overflowDist * 28)
                        easing.type: Easing.Linear
                    }
                    PauseAnimation { duration: 1000 }
                }

                states: State {
                    when: !pillHoverArea.containsMouse
                    PropertyChanges {
                        target: titleText
                        x: 0
                    }
                }

                transitions: Transition {
                    NumberAnimation {
                        property: "x"
                        to: 0
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
            }

            MouseArea {
                id: pillHoverArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: PopupManager.openPopup("media")
            }
        }
    }

    PopupWindow {
        id: mediaPopup
        anchor {
            item: root
            edges: Edges.Bottom
            gravity: Edges.Bottom
            margins.top: 8
        }
        implicitWidth: 320
        implicitHeight: mainCol.implicitHeight + 32
        visible: PopupManager.isPopupOpen("media")
        grabFocus: true
        onVisibleChanged: {
            if (!visible && PopupManager.activePopup === "media") {
                PopupManager.closeAll()
            }
        }
        color: "transparent"

        Item {
            id: mediaAnimContainer
            anchors.fill: parent
            scale: 0.92
            opacity: 0.0

            Rectangle {
                anchors.fill: parent
                radius: 18
                color: "#000000"
                border.color: "transparent"
                border.width: 0

                ColumnLayout {
                    id: mainCol
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 16

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Item {
                            Layout.fillWidth: true
                            implicitHeight: popupTitle.implicitHeight
                            clip: true

                            Text {
                                id: popupTitle
                                anchors.verticalCenter: parent.verticalCenter
                                text: activePlayer ? (activePlayer.trackTitle || "No playback") : "No player detected"
                                font.family: "Geist"
                                font.pixelSize: 16
                                font.bold: true
                                color: Colors.colText

                                readonly property real overflowDist: Math.max(0, implicitWidth - parent.width)
                                x: 0

                                SequentialAnimation on x {
                                    running: popupTitle.overflowDist > 0
                                    loops: Animation.Infinite
                                    PauseAnimation { duration: 2000 }
                                    NumberAnimation {
                                        to: -popupTitle.overflowDist
                                        duration: Math.max(1400, popupTitle.overflowDist * 28)
                                        easing.type: Easing.Linear
                                    }
                                    PauseAnimation { duration: 2400 }
                                    NumberAnimation {
                                        to: 0
                                        duration: 800
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            text: {
                                if (!activePlayer || !activePlayer.trackArtists) return "Unknown Artist"
                                if (Array.isArray(activePlayer.trackArtists)) return activePlayer.trackArtists.join(", ")
                                return activePlayer.trackArtists.toString()
                            }
                            font.family: "Geist"
                            font.pixelSize: 13
                            color: Colors.colPrimary
                        }

                        Text {
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            text: activePlayer ? (activePlayer.trackAlbum || "") : ""
                            font.family: "Geist"
                            font.pixelSize: 11
                            color: Colors.colTextMuted
                            visible: text !== ""
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Qt.rgba(1, 1, 1, 0.08)
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 20

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: popupPrevMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08)

                            Behavior on color { ColorAnimation { duration: 120 } }

                            Text {
                                anchors.centerIn: parent
                                text: "󰒮"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 16
                                color: Colors.colText
                            }
                            MouseArea {
                                id: popupPrevMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    mediaCmdProc.command = ["playerctl", "previous"]
                                    mediaCmdProc.running = true
                                }
                            }
                        }

                        Rectangle {
                            width: 48
                            height: 48
                            radius: 24
                            color: Colors.colPrimary

                            Behavior on opacity { NumberAnimation { duration: 120 } }
                            opacity: popupPlayMouse.containsMouse ? 0.9 : 1.0

                            Text {
                                anchors.centerIn: parent
                                text: (activePlayer && activePlayer.playbackState === MprisPlaybackState.Playing) ? "󰏤" : "󰐊"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 20
                                color: Colors.colOnPrimary
                            }

                            MouseArea {
                                id: popupPlayMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (activePlayer) activePlayer.togglePlaying()
                                }
                            }
                        }

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: popupNextMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08)

                            Behavior on color { ColorAnimation { duration: 120 } }

                            Text {
                                anchors.centerIn: parent
                                text: "󰒭"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 16
                                color: Colors.colText
                            }
                            MouseArea {
                                id: popupNextMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    mediaCmdProc.command = ["playerctl", "next"]
                                    mediaCmdProc.running = true
                                }
                            }
                        }
                    }
                }
            }

            states: [
                State {
                    name: "visible"
                    when: mediaPopup.visible
                    PropertyChanges { target: mediaAnimContainer; scale: 1.0; opacity: 1.0 }
                },
                State {
                    name: "hidden"
                    when: !mediaPopup.visible
                    PropertyChanges { target: mediaAnimContainer; scale: 0.92; opacity: 0.0 }
                }
            ]

            transitions: [
                Transition {
                    from: "hidden"; to: "visible"
                    ParallelAnimation {
                        NumberAnimation { property: "scale"; duration: 220; easing.type: Easing.OutQuint }
                        NumberAnimation { property: "opacity"; duration: 180; easing.type: Easing.OutCubic }
                    }
                },
                Transition {
                    from: "visible"; to: "hidden"
                    ParallelAnimation {
                        NumberAnimation { property: "scale"; duration: 160; easing.type: Easing.InCubic }
                        NumberAnimation { property: "opacity"; duration: 150; easing.type: Easing.InCubic }
                    }
                }
            ]
        }
    }
}
