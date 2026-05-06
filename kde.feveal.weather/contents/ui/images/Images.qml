import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.components
import "../libweather"

Image {
    id: images

    //--- Settings
    readonly property int forecastFontSize: plasmoid.configuration.forecastFontSize * Kirigami.Units.devicePixelRatio
    readonly property int tempFontSize: plasmoid.configuration.tempFontSize * Kirigami.Units.devicePixelRatio

    //--- Layout
    Kirigami.Icon {
        id: currentForecastIcon

        Item {

            Image {
                x: 80 * scaleFactor
                y: 260 * scaleFactor
                z: 2

                width: 110 * scaleFactor
                height: 84 * scaleFactor

//                source: "../images/" + weatherData.currentConditionIconName + ".png"
                source: {
                    var icon = weatherData.currentConditionIconName
                    if (!icon || icon === "") icon = "undefined"
                        return "../images/" + icon + ".png"
                }

                MouseArea {
                    id: mouseDetails
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    ColumnLayout {
                        x: -100 * scaleFactor
                        y: 117 * scaleFactor
                        NextForecastView {
                            id: nextForecastView
                            // Escala inicial 1 (tamaño normal)
                            scale: 1
                            z: 10
                            // Estado inicial visible
                            state: ""
                        }
                    }

                    onClicked: {
                        nextForecastView.state == 'clicked' ? nextForecastView.state = "": nextForecastView.state = 'clicked';

                    }//onClicked
                }//MouseArea
            }//Image

        }//Item
    }//Kirigami.Icon
}//Image

