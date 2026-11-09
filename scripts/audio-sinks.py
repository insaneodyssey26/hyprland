#!/usr/bin/env python3
import subprocess, re, json

def clean_sink_name(name):
    # Simplify long ALSA/Pipewire node descriptions for clean display
    cleaned = name
    # Common replacements
    cleaned = re.sub(r"\bAnalog Stereo\b", "Speakers", cleaned, flags=re.IGNORECASE)
    cleaned = re.sub(r"\bDigital Stereo\b", "Digital Out", cleaned, flags=re.IGNORECASE)
    cleaned = re.sub(r"\bHigh Definition Audio Controller\b", "HD Audio", cleaned, flags=re.IGNORECASE)
    cleaned = re.sub(r"\bRyzen HD Audio Controller\b", "Realtek ALC256", cleaned, flags=re.IGNORECASE)
    cleaned = cleaned.strip()
    return cleaned if cleaned else name

def get_sinks():
    try:
        proc = subprocess.run(["wpctl", "status"], capture_output=True, text=True, check=True)
    except Exception:
        return []

    lines = proc.stdout.splitlines()
    sinks = []
    in_sinks = False

    for line in lines:
        if "Sinks:" in line:
            in_sinks = True
            continue
        if in_sinks:
            if any(k in line for k in ["Sources:", "Filters:", "Streams:", "Video", "Settings"]) or (line.strip() and not line.strip().startswith("│")):
                break
            
            m = re.search(r"│\s*(\*?)\s*(\d+)\.\s+(.*?)(?:\s+\[.*\])?$", line)
            if m:
                is_active = bool(m.group(1))
                sink_id = int(m.group(2))
                raw_name = m.group(3).strip()
                
                # Determine icon
                icon = "󰕾"
                lower_name = raw_name.lower()
                if "headphone" in lower_name or "headset" in lower_name:
                    icon = "󰋋"
                elif "hdmi" in lower_name or "displayport" in lower_name:
                    icon = "󰡁"
                elif "bluetooth" in lower_name or "bt" in lower_name:
                    icon = "󰂯"
                elif "speaker" in lower_name or "analog" in lower_name:
                    icon = "󰓃"

                sinks.append({
                    "id": sink_id,
                    "name": raw_name,
                    "displayName": clean_sink_name(raw_name),
                    "active": is_active,
                    "icon": icon
                })
    return sinks

if __name__ == "__main__":
    print(json.dumps(get_sinks()))
