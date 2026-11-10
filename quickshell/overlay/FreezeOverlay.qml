import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    property string imageSource: ""
    property bool isShown: false

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "aether-freeze"
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "#000000"
    visible: root.isShown

    Image {
        anchors.fill: parent
        source: root.imageSource ? "file://" + root.imageSource : ""
        fillMode: Image.Stretch
        cache: false
    }

    function freeze(path) {
        root.imageSource = path
        root.isShown = true
    }

    function unfreeze() {
        root.isShown = false
        root.imageSource = ""
    }
}
