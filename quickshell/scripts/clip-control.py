#!/usr/bin/env python3
import sys
import os
import json
import subprocess
import hashlib

THUMB_DIR = "/tmp/cliphist_thumbs"
PINS_FILE = os.path.expanduser("~/.local/share/cliphist_pins.json")

def load_pins():
    if os.path.exists(PINS_FILE):
        try:
            with open(PINS_FILE, "r") as f:
                return json.load(f)
        except Exception:
            return []
    return []

def save_pins(pins):
    os.makedirs(os.path.dirname(PINS_FILE), exist_ok=True)
    with open(PINS_FILE, "w") as f:
        json.dump(pins, f)

ACTION = sys.argv[1] if len(sys.argv) > 1 else "list"

if ACTION == "list":
    os.makedirs(THUMB_DIR, exist_ok=True)
    pins = load_pins()
    pin_hashes = {p.get("hash"): p for p in pins}
    
    try:
        raw = subprocess.check_output(["cliphist", "list"], stderr=subprocess.DEVNULL).decode("utf-8", errors="replace")
        items = []
        
        # Pinned items first
        for p in pins:
            items.append({
                "id": p.get("id", ""),
                "preview": p.get("preview", ""),
                "is_binary": p.get("is_binary", False),
                "image_path": p.get("image_path", ""),
                "full_text": p.get("full_text", ""),
                "pinned": True,
                "hash": p.get("hash", "")
            })

        count = 0
        for line in raw.splitlines():
            line = line.strip()
            if not line:
                continue
            parts = line.split("\t", 1)
            entry_id = parts[0].strip()
            preview = parts[1].strip() if len(parts) > 1 else ""
            is_binary = "[[ binary data" in preview
            
            h = hashlib.sha256(preview.encode("utf-8", errors="ignore")).hexdigest()
            if h in pin_hashes:
                continue

            image_path = ""
            full_text = ""
            
            if is_binary:
                thumb_file = os.path.join(THUMB_DIR, f"{entry_id}.png")
                if not os.path.exists(thumb_file):
                    try:
                        p = subprocess.Popen(["cliphist", "decode", entry_id], stdout=subprocess.PIPE)
                        data = p.stdout.read()
                        with open(thumb_file, "wb") as f:
                            f.write(data)
                    except Exception:
                        pass
                if os.path.exists(thumb_file):
                    image_path = thumb_file
            else:
                full_text = preview

            items.append({
                "id": entry_id,
                "preview": preview,
                "is_binary": is_binary,
                "image_path": image_path,
                "full_text": full_text,
                "pinned": False,
                "hash": h
            })
            count += 1
            if count >= 80:
                break
                
        print(json.dumps(items))
    except Exception as e:
        print("[]")

elif ACTION == "decode":
    if len(sys.argv) > 2:
        entry_id = sys.argv[2]
        proc = subprocess.Popen(["cliphist", "decode", entry_id], stdout=subprocess.PIPE)
        subprocess.run(["wl-copy"], stdin=proc.stdout)

elif ACTION == "copy_text":
    if len(sys.argv) > 2:
        text = sys.argv[2]
        proc = subprocess.Popen(["wl-copy"], stdin=subprocess.PIPE)
        proc.communicate(input=text.encode("utf-8"))

elif ACTION == "toggle_pin":
    if len(sys.argv) > 2:
        item_json = sys.argv[2]
        try:
            target = json.loads(item_json)
            h = target.get("hash") or hashlib.sha256(target.get("preview", "").encode()).hexdigest()
            pins = load_pins()
            
            existing = [p for p in pins if p.get("hash") == h]
            if existing:
                pins = [p for p in pins if p.get("hash") != h]
            else:
                target["pinned"] = True
                target["hash"] = h
                pins.insert(0, target)
            save_pins(pins)
        except Exception as e:
            pass

elif ACTION == "delete":
    if len(sys.argv) > 2:
        raw_line = sys.argv[2]
        # Remove from pins if pinned
        try:
            h = hashlib.sha256(raw_line.split("\t", 1)[-1].strip().encode()).hexdigest()
            pins = load_pins()
            pins = [p for p in pins if p.get("hash") != h]
            save_pins(pins)
        except Exception:
            pass
        # Ensure trailing newline for cliphist delete
        if not raw_line.endswith("\n"):
            raw_line += "\n"
        proc = subprocess.Popen(["cliphist", "delete"], stdin=subprocess.PIPE)
        proc.communicate(input=raw_line.encode("utf-8"))

elif ACTION == "wipe":
    subprocess.run(["cliphist", "wipe"])
    if os.path.exists(PINS_FILE):
        os.remove(PINS_FILE)
