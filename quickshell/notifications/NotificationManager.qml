pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

QtObject {
    id: notiService

    property bool drawerOpen: false
    property bool dndActive: false

    // ListModel specifically for active floating toast banners
    // Using ListModel allows true item insertions (insert(0, ...)) and removals
    // so existing notifications smoothly slide down (displaced transition) instead of blinking!
    property ListModel toastModel: ListModel {
        id: toastModel
    }

    // Count of tracked notifications in the system
    property int count: server.trackedNotifications.values.length

    function toggleDrawer() {
        drawerOpen = !drawerOpen
    }

    function toggleDnd() {
        dndActive = !dndActive
    }

    function clearAll() {
        let items = [...server.trackedNotifications.values]
        for (let i = 0; i < items.length; i++) {
            items[i].dismiss()
        }
        toastModel.clear()
    }

    function dismissNoti(item) {
        removeToastById(item.id)
        item.dismiss()
    }

    function removeToastById(id) {
        for (let i = 0; i < toastModel.count; i++) {
            if (toastModel.get(i).notiId === id) {
                toastModel.remove(i, 1)
                break
            }
        }
    }

    property NotificationServer server: NotificationServer {
        id: server
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: (notification) => {
            notification.tracked = true

            if (!notiService.dndActive) {
                // If a toast for this ID already exists, remove it first
                notiService.removeToastById(notification.id)

                // Smoothly insert the new notification at the TOP (index 0)
                // Existing cards remain mounted and get displaced downward!
                notiService.toastModel.insert(0, {
                    "notiId": notification.id,
                    "notiRef": notification
                })

                // Cap active on-screen toasts to 3
                if (notiService.toastModel.count > 3) {
                    notiService.toastModel.remove(notiService.toastModel.count - 1, 1)
                }
            }
        }
    }
}
