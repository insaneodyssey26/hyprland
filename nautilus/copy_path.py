import subprocess
from urllib.parse import unquote, urlparse
from gi.repository import GObject, Nautilus

class CopyPathExtension(GObject.GObject, Nautilus.MenuProvider):
    def _copy_to_clipboard(self, text: str):
        try:
            subprocess.run(["wl-copy"], input=text.encode("utf-8"), check=True)
        except Exception:
            pass

    def _file_activate_cb(self, menu, files):
        paths = []
        for f in files:
            loc = f.get_location()
            if loc:
                paths.append(loc.get_path())
            else:
                uri = f.get_uri()
                parsed = urlparse(uri)
                paths.append(unquote(parsed.path) if parsed.scheme == "file" else uri)
        
        text = "\n".join(paths)
        self._copy_to_clipboard(text)

    def _folder_activate_cb(self, menu, folder):
        loc = folder.get_location()
        if loc:
            path = loc.get_path()
        else:
            uri = folder.get_uri()
            parsed = urlparse(uri)
            path = unquote(parsed.path) if parsed.scheme == "file" else uri
        self._copy_to_clipboard(path)

    def get_file_items(self, *args):
        files = args[-1]
        if not files:
            return []

        label = "Copy Path" if len(files) == 1 else "Copy Paths"
        tip = "Copy selected path(s) to clipboard"

        item = Nautilus.MenuItem(
            name="CopyPathExtension::CopyPath",
            label=label,
            tip=tip,
            icon="edit-copy-symbolic"
        )
        item.connect("activate", self._file_activate_cb, files)
        return [item]

    def get_background_items(self, *args):
        folder = args[-1]
        if not folder:
            return []

        item = Nautilus.MenuItem(
            name="CopyPathExtension::CopyFolderPath",
            label="Copy Folder Path",
            tip="Copy current folder path to clipboard",
            icon="edit-copy-symbolic"
        )
        item.connect("activate", self._folder_activate_cb, folder)
        return [item]
