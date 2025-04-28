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
                x:75 * scaleFactor
                y:260 * scaleFactor

                width: 92 * scaleFactor
                height: 70 * scaleFactor

                source: "../images/" + weatherData.currentConditionIconName + ".png"

                MouseArea {
                    id: mouseDetails
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    ColumnLayout {
                        NextForecastView {
                            id: nextForecastView
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

