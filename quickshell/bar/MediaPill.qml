import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import "../theme"
import "../services"

Item {
    id: root
    implicitHeight: 26
    implicitWidth: mediaRow.implicitWidth
    visible: activePlayer !== null && activePlayer.trackTitle !== ""

    property var activePlayer: {
        for (let key in Mpris.players.values) {
            let p = Mpris.players.values[key]
            if (p.playbackState === MprisPlaybackState.Playing) return p
        }
        return Mpris.players.values[0] || null
    }

    property real currentPos: activePlayer ? (activePlayer.position || 0) : 0
    property real currentLen: activePlayer ? (activePlayer.length || 0) : 0
    property bool isDraggingSeek: false
    property real seekDragRatio: 0.0

    Timer {
        interval: 1000
        running: mediaPopup.visible && activePlayer !== null && activePlayer.playbackState === MprisPlaybackState.Playing && !root.isDraggingSeek
        repeat: true
        onTriggered: {
            if (activePlayer && activePlayer.position !== undefined) {
                root.currentPos = activePlayer.position
            }
        }
    }

    Connections {
        target: activePlayer
        function onPositionChanged() {
            if (!root.isDraggingSeek && activePlayer) {
                root.currentPos = activePlayer.position
            }
        }
        function onLengthChanged() {
            if (activePlayer) {
                root.currentLen = activePlayer.length
            }
        }
    }

    function formatTime(microSeconds) {
        if (!microSeconds || microSeconds <= 0 || isNaN(microSeconds)) return "0:00"
        let totalSec = Math.floor(microSeconds / 1000000)
        let mins = Math.floor(totalSec / 60)
        let secs = totalSec % 60
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }

    Process {
        id: mediaCmdProc
    }

    RowLayout {
        id: mediaRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

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
                color: titleHoverArea.containsMouse ? Colors.colPrimary : Colors.colText

                Behavior on color { ColorAnimation { duration: 120 } }

                readonly property real overflowDist: Math.max(0, implicitWidth - titleContainer.width)
                x: 0

                SequentialAnimation on x {
                    id: marqueeAnim
                    running: titleText.overflowDist > 0 && titleHoverArea.containsMouse
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
                    when: !titleHoverArea.containsMouse
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
                id: titleHoverArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: PopupManager.openPopup("media")
            }
        }

        Rectangle {
            id: visualizerPill
            property bool isPlaying: activePlayer !== null && activePlayer.playbackState === MprisPlaybackState.Playing
            visible: opacity > 0
            opacity: isPlaying ? 1.0 : 0.0
            implicitHeight: 26
            implicitWidth: isPlaying ? (visualizer.implicitWidth + 16) : 0
            radius: 13
            clip: true
            color: (vizHoverArea.containsMouse || PopupManager.isPopupOpen("media")) ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.10)
            border.color: Qt.rgba(1, 1, 1, 0.08)
            border.width: 1

            Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
            Behavior on implicitWidth { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 150 } }

            AudioVisualizer {
                id: visualizer
                anchors.centerIn: parent
                isPlaying: visualizerPill.isPlaying
                barColor: (vizHoverArea.containsMouse || PopupManager.isPopupOpen("media")) ? Colors.colPrimary : Colors.colSecondary
            }

            MouseArea {
                id: vizHoverArea
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
        implicitWidth: 340
        implicitHeight: mainCol.implicitHeight + 32
        visible: PopupManager.isPopupOpen("media")
        grabFocus: true
        onVisibleChanged: {
            if (!visible && PopupManager.activePopup === "media") {
                PopupManager.closeAll()
            }
            if (visible && activePlayer) {
                if (activePlayer.position !== undefined) root.currentPos = activePlayer.position
                if (activePlayer.length !== undefined) root.currentLen = activePlayer.length
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
                    spacing: 14

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            width: 26
                            height: 26
                            radius: 13
                            color: Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.14)

                            Text {
                                anchors.centerIn: parent
                                text: "󰎆"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 13
                                color: Colors.colPrimary
                            }
                        }

                        Text {
                            text: "NOW PLAYING"
                            font.family: "Geist"
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 1.2
                            color: Colors.colTextMuted
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            implicitWidth: playerBadgeText.implicitWidth + 14
                            implicitHeight: 20
                            radius: 10
                            color: Qt.rgba(1, 1, 1, 0.05)
                            border.color: Qt.rgba(1, 1, 1, 0.08)
                            border.width: 1

                            Text {
                                id: playerBadgeText
                                anchors.centerIn: parent
                                text: activePlayer ? (activePlayer.identity || "Media") : "Offline"
                                font.family: "Geist"
                                font.pixelSize: 10
                                font.bold: true
                                color: Colors.colTextMuted
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: heroRow.implicitHeight + 24
                        radius: 14
                        color: Qt.rgba(1, 1, 1, 0.04)
                        border.color: Qt.rgba(1, 1, 1, 0.06)
                        border.width: 1

                        RowLayout {
                            id: heroRow
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Rectangle {
                                width: 52
                                height: 52
                                radius: 10
                                color: Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.15)
                                border.color: Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.3)
                                border.width: 1
                                clip: true

                                Image {
                                    id: albumArtImg
                                    anchors.fill: parent
                                    source: (activePlayer && activePlayer.trackArtUrl) ? activePlayer.trackArtUrl : ""
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    visible: status === Image.Ready
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: albumArtImg.status !== Image.Ready
                                    text: "󰎆"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 24
                                    color: Colors.colPrimary
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 3

                                Item {
                                    Layout.fillWidth: true
                                    implicitHeight: popupTitle.implicitHeight
                                    clip: true

                                    Text {
                                        id: popupTitle
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: activePlayer ? (activePlayer.trackTitle || "No playback") : "No player detected"
                                        font.family: "Geist"
                                        font.pixelSize: 15
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
                                    font.pixelSize: 12
                                    color: Colors.colPrimary
                                }

                                Text {
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    text: activePlayer ? (activePlayer.trackAlbum || "") : ""
                                    font.family: "Geist"
                                    font.pixelSize: 10
                                    color: Colors.colTextMuted
                                    visible: text !== ""
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        visible: root.currentLen > 0

                        Item {
                            id: progressTrack
                            Layout.fillWidth: true
                            implicitHeight: 18

                            property real progressRatio: {
                                if (root.isDraggingSeek) return root.seekDragRatio
                                if (!root.currentLen || root.currentLen <= 0) return 0.0
                                return Math.min(1.0, Math.max(0.0, root.currentPos / root.currentLen))
                            }

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 5
                                radius: 2.5
                                color: Qt.rgba(1, 1, 1, 0.12)

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: parent.width * progressTrack.progressRatio
                                    radius: 2.5
                                    color: Colors.colPrimary
                                }
                            }

                            Rectangle {
                                width: 12
                                height: 12
                                radius: 6
                                color: Colors.colText
                                anchors.verticalCenter: parent.verticalCenter
                                x: Math.max(0, Math.min(progressTrack.width - width, (progressTrack.width * progressTrack.progressRatio) - (width / 2)))
                                visible: seekMouse.containsMouse || root.isDraggingSeek
                            }

                            MouseArea {
                                id: seekMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                function applySeek(mouseXVal) {
                                    let ratio = Math.max(0.0, Math.min(1.0, mouseXVal / width))
                                    root.seekDragRatio = ratio
                                    let targetUsec = ratio * root.currentLen
                                    root.currentPos = targetUsec
                                    let targetSec = Math.floor(targetUsec / 1000000)
                                    mediaCmdProc.command = ["playerctl", "position", targetSec.toString()]
                                    mediaCmdProc.running = true
                                }

                                onPressed: function(mouse) {
                                    root.isDraggingSeek = true
                                    applySeek(mouse.x)
                                }
                                onPositionChanged: function(mouse) {
                                    if (root.isDraggingSeek) {
                                        applySeek(mouse.x)
                                    }
                                }
                                onReleased: function(mouse) {
                                    if (root.isDraggingSeek) {
                                        applySeek(mouse.x)
                                        root.isDraggingSeek = false
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: root.formatTime(root.currentPos)
                                font.family: "Geist"
                                font.pixelSize: 10
                                color: Colors.colTextMuted
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: root.formatTime(root.currentLen)
                                font.family: "Geist"
                                font.pixelSize: 10
                                color: Colors.colTextMuted
                            }
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 16

                        Rectangle {
                            width: 38
                            height: 38
                            radius: 19
                            color: popupPrevMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.06)
                            border.color: Qt.rgba(1, 1, 1, 0.08)
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 120 } }

                            Text {
                                anchors.centerIn: parent
                                text: "󰒮"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 15
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
                            opacity: popupPlayMouse.containsMouse ? 0.88 : 1.0

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
                            width: 38
                            height: 38
                            radius: 19
                            color: popupNextMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.06)
                            border.color: Qt.rgba(1, 1, 1, 0.08)
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 120 } }

                            Text {
                                anchors.centerIn: parent
                                text: "󰒭"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 15
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
