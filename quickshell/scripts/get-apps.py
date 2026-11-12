#!/usr/bin/env python3
import os
import sys
import glob
import json
import configparser

def get_desktop_apps():
    search_dirs = [
        os.path.expanduser("~/.local/share/applications"),
        "/usr/local/share/applications",
        "/usr/share/applications"
    ]
    
    seen_ids = set()
    apps = []

    # Optional icon theme lookup via GTK
    has_gtk = False
    icon_theme = None
    try:
        import gi
        gi.require_version('Gtk', '3.0')
        from gi.repository import Gtk
        icon_theme = Gtk.IconTheme.get_default()
        has_gtk = True
    except Exception:
        has_gtk = False

    def resolve_icon(icon_name):
        if not icon_name:
            return ""
        if os.path.isabs(icon_name) and os.path.exists(icon_name):
            return icon_name
        if has_gtk and icon_theme:
            try:
                info = icon_theme.lookup_icon(icon_name, 48, 0)
                if info:
                    return info.get_filename() or ""
            except Exception:
                pass
        return ""

    for d in search_dirs:
        if not os.path.isdir(d):
            continue
        for path in glob.glob(os.path.join(d, "**/*.desktop"), recursive=True):
            app_id = os.path.basename(path)
            if app_id in seen_ids:
                continue

            cp = configparser.RawConfigParser(strict=False)
            try:
                cp.read(path, encoding='utf-8')
                if not cp.has_section('Desktop Entry'):
                    continue
                de = cp['Desktop Entry']

                if de.getboolean('NoDisplay', fallback=False):
                    continue
                if de.get('Type', 'Application') != 'Application':
                    continue

                name = de.get('Name', '').strip()
                exec_cmd = de.get('Exec', '').strip()
                if not name or not exec_cmd:
                    continue

                # Strip field codes like %u, %F, %U
                clean_exec = []
                for part in exec_cmd.split():
                    if part.startswith('%') and len(part) == 2:
                        continue
                    clean_exec.append(part)
                while clean_exec and clean_exec[-1] in ('--', '--url'):
                    clean_exec.pop()
                clean_exec_str = " ".join(clean_exec)

                icon_raw = de.get('Icon', '').strip()
                resolved_icon = resolve_icon(icon_raw)

                comment = de.get('Comment', '').strip()
                generic_name = de.get('GenericName', '').strip()
                categories = de.get('Categories', '').strip()

                apps.append({
                    "id": app_id,
                    "name": name,
                    "exec": clean_exec_str,
                    "icon": resolved_icon,
                    "comment": comment or generic_name,
                    "categories": categories
                })
                seen_ids.add(app_id)
            except Exception:
                continue

    apps.sort(key=lambda a: a["name"].lower())
    return apps

if __name__ == "__main__":
    apps = get_desktop_apps()
    print(json.dumps(apps))
