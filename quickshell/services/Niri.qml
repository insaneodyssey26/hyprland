pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: niri

    // List of active workspaces [{id, idx, is_active, is_focused, is_urgent}]
    property var workspaces: []
    property int activeWorkspaceIndex: 1
    property string activeWindowTitle: ""
    property string activeAppId: ""
    property var windowsList: []

    // Read initial workspaces
    Process {
        id: initProc
        command: ["niri", "msg", "--json", "workspaces"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    let parsed = JSON.parse(data);
                    if (Array.isArray(parsed)) {
                        parsed.sort((a, b) => a.idx - b.idx);
                        niri.workspaces = parsed;
                        for (let ws of parsed) {
                            if (ws.is_active || ws.is_focused) {
                                niri.activeWorkspaceIndex = ws.idx;
                            }
                        }
                    }
                } catch (e) {}
            }
        }
    }

    // Query focused window directly
    Process {
        id: focusedWindowProc
        command: ["niri", "msg", "--json", "focused-window"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    let w = JSON.parse(data);
                    if (w) {
                        niri.activeWindowTitle = w.title || "";
                        niri.activeAppId = w.app_id || "";
                    } else {
                        niri.activeWindowTitle = "";
                        niri.activeAppId = "";
                    }
                } catch (e) {
                    niri.activeWindowTitle = "";
                    niri.activeAppId = "";
                }
            }
        }
    }

    // Query all windows
    Process {
        id: windowsProc
        command: ["niri", "msg", "--json", "windows"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    let wins = JSON.parse(data);
                    if (Array.isArray(wins)) {
                        niri.windowsList = wins;
                    }
                } catch (e) {}
            }
        }
    }

    function refreshFocus() {
        focusedWindowProc.running = true;
    }

    // Periodic lightweight sync fallback (every 800ms) to guarantee 100% accurate window title & focus
    Timer {
        interval: 800
        running: true
        repeat: true
        onTriggered: {
            niri.refreshFocus();
        }
    }

    // Stream live events from Niri
    Process {
        id: eventStream
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                if (!line || line.trim() === "") return;
                try {
                    let ev = JSON.parse(line);
                    if (ev.WorkspacesChanged) {
                        let list = ev.WorkspacesChanged.workspaces || [];
                        list.sort((a, b) => a.idx - b.idx);
                        niri.workspaces = list;
                        for (let ws of list) {
                            if (ws.is_active || ws.is_focused) {
                                niri.activeWorkspaceIndex = ws.idx;
                            }
                        }
                        niri.refreshFocus();
                    } else if (ev.WorkspaceActivated) {
                        let targetId = ev.WorkspaceActivated.id;
                        for (let ws of niri.workspaces) {
                            if (ws.id === targetId) {
                                niri.activeWorkspaceIndex = ws.idx;
                                break;
                            }
                        }
                        niri.refreshFocus();
                    } else if (ev.WindowsChanged) {
                        let wins = ev.WindowsChanged.windows || [];
                        niri.windowsList = wins;
                        let focused = wins.find(w => w.is_focused);
                        if (focused) {
                            niri.activeWindowTitle = focused.title || "";
                            niri.activeAppId = focused.app_id || "";
                        } else {
                            niri.refreshFocus();
                        }
                    } else if (ev.WindowFocusChanged) {
                        let winId = ev.WindowFocusChanged.id;
                        if (!winId) {
                            niri.activeWindowTitle = "";
                            niri.activeAppId = "";
                        } else {
                            let win = niri.windowsList.find(w => w.id === winId);
                            if (win) {
                                niri.activeWindowTitle = win.title || "";
                                niri.activeAppId = win.app_id || "";
                            }
                            niri.refreshFocus();
                        }
                    }
                } catch (e) {}
            }
        }
    }

    function focusWorkspace(index) {
        Qt.createQmlObject('import Quickshell.Io; Process { command: ["niri", "msg", "action", "focus-workspace", "' + index + '"]; running: true }', niri);
    }
}
