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

    // Target timestamp in seconds since epoch for timers, or start timestamp for stopwatch
    property real targetEpoch: 0
    property real startEpoch: 0

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

    Process {
        id: saveStateProc
    }

    function saveState() {
        let data = JSON.stringify({
            mode: timerService.mode,
            status: timerService.status,
            durationSec: timerService.durationSec,
            remainingSec: timerService.remainingSec,
            elapsedSec: timerService.elapsedSec,
            targetEpoch: timerService.targetEpoch,
            startEpoch: timerService.startEpoch
        });
        saveStateProc.command = ["bash", "-c", "echo '" + data + "' > /tmp/qs_timer.json"];
        saveStateProc.running = true;
    }

    // Restore state on launch
    FileView {
        id: stateFile
        path: "/tmp/qs_timer.json"
        onLoaded: {
            try {
                let txt = text().trim();
                if (!txt || txt === "") return;
                let s = JSON.parse(txt);
                if (s && s.mode && s.mode !== "stopped") {
                    let now = Date.now() / 1000;
                    timerService.mode = s.mode;
                    timerService.durationSec = s.durationSec || 0;

                    if (s.mode === "timer") {
                        if (s.status === "running") {
                            let rem = Math.round(s.targetEpoch - now);
                            if (rem <= 0) {
                                timerService.remainingSec = 0;
                                timerService.status = "finished";
                            } else {
                                timerService.remainingSec = rem;
                                timerService.targetEpoch = s.targetEpoch;
                                timerService.status = "running";
                            }
                        } else {
                            timerService.remainingSec = s.remainingSec || 0;
                            timerService.status = s.status || "paused";
                        }
                    } else if (s.mode === "stopwatch") {
                        if (s.status === "running") {
                            timerService.elapsedSec = Math.max(0, Math.round(now - s.startEpoch));
                            timerService.startEpoch = s.startEpoch;
                            timerService.status = "running";
                        } else {
                            timerService.elapsedSec = s.elapsedSec || 0;
                            timerService.status = s.status || "paused";
                        }
                    }
                }
            } catch (e) {}
        }
    }

    Timer {
        id: ticker
        interval: 1000
        repeat: true
        running: timerService.isRunning

        onTriggered: {
            let now = Date.now() / 1000;
            if (timerService.mode === "stopwatch") {
                timerService.elapsedSec = Math.max(0, Math.round(now - timerService.startEpoch));
            } else if (timerService.mode === "timer") {
                let rem = Math.round(timerService.targetEpoch - now);
                if (rem <= 0) {
                    timerService.remainingSec = 0;
                    timerService.status = "finished";
                    timerService.notifyFinished();
                    timerService.saveState();
                } else {
                    timerService.remainingSec = rem;
                }
            }
        }
    }

    Process {
        id: notifyProc
    }

    Process {
        id: soundProc
        command: ["paplay", "/usr/share/sounds/freedesktop/stereo/complete.oga"]
    }

    function notifyFinished() {
        let title = "Timer Finished"
        let msg = "Countdown of " + formatDuration(durationSec) + " has completed."
        notifyProc.command = ["notify-send", "-u", "critical", "-t", "8000", "-a", "Quickshell Timer", title, msg]
        notifyProc.running = true
        soundProc.running = true
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
        targetEpoch = (Date.now() / 1000) + seconds
        mode = "timer"
        status = "running"
        saveState()
    }

    function startStopwatch() {
        elapsedSec = 0
        startEpoch = Date.now() / 1000
        mode = "stopwatch"
        status = "running"
        saveState()
    }

    function togglePause() {
        let now = Date.now() / 1000
        if (status === "running") {
            status = "paused"
            saveState()
        } else if (status === "paused") {
            if (mode === "timer") {
                targetEpoch = now + remainingSec
            } else if (mode === "stopwatch") {
                startEpoch = now - elapsedSec
            }
            status = "running"
            saveState()
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
        targetEpoch = 0
        startEpoch = 0
        saveState()
    }

    function adjustTime(deltaSec) {
        let now = Date.now() / 1000
        if (mode === "timer") {
            let next = remainingSec + deltaSec
            remainingSec = Math.max(0, next)
            targetEpoch = now + remainingSec
            if (remainingSec === 0 && status === "running") {
                status = "finished"
                notifyFinished()
            }
            saveState()
        } else if (mode === "stopwatch") {
            let next = Math.max(0, elapsedSec + deltaSec)
            elapsedSec = next
            startEpoch = now - elapsedSec
            saveState()
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
