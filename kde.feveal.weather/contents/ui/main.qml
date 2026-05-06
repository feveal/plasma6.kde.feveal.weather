// main.qml - parte modificada

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
    property double scaleFactor: Math.min(width / baseWidth, height / baseHeight)
    width: baseWidth
    height: baseHeight

    fullRepresentation: Item {
        id: parentContainer
        anchors.fill: parent
        Layout.preferredWidth: baseWidth * Screen.devicePixelRatio
        Layout.preferredHeight: baseHeight * Screen.devicePixelRatio

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
//                console.log("Moon XML received, length:", xml.length)

                var elongationToSun = extractTagValue(xml, "elongationToSun");
                var phase = extractTagValue(xml, "phase");
//                console.log("Extracted phase:", phase)

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
//                console.log("moonPhase set to:", moonPhase)
                daysPhase = daysToPhaseVal;
                nextPhase = nextPhaseVal;
            }
        }

        // ==================================================================
        // NUEVO: WeatherData actualizado
        // ==================================================================
        LibWeather.WeatherData {
            id: weatherData

            // Estas propiedades deben estar en tu configuración
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
