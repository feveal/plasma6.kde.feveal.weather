import QtQuick
import org.kde.plasma.components as PlasmaComponents3

PlasmaComponents3.Label {
    font.pointSize: -1
    font.pixelSize: 12  // Eliminado Screen.devicePixelRatio
    font.family: plasmoid.configuration.fontFamily || "sans-serif"
    font.bold: plasmoid.configuration.bold || false
    color: plasmoid.configuration.textColor || "white"
    style: plasmoid.configuration.showOutline ? Text.Outline : Text.Normal
    styleColor: plasmoid.configuration.showOutline ? (plasmoid.configuration.outlineColor || "black") : "transparent"
}
