import QtQuick
import Quickshell.Io

QtObject {
    id: appService

    property var allApps: []
    property bool isLoaded: false

    property Process appProc: Process {
        command: ["/home/masum/dotfiles/quickshell/scripts/get-apps.py"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let parsed = JSON.parse(text.trim())
                    appService.allApps = parsed
                    appService.isLoaded = true
                } catch (e) {
                    console.log("Error parsing apps JSON:", e)
                }
            }
        }
    }

    function refresh() {
        appProc.running = true
    }

    Component.onCompleted: {
        refresh()
    }
}
