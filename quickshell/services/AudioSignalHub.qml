pragma Singleton
import QtQuick

QtObject {
    id: audioSignalHub

    signal volumeChanged()

    function notifyVolumeChanged() {
        volumeChanged()
    }
}
