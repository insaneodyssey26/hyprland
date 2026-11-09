import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services"

Rectangle {
    id: root
    Layout.maximumWidth: 180
    implicitHeight: 24
    implicitWidth: Math.min(180, titleRow.implicitWidth + 8)
    radius: 12
    color: winHover.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

    Behavior on color { ColorAnimation { duration: 150 } }

    function getAppGlyph(appId, title) {
        let id = (appId || "").toLowerCase()
        let t = (title || "").toLowerCase()

        // Web Browsers
        if (id.includes("zen")) return "󰈹"
        if (id.includes("firefox")) return "󰈹"
        if (id.includes("chrome") || id.includes("chromium")) return "󰊯"
        if (id.includes("brave")) return "󰊯"

        // Terminals & System
        if (id.includes("kitty") || id.includes("foot") || id.includes("alacritty") || id.includes("ghostty") || id.includes("terminal")) return "󰞷"
        if (id.includes("btop") || id.includes("htop")) return "󰓅"

        // Code Editors & IDEs
        if (id.includes("zed")) return "󱚌"
        if (id.includes("code") || id.includes("vscodium")) return "󰨞"
        if (id.includes("jetbrains") || id.includes("idea") || id.includes("clion") || id.includes("pycharm") || id.includes("studio")) return "󰅩"
        if (id.includes("vim") || id.includes("neovim") || id.includes("nvim")) return ""

        // Chat & Social
        if (id.includes("discord") || id.includes("vesktop") || id.includes("webcord")) return "󰙯"
        if (id.includes("telegram")) return "󰀈"
        if (id.includes("slack")) return "󰒱"

        // File Management
        if (id.includes("nautilus") || id.includes("thunar") || id.includes("dolphin") || id.includes("files") || id.includes("yazi")) return "󰝰"

        // Media & Graphics
        if (id.includes("spotify")) return "󰓇"
        if (id.includes("mpv") || id.includes("vlc")) return "󰕼"
        if (id.includes("loupe") || id.includes("imv") || id.includes("satty") || id.includes("image")) return "󰋩"
        if (id.includes("gimp") || id.includes("inkscape") || id.includes("krita")) return "󰽉"
        if (id.includes("obs")) return "󰑋"

        // Office, Notes & Tools
        if (id.includes("rnote")) return "󰠮"
        if (id.includes("onlyoffice") || id.includes("libreoffice") || id.includes("word") || id.includes("writer")) return "󰧮"
        if (id.includes("calculator")) return "󰃬"
        if (id.includes("qbittorrent") || id.includes("torrent")) return "󰇚"
        if (id.includes("bluetooth") || id.includes("blueman")) return "󰂯"
        if (id.includes("settings") || id.includes("pavucontrol") || id.includes("control")) return "󰒓"
        if (id.includes("scrcpy")) return "󰄡"
        if (id.includes("kdeconnect")) return "󰄡"

        return "󰣇"
    }

    function getCleanAppName(appId, title) {
        if (!appId && !title) return "Desktop"
        let id = (appId || "").toLowerCase()
        let t = (title || "").toLowerCase()

        // Browsers
        if (id.includes("zen")) return "Zen Browser"
        if (id.includes("firefox")) return "Firefox"
        if (id.includes("chrome")) return "Google Chrome"
        if (id.includes("chromium")) return "Chromium"
        if (id.includes("brave")) return "Brave"

        // Terminals
        if (id.includes("kitty")) return "Kitty"
        if (id.includes("ghostty")) return "Ghostty"
        if (id.includes("alacritty")) return "Alacritty"
        if (id.includes("foot")) return "Foot"

        // Editors & Dev Tools
        if (id.includes("zed")) return "Zed"
        if (id.includes("code")) return "VS Code"
        if (id.includes("vscodium")) return "VSCodium"
        if (id.includes("rnote")) return "Rnote"
        if (id.includes("vim") || id.includes("nvim")) return "Neovim"
        if (id.includes("jetbrains-toolbox")) return "JetBrains"

        // Files & Media
        if (id.includes("nautilus") || id.includes("files")) return "Files"
        if (id.includes("thunar")) return "Thunar"
        if (id.includes("dolphin")) return "Dolphin"
        if (id.includes("yazi")) return "Yazi"
        if (id.includes("spotify")) return "Spotify"
        if (id.includes("mpv")) return "MPV"
        if (id.includes("vlc")) return "VLC"
        if (id.includes("loupe")) return "Image Viewer"
        if (id.includes("satty")) return "Satty"

        // Communication & Office
        if (id.includes("discord")) return "Discord"
        if (id.includes("vesktop")) return "Vesktop"
        if (id.includes("telegram")) return "Telegram"
        if (id.includes("onlyoffice")) return "ONLYOFFICE"
        if (id.includes("calculator")) return "Calculator"
        if (id.includes("qbittorrent")) return "qBittorrent"
        if (id.includes("pavucontrol")) return "Volume Control"
        if (id.includes("blueman")) return "Bluetooth"
        if (id.includes("scrcpy")) return "Scrcpy"
        if (id.includes("obs")) return "OBS Studio"
        if (id.includes("gimp")) return "GIMP"
        if (id.includes("btop")) return "btop++"

        // Fallback: Clean up appId (e.g. "org.gnome.Nautilus" -> "Nautilus", "dev.zed.Zed" -> "Zed")
        if (appId) {
            let parts = appId.split('.')
            let name = parts[parts.length - 1]
            if (name && name.length > 0) {
                return name.charAt(0).toUpperCase() + name.slice(1)
            }
        }

        return title || "Desktop"
    }

    RowLayout {
        id: titleRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.getAppGlyph(Niri.activeAppId, Niri.activeWindowTitle)
            font.family: "Symbols Nerd Font"
            font.pixelSize: 13
            color: Colors.colPrimary
        }

        Text {
            Layout.maximumWidth: 150
            elide: Text.ElideRight
            text: root.getCleanAppName(Niri.activeAppId, Niri.activeWindowTitle)
            font.family: "Geist"
            font.pixelSize: 12
            font.bold: true
            color: Colors.colText
        }
    }

    MouseArea {
        id: winHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            // Clicking the active window indicator opens fuzzel app launcher
            Qt.createQmlObject('import Quickshell.Io; Process { command: ["fuzzel"]; running: true }', root)
        }
    }
}
