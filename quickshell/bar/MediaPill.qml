import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import "../theme"
import "../services"

Rectangle {
    id: root
    implicitHeight: 28
    implicitWidth: mediaRow.implicitWidth + 16
    radius: 14
    color: (mediaHover.containsMouse || PopupManager.isPopupOpen("media")) ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
    visible: activePlayer !== null && activePlayer.trackTitle !== ""

    Behavior on color { ColorAnimation { duration: 150 } }

    property var activePlayer: {
        for (let key in Mpris.players.values) {
            let p = Mpris.players.values[key]
            if (p.playbackState === MprisPlaybackState.Playing) return p
        }
        return Mpris.players.values[0] || null
    }

    // Refresh position every 500ms when playing
    Timer {
        interval: 500
        running: activePlayer && activePlayer.playbackState === MprisPlaybackState.Playing
        repeat: true
        onTriggered: {
            if (activePlayer && activePlayer.positionSupported) {
                activePlayer.positionChanged()
            }
        }
    }

    function formatTime(sec) {
        if (!sec || isNaN(sec) || sec <= 0) return "0:00"
        let m = Math.floor(sec / 60)
        let s = Math.floor(sec % 60)
        return m + ":" + (s < 10 ? "0" + s : s)
    }

    RowLayout {
        id: mediaRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: (activePlayer && activePlayer.playbackState === MprisPlaybackState.Playing) ? "󰎆" : "󰏤"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 13
            color: Colors.colPrimary
        }

        Text {
            Layout.maximumWidth: 190
            elide: Text.ElideRight
            text: activePlayer ? (activePlayer.trackTitle || "") : ""
            font.family: "Geist"
            font.pixelSize: 12
            font.bold: true
            color: Colors.colText
        }
    }

    MouseArea {
        id: mediaHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: PopupManager.openPopup("media")
    }

    // MPRIS Enhanced Media Card Popup
    PopupWindow {
        id: mediaPopup
        anchor {
            item: root
            edges: Edges.Bottom
            gravity: Edges.Bottom
            margins.top: 8
        }
        implicitWidth: 320
        implicitHeight: progressSection.visible ? 215 : 185
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
                color: Qt.rgba(18/255, 18/255, 20/255, 0.98)
                border.color: Qt.rgba(1, 1, 1, 0.18)
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    // Art + Metadata Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 14

                        Rectangle {
                            Layout.preferredWidth: 54
                            Layout.preferredHeight: 54
                            radius: 12
                            color: Qt.rgba(1, 1, 1, 0.08)
                            border.color: Qt.rgba(1, 1, 1, 0.1)

                            Image {
                                anchors.fill: parent
                                anchors.margins: 2
                                fillMode: Image.PreserveAspectCrop
                                source: activePlayer ? (activePlayer.artUrl || "") : ""
                                visible: source != ""
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "󰎆"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 24
                                color: Colors.colPrimary
                                visible: !activePlayer || !activePlayer.artUrl
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                text: activePlayer ? (activePlayer.trackTitle || "No playback") : "No player detected"
                                font.family: "Geist"
                                font.pixelSize: 14
                                font.bold: true
                                color: Colors.colText
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
                                font.pixelSize: 12
                                color: Colors.colTextMuted
                            }

                            Text {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                text: activePlayer ? (activePlayer.trackAlbum || "") : ""
                                font.family: "Geist"
                                font.pixelSize: 11
                                color: Colors.colOutline
                                visible: text !== ""
                            }
                        }
                    }

                    // Progress Bar & Time Stamps
                    // Only show if the player actually supports reportable track length and length > 0
                    ColumnLayout {
                        id: progressSection
                        Layout.fillWidth: true
                        spacing: 4
                        visible: activePlayer && activePlayer.lengthSupported && activePlayer.length > 0

                        // Interactive Progress Track
                        Rectangle {
                            id: progressTrack
                            Layout.fillWidth: true
                            Layout.preferredHeight: 6
                            radius: 3
                            color: Qt.rgba(1, 1, 1, 0.12)

                            // Played progress bar with safe ratio check
                            Rectangle {
                                height: parent.height
                                radius: 3
                                color: Colors.colPrimary
                                width: {
                                    if (!activePlayer || !activePlayer.lengthSupported || activePlayer.length <= 0) return 0
                                    let curPos = activePlayer.position || 0
                                    let totalLen = activePlayer.length
                                    if (curPos >= totalLen) return 0 // Reset if song finished/switched
                                    let ratio = Math.max(0.0, Math.min(1.0, curPos / totalLen))
                                    return ratio * progressTrack.width
                                }
                            }

                            // Interactive Seek (only if canSeek is true)
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: (activePlayer && activePlayer.canSeek) ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: (mouse) => {
                                    if (activePlayer && activePlayer.canSeek && activePlayer.length > 0) {
                                        let targetPos = (mouse.x / progressTrack.width) * activePlayer.length
                                        activePlayer.position = targetPos
                                    }
                                }
                            }
                        }

                        // Timestamps row: position / total length
                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: activePlayer ? root.formatTime(activePlayer.position) : "0:00"
                                font.family: "Geist"
                                font.pixelSize: 10
                                color: Colors.colTextMuted
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: activePlayer ? root.formatTime(activePlayer.length) : "0:00"
                                font.family: "Geist"
                                font.pixelSize: 10
                                color: Colors.colTextMuted
                            }
                        }
                    }

                    // Playback Controls Row (Prev, Play/Pause, Next)
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 22

                        // Prev
                        Rectangle {
                            width: 34; height: 34; radius: 17
                            color: prevBtnMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.06)
                            Text {
                                anchors.centerIn: parent
                                text: "󰒮"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 16
                                color: Colors.colText
                            }
                            MouseArea {
                                id: prevBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (activePlayer && activePlayer.canGoPrevious) activePlayer.previous()
                            }
                        }

                        // Play/Pause Hero Button
                        Rectangle {
                            width: 44; height: 44; radius: 22
                            color: Colors.colPrimary
                            Text {
                                anchors.centerIn: parent
                                text: (activePlayer && activePlayer.playbackState === MprisPlaybackState.Playing) ? "󰏤" : "󰐊"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 18
                                color: Colors.colOnPrimary
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (activePlayer) activePlayer.togglePlaying()
                            }
                        }

                        // Next
                        Rectangle {
                            width: 34; height: 34; radius: 17
                            color: nextBtnMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.06)
                            Text {
                                anchors.centerIn: parent
                                text: "󰒭"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 16
                                color: Colors.colText
                            }
                            MouseArea {
                                id: nextBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (activePlayer && activePlayer.canGoNext) activePlayer.next()
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
                        NumberAnimation { property: "scale"; duration: 220; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
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
