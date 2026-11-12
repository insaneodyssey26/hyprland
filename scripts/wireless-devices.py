#!/usr/bin/env python3
import subprocess
import json
import sys

def get_wifi_state():
    radio_on = False
    try:
        r_out = subprocess.check_output(["nmcli", "radio", "wifi"], stderr=subprocess.DEVNULL).decode().strip()
        radio_on = (r_out == "enabled")
    except Exception:
        pass

    saved_conns = set()
    try:
        sc_out = subprocess.check_output(["nmcli", "-g", "NAME", "connection", "show"], stderr=subprocess.DEVNULL).decode()
        for c in sc_out.splitlines():
            c = c.strip()
            if c:
                saved_conns.add(c)
    except Exception:
        pass

    networks = []
    seen_ssids = set()
    active_ssid = ""
    try:
        out = subprocess.check_output(["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "dev", "wifi", "list", "--rescan", "no"], stderr=subprocess.DEVNULL).decode()
        for line in out.splitlines():
            line = line.strip()
            if not line:
                continue
            parts = line.split(":")
            if len(parts) >= 4:
                in_use = (parts[0] == "*")
                ssid = parts[1]
                if not ssid:
                    continue
                if in_use:
                    active_ssid = ssid
                if ssid in seen_ssids:
                    continue
                seen_ssids.add(ssid)
                signal = int(parts[2]) if parts[2].isdigit() else 50
                security = parts[3]
                networks.append({
                    "ssid": ssid,
                    "signal": signal,
                    "security": security,
                    "active": in_use,
                    "locked": bool(security and security != "--"),
                    "saved": (ssid in saved_conns)
                })
    except Exception:
        pass

    return {
        "radio": radio_on,
        "activeSsid": active_ssid,
        "networks": networks
    }

def get_bt_state():
    powered = False
    try:
        out = subprocess.check_output(["bluetoothctl", "show"], stderr=subprocess.DEVNULL).decode()
        for line in out.splitlines():
            line = line.strip()
            if line.startswith("Powered:"):
                powered = (line.split()[1] == "yes")
                break
    except Exception:
        pass

    devices = []
    try:
        out = subprocess.check_output(["bluetoothctl", "devices"], stderr=subprocess.DEVNULL).decode()
        for line in out.splitlines():
            parts = line.strip().split(maxsplit=2)
            if len(parts) >= 3 and parts[0] == "Device":
                mac = parts[1]
                name = parts[2]
                conn = False
                icon = "󰂯"
                try:
                    info_out = subprocess.check_output(["bluetoothctl", "info", mac], stderr=subprocess.DEVNULL).decode()
                    for il in info_out.splitlines():
                        il = il.strip()
                        if il.startswith("Connected:"):
                            conn = (il.split()[1] == "yes")
                        elif il.startswith("Icon:"):
                            ic_val = il.split()[1]
                            if "audio" in ic_val or "headset" in ic_val:
                                icon = "󰋋"
                            elif "mouse" in ic_val:
                                icon = "󰍽"
                            elif "keyboard" in ic_val:
                                icon = "󰌌"
                except Exception:
                    pass
                devices.append({
                    "mac": mac,
                    "name": name,
                    "connected": conn,
                    "icon": icon
                })
    except Exception:
        pass

    return {
        "powered": powered,
        "devices": devices
    }

def toggle_bluetooth(target):
    if target == "on":
        subprocess.run(["rfkill", "unblock", "bluetooth"], check=False)
        subprocess.run(["bluetoothctl", "power", "on"], check=False)
    else:
        subprocess.run(["bluetoothctl", "power", "off"], check=False)
        subprocess.run(["rfkill", "block", "bluetooth"], check=False)

def main():
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        if cmd == "toggle-bt":
            target = sys.argv[2] if len(sys.argv) > 2 else "on"
            toggle_bluetooth(target)
            return

    data = {
        "wifi": get_wifi_state(),
        "bt": get_bt_state()
    }
    print(json.dumps(data))

if __name__ == "__main__":
    main()
