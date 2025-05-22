import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

GridLayout {
	id: dailyForecastView

	//--- Settings
	readonly property int dateFontSize: plasmoid.configuration.dateFontSize * Screen.devicePixelRatio
	readonly property int minMaxFontSize: plasmoid.configuration.minMaxFontSize * Screen.devicePixelRatio
	
	readonly property int showNumDays: plasmoid.configuration.showNumDays
	readonly property bool showDailyBackground: plasmoid.configuration.showDailyBackground
	readonly property bool showMinTempBelow: plasmoid.configuration.showMinTempBelow

	//---
	columnSpacing: Kirigami.Units.smallSpacing
	rowSpacing: Kirigami.Units.smallSpacing

	// EnvCan has 2 day items for day/night, so we use 2 rows.
	// Other sources only need 1 row.
	readonly property int showNumDayItems: {
		if (weatherData.weatherSourceIsEnvcan) {
			if (weatherData.dataStartsWithNight) {
				return showNumDays * 2 - 1
			} else {
				return showNumDays * 2
			}
		} else {
			return showNumDays
		}
	}
	rows: weatherData.weatherSourceIsEnvcan ? 2 : 1
	flow: GridLayout.TopToBottom

	//--- Layout
	property alias model: dayRepeater.model

	// [EnvCan only] Takes the place of "today" if model starts with "night".
	Item {
		id: placeholderDayItem
		visible: weatherData.dataStartsWithNight
		Layout.fillWidth: true
		Layout.fillHeight: true
	}

	Repeater {
		id: dayRepeater
		model: weatherData.dailyForecastModel

		Item {
			id: dayItem

			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.minimumWidth: 62 * scaleFactor
			Layout.alignment: Qt.AlignHCenter

			visible: {
				if (dailyForecastView.showNumDays == 0) { // Show all
					return true
				} else {
					return (index+1) <= dailyForecastView.showNumDayItems
				}
			}

			ColumnLayout {
				id: dayItemLayout

				WLabel {
					text: modelData.dayLabel || ""
					font.pixelSize: dailyForecastView.dateFontSize
				}

			Kirigami.Icon {

				Image {
					id: dayItemIcon
					width: 56 * scaleFactor
					height: 44 * scaleFactor

					source: "../images/" + modelData.forecastIcon + ".png"

//            		Component.onCompleted: {console.log("Ruta del directorio:", source)}
				}

			}

				GridLayout {
					Layout.alignment: Qt.AlignHCenter
					columnSpacing: Kirigami.Units.smallSpacing * scaleFactor
					rowSpacing: 0
					flow: dailyForecastView.showMinTempBelow ? GridLayout.TopToBottom : GridLayout.LeftToRight

					WLabel {text: ""}
// Max temp
					WLabel {
						readonly property var value: modelData.tempHigh
						readonly property bool hasValue: !isNaN(value)

						text: hasValue ? weatherData.formatTempShort(value) : ""
						visible: hasValue
						font.pixelSize: dailyForecastView.minMaxFontSize
						Layout.alignment: Qt.AlignHCenter
					}
// Min Temp
					WLabel {
						readonly property var value: modelData.tempLow
//						opacity: forecastLayout.fadedOpacity
						readonly property bool hasValue: !isNaN(value)

						text: hasValue ? weatherData.formatTempShort(value) : ""
						visible: hasValue
						font.pixelSize: dailyForecastView.minMaxFontSize
						Layout.alignment: Qt.AlignHCenter
					}
				}

				// Top align contents
				Item {
					Layout.fillWidth: true
					Layout.fillHeight: true

				}
			}

			PlasmaCore.ToolTipArea {
				anchors.fill: parent
				mainText: modelData.forecastLabel
			}

		}
	}

}
