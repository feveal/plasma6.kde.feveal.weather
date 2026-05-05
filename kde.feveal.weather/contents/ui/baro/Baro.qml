// Baro.qml
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import QtQuick.Controls 2.2 as QtControls
import "../libweather"

Item {
    id: baro
    anchors.fill: parent

    Image {
        id: needleShadow;
        fillMode: Image.PreserveAspectFit
        x: 172 * scaleFactor - (width / 2) // Posicion giro
        y: 122 * scaleFactor - height + 2

        width: 188 * scaleFactor // Ancho imagen
        height: 25 * scaleFactor
        smooth: true
        mipmap: true
        source: "sombra_aguja.png"

        transform: Rotation {
            id: needleShadowRotation

            property var angNeedle: 0

            origin.x: needleShadow.paintedWidth - (needleShadow.paintedWidth / 6) // Punto de giro en la aguja
            origin.y: needleShadow.paintedHeight - 2

            angle: ruleUnits (angNeedle)
        }
    } //Images

    Item {
        id: baroItem
        // Tamaño inicial

        readonly property var value: weatherData.currentTemp
        readonly property bool hasValue: !isNaN(value)

        property alias displayUnits: displayUnits
        DisplayUnits { id: displayUnits }
        anchors.fill: parent
        anchors.left: parent.left
        anchors.top: parent.top

        Image {
            id: backgroundShadow;
            fillMode: Image.PreserveAspectFit
            x:8 * root.scaleFactor
            y:8 * root.scaleFactor
            width: root.baseWidth * scaleFactor
            height: root.baseHeight * scaleFactor
            smooth: true
            mipmap: true
            source: "sombra_baro.png"
        }

        Image {
            id: background;
            fillMode: Image.PreserveAspectFit
            z: 1
            width: root.baseWidth * scaleFactor
            height: root.baseHeight * scaleFactor
            smooth: true
            mipmap: true
            source: "baro.png"
        }

        Image {
            id: ruler
            x: 5 * scaleFactor
            y: 1 * scaleFactor
            z: 2
            width: root.baseWidth * scaleFactor
            height: root.baseHeight * scaleFactor

            property string rulerSource: {
                var unitId = plasmoid.configuration.temperatureUnitId || 0
                if (unitId === 2) {  // Kelvin
                    return "regla_K.png"
                } else if (unitId === 0) {  // Celsius
                    return "regla_C.png"
                } else {  // Fahrenheit
                    return "regla_F.png"
                }
            }

            smooth: true
            mipmap: true
            source: rulerSource

            // Forzar actualización cuando cambie la unidad
            Connections {
                target: plasmoid.configuration
                function onTemperatureUnitIdChanged() {
                    // Forzar recarga de la imagen
                    var currentSource = ruler.rulerSource
                    ruler.source = ""
                    ruler.source = currentSource
//                    console.log("Ruler updated to:", currentSource)
                }
            }

            // Actualizar si la imagen falla al cargar
            onStatusChanged: {
                if (status === Image.Error) {
//                    console.log("Failed to load ruler image:", source)
                } else if (status === Image.Ready) {
//                    console.log("Ruler image loaded:", source)
                }
            }
        }

        Item {
            id: needleItem
            z: 4

            Image {
                id: needle;

                x: 166 * scaleFactor - (width / 2) // Posicion giro
                y: 113 * scaleFactor - height + 2

                width: 188 * scaleFactor // Ancho imagen
                height: 25 * scaleFactor

                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                source: "aguja.png"

                transform: Rotation {
                    id: needleRotation
                    //---------------
                    property var angNeedle: 0

                    // Component.onCompleted: {console.log (">>>: " + angNeedle)}

                    origin.x: needle.paintedWidth - (needle.paintedWidth / 6) // Punto de giro en la aguja
                    origin.y: needle.paintedHeight - 2
                    angle: ruleUnits (angNeedle)

                }
            }
        }

        Image {
            id: baroSupport;
            x: 229 * scaleFactor
            y: 83 * scaleFactor
            z: 5
            width: 20 * scaleFactor
            height: 68 * scaleFactor
            source: "soporte_aguja.png"
        }

        //----------- Mouse
        Image {
            id: animationImage
            x: 106 * scaleFactor
            y: 176 * scaleFactor
            z: 5
            width: 62 * scaleFactor
            height: 23 * scaleFactor
            source: "anemometro/ane-1.png"
            visible: true
            MouseArea {
                id: mouseAction
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    animationImage.visible = true;
                    animationTimer.running = !animationTimer.running;
                }
            }
            // Timer para cambiar las imágenes
            Timer {
                id: animationTimer
                interval: {
                    var rawSpeed = weatherData.currentWeather.windSpeedMps || 0
                    var unitId = plasmoid.configuration.windSpeedUnitId || 0  // 0=m/s, 1=km/h

                    var speed
                    if (unitId === 0) {
                        // m/s - factor original
                        speed = rawSpeed
                    } else {
                        // km/h - convertir y ajustar factor
                        speed = rawSpeed * 3.6  // Convertir a km/h

                        speed = speed / 3.6
                    }

                    if (speed <= 0) return 1000
                        return (300 / (speed / 2) + 1)
                }
                repeat: true
                running: true
                property int currentImageIndex: 1;
                onTriggered: {
                    currentImageIndex = (currentImageIndex % 8) + 1;
                    animationImage.source = "anemometro/ane-" + currentImageIndex + ".png";
//                    console.log (interval)
                }
            }
        }
    }

    function ruleUnits(angNeedle) {
        var unitId = plasmoid.configuration.temperatureUnitId || 0
        var celsius = weatherData.currentTemp

        if (unitId === 0) {
            // Celsius
            return (-4.8 + celsius * 0.5406)
        } else if (unitId === 1) {
            // Fahrenheit
            var fahrenheit = (celsius * 9/5) + 32
            return (-14.5 + fahrenheit * 0.304)
        } else if (unitId === 2) {
            return (-4.8 + celsius * 0.5406)
        } else {
            return 0
        }
    }

    function intWindSpeed() {
        return currentWeather.windSpeedMps || 0
    }

}
