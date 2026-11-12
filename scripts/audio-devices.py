#!/usr/bin/env python3
import subprocess, re, json

def get_audio_routes():
    try:
        proc_sinks = subprocess.run(["pactl", "list", "sinks"], capture_output=True, text=True, check=True)
        proc_sources = subprocess.run(["pactl", "list", "sources"], capture_output=True, text=True, check=True)
    except Exception:
        return {"sinks": [], "sources": []}

    sinks = []
    sources = []

    active_sink = None
    active_sink_port = None
    sink_ports = []
    in_sink_ports = False

    for line in proc_sinks.stdout.splitlines():
        line_str = line.strip()
        if line.startswith("Sink #"):
            active_sink = None
            active_sink_port = None
            sink_ports = []
        elif line_str.startswith("Name:"):
            active_sink = line_str.split(":", 1)[1].strip()
        elif line_str.startswith("Active Port:"):
            active_sink_port = line_str.split(":", 1)[1].strip()
        elif line_str == "Ports:":
            in_sink_ports = True
            continue
        elif in_sink_ports and (line_str == "Formats:" or (line.startswith("\t") and not line.startswith("\t\t"))):
            in_sink_ports = False
            for p_name, p_desc in sink_ports:
                icon = "󰕾"
                lower = p_name.lower()
                if "headphone" in lower or "headset" in lower:
                    icon = "󰋋"
                elif "speaker" in lower:
                    icon = "󰓃"
                elif "hdmi" in lower:
                    icon = "󰡁"
                sinks.append({
                    "target": active_sink,
                    "port": p_name,
                    "displayName": p_desc,
                    "active": (p_name == active_sink_port),
                    "icon": icon
                })
        elif in_sink_ports and (line_str.startswith("analog-") or line_str.startswith("hdmi-")):
            m = re.match(r"^([^:]+):\s+([^(]+)", line_str)
            if m:
                sink_ports.append((m.group(1).strip(), m.group(2).strip()))

    active_source = None
    active_source_port = None
    source_ports = []
    in_source_ports = False

    for line in proc_sources.stdout.splitlines():
        line_str = line.strip()
        if line.startswith("Source #"):
            active_source = None
            active_source_port = None
            source_ports = []
        elif line_str.startswith("Name:"):
            active_source = line_str.split(":", 1)[1].strip()
        elif line_str.startswith("Active Port:"):
            active_source_port = line_str.split(":", 1)[1].strip()
        elif line_str == "Ports:":
            in_source_ports = True
            continue
        elif in_source_ports and (line_str == "Formats:" or (line.startswith("\t") and not line.startswith("\t\t"))):
            in_source_ports = False
            if active_source and not active_source.endswith(".monitor"):
                for p_name, p_desc in source_ports:
                    icon = "󰍬"
                    if "headset" in p_name.lower():
                        icon = "󰋎"
                    sources.append({
                        "target": active_source,
                        "port": p_name,
                        "displayName": p_desc,
                        "active": (p_name == active_source_port),
                        "icon": icon
                    })
        elif in_source_ports and (line_str.startswith("analog-") or line_str.startswith("mic-")):
            m = re.match(r"^([^:]+):\s+([^(]+)", line_str)
            if m:
                source_ports.append((m.group(1).strip(), m.group(2).strip()))

    return {"sinks": sinks, "sources": sources}

if __name__ == "__main__":
    print(json.dumps(get_audio_routes()))
