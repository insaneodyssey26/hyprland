import QtQuick
import Quickshell.Io

QtObject {
    id: netService

    property bool isConnected: false
    property string activeSsid: ""
    property int signalStrength: 75
    property string speedStr: "0 B/s"

    // Network speed tracking
    property real lastRxBytes: 0
    property real lastTxBytes: 0
    property real lastTime: 0

    // Poll wifi status every 4s
    property Timer pollTimer: Timer {
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: wifiCheckProcess.running = true
    }

    // Sample /proc/net/dev every 1s for accurate throughput calculation
    property Timer speedTimer: Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: devFile.reload()
    }

    property FileView devFile: FileView {
        path: "/proc/net/dev"
        onLoaded: {
            let lines = text().split("\n")
            let rx = 0
            let tx = 0
            for (let i = 2; i < lines.length; i++) {
                let l = lines[i].trim()
                if (!l || l.startsWith("lo:")) continue
                let parts = l.split(/\s+/)
                // parts[0] is interface:, parts[1] is rx_bytes, parts[9] is tx_bytes
                if (parts.length >= 10) {
                    let r = parseInt(parts[1]) || 0
                    let t = parseInt(parts[9]) || 0
                    rx += r
                    tx += t
                }
            }

            let now = Date.now()
            if (netService.lastTime > 0) {
                let sec = (now - netService.lastTime) / 1000
                if (sec > 0) {
                    let rxDelta = Math.max(0, rx - netService.lastRxBytes)
                    let txDelta = Math.max(0, tx - netService.lastTxBytes)
                    let totalBytesPerSec = (rxDelta + txDelta) / sec

                    if (totalBytesPerSec >= 1024 * 1024) {
                        netService.speedStr = (totalBytesPerSec / (1024 * 1024)).toFixed(1) + " MB/s"
                    } else if (totalBytesPerSec >= 1024) {
                        netService.speedStr = (totalBytesPerSec / 1024).toFixed(0) + " KB/s"
                    } else {
                        netService.speedStr = Math.round(totalBytesPerSec) + " B/s"
                    }
                }
            }
            netService.lastRxBytes = rx
            netService.lastTxBytes = tx
            netService.lastTime = now
        }
    }

    property Process wifiCheckProcess: Process {
        command: ["bash", "-c", "nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes:' | cut -d: -f2"]
        stdout: StdioCollector {
            onStreamFinished: {
                let ssid = text.trim()
                if (ssid.length > 0) {
                    netService.activeSsid = ssid
                    netService.isConnected = true
                } else {
                    netService.isConnected = false
                    netService.activeSsid = "Disconnected"
                    netService.speedStr = "Offline"
                }
            }
        }
    }
}
