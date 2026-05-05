import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami as Kirigami

Item {
    id: nextForecastView
/*
    anchors {
        left: parent ? parent.left : undefined
        top: parent ? parent.top : undefined
        leftMargin: -70 * scaleFactor
        topMargin: 98 * scaleFactor
    }
*/
    //	opacity: weatherData.hasData ? 1 : 0
/*
    states: [
        State {
            name: "clicked"
            PropertyChanges {
                target: nextForecastView
                scale: 0.01
                // Punto de ocultación
                anchors.leftMargin: -170 * scaleFactor // x
                anchors.topMargin: -200 * scaleFactor // y
            }
        }
    ]


    transitions: [
        Transition {
            from: "clicked"; to: "*"
            NumberAnimation { properties: "scale"; duration: 1000 } //InOutBack
            NumberAnimation { properties: "anchors.leftMargin, anchors.topMargin"; duration: 700 }

        },
        Transition {
            from: "*"; to: "clicked"
            NumberAnimation { properties: "scale"; duration: 1000 }
            NumberAnimation { properties: "anchors.leftMargin, anchors.topMargin"; duration: 700 }
        }
    ]
*/

states: [
    State {
        name: "clicked"
        PropertyChanges {
            target: nextForecastView
            scale: 0.01
            x: -200 * scaleFactor
            y: -260 * scaleFactor
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
