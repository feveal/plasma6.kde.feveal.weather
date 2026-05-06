import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami as Kirigami

Item {
    id: nextForecastView

    states: [
        State {
            name: "clicked"
            PropertyChanges {
                target: nextForecastView
                scale: 0.01
                x: 155 * scaleFactor
                y: -100 * scaleFactor
                z: 1
            }
        }
    ]

    transitions: [
        Transition {
            from: "clicked"; to: "*"
            NumberAnimation { properties: "scale"; duration: 1000 }
            NumberAnimation { properties: "x,y"; duration: 700 }
        },
        Transition {
            from: "*"; to: "clicked"
            NumberAnimation { properties: "scale"; duration: 1000 }
            NumberAnimation { properties: "x,y"; duration: 700 }
        }
    ]

    //--- Layout
    Image {
        id: nextImages
        // Posición imágenes
        x:-10 * scaleFactor
        y:18 * scaleFactor // The position depends on Images, currentForecastIcon

        DailyForecastView {
            id: dailyForecastView
            model: weatherData.dailyForecastModel
        }
    }
}
