pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: weatherService

    property string temp: "--°C"
    property string icon: "󰖐"
    property string condition: "Loading..."
    property bool isLoaded: false

    Process {
        id: weatherProc
        command: ["bash", "-c", "curl -s --connect-timeout 3 'wttr.in/Kolkata?format=%c+%t' || echo ''"]
        stdout: StdioCollector {
            onStreamFinished: {
                let out = text.trim()
                if (out && out.length > 0) {
                    let parts = out.split(/\s+/)
                    if (parts.length >= 2) {
                        let sym = parts[0]
                        let t = parts[1]
                        weatherService.temp = t.replace("+", "")
                        
                        // Clean Nerd Font weather glyph mapping
                        if (sym.includes("☀️") || sym.includes("🌞")) weatherService.icon = "󰖙"
                        else if (sym.includes("✨") || sym.includes("Clear")) weatherService.icon = "󰖔"
                        else if (sym.includes("⛅") || sym.includes("Partly")) weatherService.icon = "󰖕"
                        else if (sym.includes("☁️") || sym.includes("Overcast")) weatherService.icon = "󰖐"
                        else if (sym.includes("🌧") || sym.includes("Rain")) weatherService.icon = "󰖗"
                        else if (sym.includes("⛈") || sym.includes("Thunder")) weatherService.icon = "󰙾"
                        else if (sym.includes("❄️") || sym.includes("Snow")) weatherService.icon = "󰖘"
                        else if (sym.includes("🌫") || sym.includes("Fog") || sym.includes("Mist")) weatherService.icon = "󰖑"
                        else weatherService.icon = "󰖔"

                        weatherService.isLoaded = true
                    }
                }
            }
        }
    }

    // Refresh every 30 minutes (extremely lightweight, near zero bandwidth/battery)
    Timer {
        interval: 1800000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            weatherProc.running = true
        }
    }

    function refresh() {
        weatherProc.running = true
    }
}
