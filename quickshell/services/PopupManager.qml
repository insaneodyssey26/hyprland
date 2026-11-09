pragma Singleton
import QtQuick

QtObject {
    id: popupMgr

    // The name of the currently active popup:
    // e.g. "calendar", "cpu", "media", "volume", "wifi", "battery", "power", "launcher" or ""
    property string activePopup: ""

    property var launcherRef: null

    function toggleLauncher() {
        if (launcherRef) {
            launcherRef.toggle()
        }
    }

    function openPopup(name) {
        if (activePopup === name) {
            activePopup = ""
        } else {
            activePopup = name
        }
    }

    function closeAll() {
        activePopup = ""
    }

    function isPopupOpen(name) {
        return activePopup === name
    }
}
