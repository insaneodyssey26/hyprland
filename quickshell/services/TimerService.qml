pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: timerService

    // mode: "stopped" | "timer" | "stopwatch"
    property string mode: "stopped"
    // status: "stopped" | "running" | "paused" | "finished"
    property string status: "stopped"

    property int durationSec: 0
    property int remainingSec: 0
    property int elapsedSec: 0

    // Formatted strings
    readonly property string displayTime: {
        let total = (mode === "stopwatch") ? elapsedSec : remainingSec
        if (total < 0) total = 0
        let h = Math.floor(total / 3600)
        let m = Math.floor((total % 3600) / 60)
        let s = total % 60
        let pad = (n) => (n < 10 ? "0" + n : "" + n)
        if (h > 0) {
            return pad(h) + ":" + pad(m) + ":" + pad(s)
        }
        return pad(m) + ":" + pad(s)
    }

    readonly property bool isRunning: status === "running"
    readonly property bool isPaused: status === "paused"
    readonly property bool isFinished: status === "finished"
    readonly property bool isActive: mode !== "stopped"

    Timer {
        id: ticker
        interval: 1000
        repeat: true
        running: timerService.isRunning

        onTriggered: {
            if (timerService.mode === "stopwatch") {
                timerService.elapsedSec++
            } else if (timerService.mode === "timer") {
                if (timerService.remainingSec > 0) {
                    timerService.remainingSec--
                    if (timerService.remainingSec === 0) {
                        timerService.status = "finished"
                        timerService.notifyFinished()
                    }
                }
            }
        }
    }

    function notifyFinished() {
        let title = "Timer Finished"
        let msg = "Countdown of " + formatDuration(durationSec) + " has completed."
        Qt.createQmlObject('import Quickshell.Io; Process { command: ["notify-send", "-u", "critical", "-t", "8000", "-a", "Quickshell Timer", "' + title + '", "' + msg + '"]; running: true }', timerService)
        // Play system bell alert sound if available
        Qt.createQmlObject('import Quickshell.Io; Process { command: ["canberra-gtk-play", "-i", "alarm-clock-elapsed"]; running: true }', timerService)
    }

    function formatDuration(sec) {
        let m = Math.floor(sec / 60)
        let s = sec % 60
        if (m > 0 && s > 0) return m + "m " + s + "s"
        if (m > 0) return m + "m"
        return s + "s"
    }

    function startTimer(seconds) {
        if (seconds <= 0) return
        durationSec = seconds
        remainingSec = seconds
        mode = "timer"
        status = "running"
    }

    function startStopwatch() {
        elapsedSec = 0
        mode = "stopwatch"
        status = "running"
    }

    function togglePause() {
        if (status === "running") {
            status = "paused"
        } else if (status === "paused") {
            status = "running"
        } else if (status === "finished") {
            reset()
        }
    }

    function reset() {
        mode = "stopped"
        status = "stopped"
        durationSec = 0
        remainingSec = 0
        elapsedSec = 0
    }

    function adjustTime(deltaSec) {
        if (mode === "timer") {
            let next = remainingSec + deltaSec
            remainingSec = Math.max(0, next)
            if (remainingSec === 0 && status === "running") {
                status = "finished"
                notifyFinished()
            }
        } else if (mode === "stopwatch") {
            let next = elapsedSec + deltaSec
            elapsedSec = Math.max(0, next)
        }
    }

    function parseAndStart(inputStr) {
        let raw = inputStr.trim().toLowerCase().replace(/\s+/g, "")
        if (!raw) return false

        let total = 0
        let hMatch = raw.match(/(\d+)h/)
        let mMatch = raw.match(/(\d+)m/)
        let sMatch = raw.match(/(\d+)s/)

        if (hMatch) total += parseInt(hMatch[1]) * 3600
        if (mMatch) total += parseInt(mMatch[1]) * 60
        if (sMatch) total += parseInt(sMatch[1])

        // If purely digits, treat as minutes
        if (!hMatch && !mMatch && !sMatch && /^\d+$/.test(raw)) {
            total = parseInt(raw) * 60
        }

        if (total > 0) {
            startTimer(total)
            return true
        }
        return false
    }
}
