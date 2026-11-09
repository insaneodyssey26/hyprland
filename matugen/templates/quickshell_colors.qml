pragma Singleton
import QtQuick

QtObject {
    id: colors
    readonly property color colBackground: "{{colors.surface.default.hex}}"
    readonly property color colSurface: "{{colors.surface.default.hex}}"
    readonly property color colSurfaceContainer: "{{colors.surface_container.default.hex}}"
    readonly property color colPrimary: "{{colors.primary.default.hex}}"
    readonly property color colOnPrimary: "{{colors.on_primary.default.hex}}"
    readonly property color colSecondary: "{{colors.secondary.default.hex}}"
    readonly property color colOnSecondary: "{{colors.on_secondary.default.hex}}"
    readonly property color colOutline: "{{colors.outline.default.hex}}"
    readonly property color colText: "{{colors.on_surface.default.hex}}"
    readonly property color colTextMuted: "{{colors.on_surface_variant.default.hex}}"
    readonly property color colError: "{{colors.error.default.hex}}"
    readonly property color colOnError: "{{colors.on_error.default.hex}}"
}
