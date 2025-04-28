import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
//import org.kde.ksvg as KSvg
import org.kde.plasma.components 3.0 as PlasmaComponents3
import QtQuick.Controls
//import QtQuick.XmlListModel // qml6-module-qtqml-xmllistmodel
import "baro"
import "moon"
import "./libweather" as LibWeather

PlasmoidItem {
    id: root
        Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

        readonly property int baseWidth: 300
        readonly property int baseHeight: 300
        property double scaleFactor: Math.min(width / baseWidth, height / baseHeight)
        width: baseWidth
        height: baseHeight

        // Check position & dimension
//        onWidthChanged: console.log("Ancho actualizado:", width, "scaleFactor:", scaleFactor)
//        onHeightChanged: console.log("Alto actualizado:", height, "scaleFactor:", scaleFactor)

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
//----
            property var elongSun: undefined
            property var percentIlu: undefined
            property var moonPhase: undefined
            property var daysPhase: undefined
            property var nextPhase: undefined
//----

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

                // Asignación a propiedades del componente
                elongSun = elongationToSun;
                percentIlu = percentIlluminated;
                moonPhase = phase;
                daysPhase = daysToPhaseVal;
                nextPhase = nextPhaseVal;
/*
                console.log("Elongation to Sun:", elongSun);
                console.log("Phase:", moonPhase);
                console.log("Percent Illuminated:", percentIlu);
                console.log("Next Phase:", nextPhase);
                console.log("Days to Next Phase:", daysPhase);
*/
            }

        }
        ///------------------------

    LibWeather.WeatherData {
        id: weatherData
    }

//	Plasmoid.toolTipMainText: weatherData.currentConditions

		PlasmaComponents3.Button {
			id: configureButton
			anchors.centerIn: parent
			visible: weatherData.needsConfiguring
			text: i18nd("plasma_applet_org.kde.plasma.weather", "Set location…")
            z: 3
			onClicked: Plasmoid.internalAction("configure").trigger()
			Layout.minimumWidth: implicitWidth
			Layout.minimumHeight: implicitHeight
		}

    property Item contentItem: weatherData.needsConfiguring ? configureButton : forecastLayout

		ForecastLayout {
			id: forecastLayout
			visible: !weatherData.needsConfiguring
		}

	function action_refresh() {
		weatherData.refresh()
	}

	Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Refresh")
            icon.name: "view-refresh"
            onTriggered: weatherData.refresh()
        }
    ]
    } //fullRepresentation

}
