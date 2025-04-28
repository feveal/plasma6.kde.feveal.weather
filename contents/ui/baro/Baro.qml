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

//---------------
                    property var angNeedle: 0
//                    property var rUnits: ruleUnits()

//---------------

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
            id: baroSupport;
            x: 260 * scaleFactor //370
            y: 85 * scaleFactor //136
            z: 2
            width: 19 * scaleFactor //30
            height: 66 * scaleFactor //105
            source: "soporte_aguja.png"
        }


        Image {
            id: ruler;
            x: 5 * scaleFactor //8
            y: 1 * scaleFactor //2
            z: 2
            width: root.baseWidth * scaleFactor
            height: root.baseHeight * scaleFactor

            function rulerImage (ruler) {
                var value = weatherData.data["Temperature Unit"]
                if (value == 6000) {
                    return "regla_K.png"
                }
                if (value == 6001) {
                    return "regla_C.png"
                }
                else { (value == 6002)
                    return "regla_F.png"
                }
            }
//    Component.onCompleted: {console.log (rulerImage (ruler))}
            smooth: true
            mipmap: true
            source: rulerImage (ruler)
        }


    Item {
        id: needleItem
        z: 4

        Image {
            id: needle;

            x: 166 * scaleFactor - (width / 2) // Posicion giro
            y: 112 * scaleFactor - height + 2

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

// Datos Plasma 5
// En Celsius -15.5 equivale a "-20º", -4.8 a "0º", 6 a "20º", 17 a "40º"
// el angulo es a partir de -15.5 sumandole 0,55 por cada grado entre -20º y 40º
// En Farenheight es -14.5 y el paso 0.304
//---------------
// Component.onCompleted: {console.log (">>>: " + angNeedle)}

                origin.x: needle.paintedWidth - (needle.paintedWidth / 6) // Punto de giro en la aguja
                origin.y: needle.paintedHeight - 2
                angle: ruleUnits (angNeedle)

            }
        }
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
                    interval: (300 / (weatherData.intWindSpeed() / 2) + 1)
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
        var tempUnit = weatherData.data["Temperature Unit"]
        var value = weatherData.currentTemp;
        // Verificar la unidad de temperatura actual y aplicar la regla correspondiente
        if (tempUnit === 6000) {
            // Kelvin
            return (-4.8 + value * 0.55);
        } else if (tempUnit === 6001) {
            // Celsius
//            console.log ("Celsius:  " + value);
            return (-4.8 + value * 0.5406);
        } else if (tempUnit === 6002) {
            // Fahrenheit
//            console.log ("Fahrenheit:  " + value);
            return (-14.5 + value * 0.304);
        } else {
            // Unidad de temperatura desconocida
//            console.log("Unidad de temperatura desconocida");
            return 0;
        }
    }

}
