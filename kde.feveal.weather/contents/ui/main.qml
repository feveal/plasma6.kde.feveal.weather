// main.qml

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents3
import QtQuick.Controls
import "baro"
import "moon"
import "libweather" as LibWeather

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    readonly property int baseWidth: 300
    readonly property int baseHeight: 300
    property int savedWidth: plasmoid.configuration.customWidth || baseWidth
    property int savedHeight: plasmoid.configuration.customHeight || baseHeight
    property double scaleFactor: Math.min(width / baseWidth, height / baseHeight)

    width: savedWidth
    height: savedHeight

    onWidthChanged: {
        if (width !== savedWidth && width > 0) {
            plasmoid.configuration.customWidth = width
            plasmoid.configuration.write();
        }
    }

    onHeightChanged: {
        if (height !== savedHeight && height > 0) {
            plasmoid.configuration.customHeight = height
            plasmoid.configuration.write();
        }
    }

    fullRepresentation: Item {
        id: parentContainer
        anchors.fill: parent
        Layout.preferredWidth: plasmoid.configuration.customWidth
        Layout.preferredHeight: plasmoid.configuration.customHeight

        Baro {
            id: baro;
            z: 1
        }

        Moon {
            id: moon
            z: 4
            scale: 1
            property string xmlData: ""

            Component.onCompleted: {
                var xhr = new XMLHttpRequest();
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                        xmlData = xhr.responseText;
                        processXMLData(xmlData);
                    }
                };
                xhr.open("GET", "http://iohelix.net/moon/moonlite.xml", true);
                xhr.send();
            }

            function extractTagValue(xml, tag) {
                var regex = new RegExp("<" + tag + ">(.*?)</" + tag + ">", "i");
                var match = xml.match(regex);
                return match ? match[1] : "";
            }

            property var elongSun: undefined
            property var percentIlu: undefined
            property var moonPhase: undefined
            property var daysPhase: undefined
            property var nextPhase: undefined

            function processXMLData(xml) {
                var elongationToSun = extractTagValue(xml, "elongationToSun");
                var phase = extractTagValue(xml, "phase");
                var percentIlluminated = extractTagValue(xml, "percentIlluminated");
                var nextPhaseSection = xml.match(/<nextPhase>([\s\S]*?)<\/nextPhase>/i);
                var nextPhaseVal = "";
                var daysToPhaseVal = "";
                if (nextPhaseSection) {
                    nextPhaseVal = extractTagValue(nextPhaseSection[1], "phase");
                    daysToPhaseVal = extractTagValue(nextPhaseSection[1], "daysToPhase");
                }

                elongSun = elongationToSun;
                percentIlu = percentIlluminated;
                moonPhase = phase;
                daysPhase = daysToPhaseVal;
                nextPhase = nextPhaseVal;

/*
                 // Consola para depuración para verificar los datos extraídos:
                 console.log("Longitud de datos, Moon XML:", xml.length)
                 console.log("Elongación:", elongSun);
                 console.log("Iluminación:", percentIlu);
                 console.log("Fase Actual:", moonPhase);
                 console.log("Próxima Fase:", nextPhase);
                 console.log("Días restantes:", daysPhase);
*/
            }
        }

        LibWeather.WeatherData {
            id: weatherData

            // Propiedades en configuración
            selectedProvider: plasmoid.configuration.provider || "metno"
            locationId: plasmoid.configuration.locationId || ""
            latitude: plasmoid.configuration.latitude || 0
            longitude: plasmoid.configuration.longitude || 0

            onLocationIdChanged: {
                // Forzar actualización de la UI
                contentItemChanged()
            }

        }

        PlasmaComponents3.Button {
            id: configureButton
            anchors.centerIn: parent
            visible: !plasmoid.configuration.locationId || plasmoid.configuration.locationId === ""
            text: i18nd("plasma_applet_org.kde.plasma.weather", "Set location…")
            z: 3
            onClicked: Plasmoid.internalAction("configure").trigger()
            Layout.minimumWidth: implicitWidth
            Layout.minimumHeight: implicitHeight
        }

        property Item contentItem: {
            if (!weatherData.locationId || weatherData.locationId === "") {
                return configureButton
            } else {
                return forecastLayout
            }
        }

        ForecastLayout {
            id: forecastLayout
            visible: !configureButton.visible
        }

        function action_refresh() {
            weatherData.refresh()
        }

        Plasmoid.contextualActions: [
            PlasmaCore.Action {
                text: i18n("Refresh")
                icon.name: "view-refresh"
                onTriggered: {
                    console.log("Refresh triggered")
                    weatherData.refresh()
                }
            }
        ]
    }
/*
    Component.onCompleted: {
        console.log("=== PLASMOID LOADED ===")
        console.log("locationId:", plasmoid.configuration.locationId)
        console.log("cityName:", plasmoid.configuration.cityName)
    }
*/
}
