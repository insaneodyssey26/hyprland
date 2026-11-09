import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"
import "../services"

QtObject {
    id: monitor

    property real cpuUsage: 0.0
    property real memUsage: 0.0
    property string memStr: "0 GB"
    property real tempC: 0.0
    property string diskUsageStr: "0%"
    property string diskDetailStr: "0G / 0G"
    property real diskUsagePct: 0.0
    property string uptimeStr: "up 0m"
    property string cpuModel: "AMD Ryzen 7 7435HS"
    property int coreCount: 16

    // GPU metrics (NVIDIA RTX 4050)
    property int gpuTemp: 0
    property int gpuUsage: 0
    property string gpuMemStr: "0G / 6G"
    property real gpuMemPct: 0.0
    property string gpuName: "GeForce RTX 4050"

    // Fan speed
    property int fanRpm: 0

    // Local IP address
    property string localIp: "127.0.0.1"

    // Store previous CPU tick counters
    property var lastCpuTicks: null

    // Lightweight sampling of kernel virtual files every 2s
    property Timer timer: Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statFile.reload()
            memFile.reload()
            tempFile.reload()

            // Heavy subprocesses only sampled when popup is active or on first start
            if (PopupManager.isPopupOpen("cpu") || monitor.uptimeStr === "up 0m") {
                diskProcess.running = true
                uptimeProcess.running = true
                gpuProcess.running = true
                fanProcess.running = true
                ipProcess.running = true
            }
        }
    }

    property FileView statFile: FileView {
        path: "/proc/stat"
        onLoaded: {
            let line = text().split("\n")[0]
            if (line && line.startsWith("cpu ")) {
                let parts = line.trim().split(/\s+/).slice(1).map(Number)
                let idle = parts[3] + (parts[4] || 0)
                let total = parts.reduce((a, b) => a + b, 0)

                if (monitor.lastCpuTicks) {
                    let diffIdle = idle - monitor.lastCpuTicks.idle
                    let diffTotal = total - monitor.lastCpuTicks.total
                    if (diffTotal > 0) {
                        monitor.cpuUsage = Math.max(0, Math.min(100, Math.round(((diffTotal - diffIdle) / diffTotal) * 100)))
                    }
                }
                monitor.lastCpuTicks = { idle: idle, total: total }
            }
        }
    }

    property FileView memFile: FileView {
        path: "/proc/meminfo"
        onLoaded: {
            let lines = text().split("\n")
            let total = 0
            let avail = 0
            for (let i = 0; i < lines.length; i++) {
                let l = lines[i]
                if (l.startsWith("MemTotal:")) total = parseInt(l.replace(/\D/g, ""))
                else if (l.startsWith("MemAvailable:")) avail = parseInt(l.replace(/\D/g, ""))
                if (total > 0 && avail > 0) break
            }
            if (total > 0) {
                let used = total - avail
                monitor.memUsage = Math.round((used / total) * 100)
                monitor.memStr = (used / (1024 * 1024)).toFixed(1) + "G / " + (total / (1024 * 1024)).toFixed(1) + "G"
            }
        }
    }

    property FileView tempFile: FileView {
        path: "/sys/class/thermal/thermal_zone0/temp"
        onLoaded: {
            let t = parseInt(text().trim())
            if (!isNaN(t)) {
                monitor.tempC = Math.round(t / 1000)
            }
        }
    }

    property Process diskProcess: Process {
        command: ["bash", "-c", "df -h / | awk 'NR==2 {print $3, $2, $5}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split(/\s+/)
                if (parts.length >= 3) {
                    monitor.diskDetailStr = parts[0] + " / " + parts[1]
                    monitor.diskUsageStr = parts[2]
                    monitor.diskUsagePct = parseFloat(parts[2].replace("%", "")) || 0
                }
            }
        }
    }

    property Process uptimeProcess: Process {
        command: ["uptime", "-p"]
        stdout: StdioCollector {
            onStreamFinished: {
                monitor.uptimeStr = text.trim()
            }
        }
    }

    property Process gpuProcess: Process {
        command: ["/home/masum/dotfiles/quickshell/scripts/gpu-stats.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split(",").map(s => s.trim())
                if (parts.length >= 4) {
                    monitor.gpuTemp = parseInt(parts[0]) || 0
                    monitor.gpuUsage = parseInt(parts[1]) || 0
                    let usedMb = parseFloat(parts[2]) || 0
                    let totalMb = parseFloat(parts[3]) || 6141
                    monitor.gpuMemPct = Math.round((usedMb / totalMb) * 100)
                    monitor.gpuMemStr = (usedMb / 1024).toFixed(1) + "G / " + (totalMb / 1024).toFixed(1) + "G"
                }
            }
        }
    }

    property Process fanProcess: Process {
        command: ["/home/masum/dotfiles/quickshell/scripts/fan-stats.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                monitor.fanRpm = parseInt(text.trim()) || 0
            }
        }
    }

    property Process ipProcess: Process {
        command: ["bash", "-c", "ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d/ -f1 | head -n1"]
        stdout: StdioCollector {
            onStreamFinished: {
                let ip = text.trim()
                if (ip.length > 0) {
                    monitor.localIp = ip
                }
            }
        }
    }
}
