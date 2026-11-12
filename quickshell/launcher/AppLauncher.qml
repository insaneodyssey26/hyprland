import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../theme"

PanelWindow {
    id: root

    property bool isOpen: false
    property string query: ""
    property int selectedIndex: 0

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "aether-launcher"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: root.isOpen || launcherCard.opacity > 0.0

    AppService {
        id: appService
    }

    property string calcResult: ""

    function evaluateMath(expr) {
        let clean = expr.trim()
        if (!/^[0-9\.\s\+\-\*\/\(\)\%\^\,a-zA-Z]+$/.test(clean) || !/[0-9]/.test(clean)) {
            return ""
        }
        if (!/[\+\-\*\/\%\^\(\)]/.test(clean) && !/(sqrt|sin|cos|tan|log|abs|pow|round|ceil|floor|pi|e)/i.test(clean)) {
            return ""
        }
        try {
            let sanitized = clean.replace(/\^/g, "**")
            // Support common math functions and constants without typing Math.
            sanitized = sanitized.replace(/\b(sin|cos|tan|asin|acos|atan|sqrt|cbrt|log|log2|log10|abs|round|floor|ceil|exp)\b/gi, "Math.$1")
            sanitized = sanitized.replace(/\b(pi)\b/gi, "Math.PI")
            sanitized = sanitized.replace(/\b(e)\b/gi, "Math.E")
            let fn = new Function("return (" + sanitized + ")")
            let val = fn()
            if (typeof val === "number" && !isNaN(val) && isFinite(val)) {
                return (Math.round(val * 100000000) / 100000000).toString()
            }
        } catch (e) {}
        return ""
    }

    property var filteredApps: {
        root.calcResult = evaluateMath(root.query)
        if (!appService.isLoaded) return []
        let q = root.query.trim().toLowerCase()
        if (q === "") return appService.allApps

        return appService.allApps.filter(app => {
            let name = (app.name || "").toLowerCase()
            let comm = (app.comment || "").toLowerCase()
            let exe = (app.exec || "").toLowerCase()
            return name.includes(q) || comm.includes(q) || exe.includes(q)
        })
    }

    onFilteredAppsChanged: {
        root.selectedIndex = 0
    }

    function open() {
        root.query = ""
        root.selectedIndex = 0
        root.isOpen = true
        searchInput.forceActiveFocus()
    }

    function close() {
        root.isOpen = false
        searchInput.focus = false
    }

    function toggle() {
        if (root.isOpen) {
            close()
        } else {
            open()
        }
    }

    function copyToClipboard(val) {
        copyProc.command = ["wl-copy", val]
        copyProc.running = true
        root.close()
    }

    Process {
        id: copyProc
    }

    function launchSelected() {
        if (root.calcResult !== "") {
            copyToClipboard(root.calcResult)
            return
        }
        if (root.filteredApps.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < root.filteredApps.length) {
            let app = root.filteredApps[root.selectedIndex]
            launchApp(app)
        }
    }

    function launchApp(app) {
        if (!app || !app.exec) return
        launchProc.command = ["bash", "-c", "nohup " + app.exec + " >/dev/null 2>&1 &"]
        launchProc.running = true
        root.close()
    }

    Process {
        id: launchProc
    }

    // Dim backdrop
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: "#000000"
        opacity: root.isOpen ? 0.45 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    Rectangle {
        id: launcherCard
        width: 540
        height: Math.min(480, Math.max(80, 72 + (root.calcResult !== "" ? 52 : 0) + root.filteredApps.length * 48))
        anchors.centerIn: parent
        radius: 16
        color: "#000000"
        border.color: "transparent"
        border.width: 0

        scale: root.isOpen ? 1.0 : 0.95
        opacity: root.isOpen ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation { duration: 220; easing.type: Easing.OutQuint }
        }
        Behavior on opacity {
            NumberAnimation { duration: 180 }
        }
        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.OutQuint }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                spacing: 10

                Text {
                    text: "󰍉"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 16
                    color: Colors.colPrimary
                    Layout.alignment: Qt.AlignVCenter
                }

                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    font.family: "Geist"
                    font.pixelSize: 14
                    font.bold: true
                    color: Colors.colText
                    clip: true

                    Text {
                        text: "Search apps..."
                        font.family: "Geist"
                        font.pixelSize: 14
                        font.bold: true
                        color: Colors.colTextMuted
                        opacity: 0.5
                        visible: !searchInput.text && !searchInput.inputMethodComposing
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    onTextChanged: {
                        root.query = text
                    }

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Escape) {
                            root.close()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down) {
                            if (root.filteredApps.length > 0) {
                                root.selectedIndex = (root.selectedIndex + 1) % root.filteredApps.length
                                resultsView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            if (root.filteredApps.length > 0) {
                                root.selectedIndex = (root.selectedIndex - 1 + root.filteredApps.length) % root.filteredApps.length
                                resultsView.positionViewAtIndex(root.selectedIndex, ListView.Contain)
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.launchSelected()
                            event.accepted = true
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(1, 1, 1, 0.08)
            }

            // Inline Math Calculation Result Banner
            Rectangle {
                id: calcBanner
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                radius: 10
                color: Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.16)
                visible: root.calcResult !== ""

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        radius: 6
                        color: Qt.rgba(1, 1, 1, 0.10)
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            anchors.centerIn: parent
                            text: "="
                            font.family: "Geist"
                            font.pixelSize: 15
                            font.bold: true
                            color: Colors.colPrimary
                        }
                    }

                    Text {
                        text: root.calcResult
                        font.family: "Geist"
                        font.pixelSize: 15
                        font.bold: true
                        color: "#ffffff"
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "Enter to copy"
                        font.family: "Geist"
                        font.pixelSize: 11
                        font.bold: true
                        color: Colors.colPrimary
                        opacity: 0.8
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.copyToClipboard(root.calcResult)
                }
            }

            ListView {
                id: resultsView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                model: root.filteredApps

                delegate: Rectangle {
                    id: delegateItem
                    width: resultsView.width
                    height: 44
                    radius: 10

                    property bool isSelected: index === root.selectedIndex

                    color: isSelected ? Qt.rgba(Colors.colPrimary.r, Colors.colPrimary.g, Colors.colPrimary.b, 0.16)
                                      : (itemHover.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")

                    Behavior on color { ColorAnimation { duration: 120 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 12

                        Item {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            Layout.alignment: Qt.AlignVCenter

                            Image {
                                anchors.centerIn: parent
                                width: 22
                                height: 22
                                sourceSize.width: 44
                                sourceSize.height: 44
                                source: modelData.icon ? ("file://" + modelData.icon) : ""
                                visible: status === Image.Ready
                                smooth: true
                                mipmap: true
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: !modelData.icon || parent.children[0].status !== Image.Ready
                                text: "󰀻"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 16
                                color: Colors.colPrimary
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.name
                            font.family: "Geist"
                            font.pixelSize: 13
                            font.bold: true
                            color: isSelected ? "#ffffff" : Colors.colText
                            elide: Text.ElideRight
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            text: modelData.comment || ""
                            font.family: "Geist"
                            font.pixelSize: 11
                            color: Colors.colTextMuted
                            opacity: 0.6
                            elide: Text.ElideRight
                            Layout.maximumWidth: 160
                            Layout.alignment: Qt.AlignVCenter
                            visible: text.length > 0
                        }
                    }

                    MouseArea {
                        id: itemHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: {
                            root.selectedIndex = index
                        }
                        onClicked: {
                            root.selectedIndex = index
                            root.launchApp(modelData)
                        }
                    }
                }
            }
        }
    }
}
