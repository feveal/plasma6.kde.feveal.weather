import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import "images"

Item {
	id:temp

	//--- Settings
	readonly property int forecastFontSize: plasmoid.configuration.forecastFontSize || 12
	readonly property int tempFontSize: plasmoid.configuration.tempFontSize || 24
	readonly property int detailsFontSize: plasmoid.configuration.detailsFontSize || 10
	readonly property bool showOutline: plasmoid.configuration.showOutline

	Images {
		id: images
	}

	WLabel {
		id: currentConditionsLabel

		Layout.fillWidth: true
		Layout.preferredWidth: 38 * Kirigami.Units.devicePixelRatio

		// Icon position
		x: 16 * scaleFactor
		y: 256 * scaleFactor
		text: weatherData.todaysForecastLabel || ""

		PlasmaCore.ToolTipArea {
			anchors.fill: parent
			mainText: currentConditionsLabel.text
			enabled: currentConditionsLabel.truncated
		}
	}

	GridLayout {
		id: currentWeatherView
		columns: 1

		// Temp position
		x: -16 * scaleFactor
		y: 260 * scaleFactor

		Layout.fillHeight: true

		Item {
			implicitHeight: currentTempLabel.font.pixelSize
			implicitWidth: currentTempLabel.implicitWidth
			WLabel {
				id: currentTempLabel
				anchors.verticalCenter: parent.verticalCenter
				font.pixelSize: tempFontSize
				font.family: plasmoid.configuration.fontFamily || Kirigami.Theme.defaultFont.family
				font.bold: plasmoid.configuration.bold || false
				readonly property var value: weatherData.currentTemp
				readonly property bool hasValue: !isNaN(value)

				Connections {
					target: weatherData
					function onCurrentTempChanged() {
						// Actions to take when the temperature changes
						var value = weatherData.currentTemp;
						var hasValue = !isNaN(value);
						var valor = hasValue ? weatherData.currentTempFormatted : "";
//						console.log ("------->:  " + valor)
					}
				}

				text: hasValue ? weatherData.formatTempShort(value) : ""

			}
		}

		// Estado actual
		Text {
			text: i18n(weatherData.currentConditions)
			color: plasmoid.configuration.textColor || "white"
			font.pixelSize: 12
			horizontalAlignment: Text.AlignHCenter
			Layout.alignment: Qt.AlignHCenter
		}


		Item {
			WLabel {
				id: locationLabel
				x:0 * scaleFactor
				y:0 * scaleFactor
				Layout.fillWidth: true
				horizontalAlignment: Text.AlignHCenter
				font.bold: true
				readonly property var value: weatherData.location
				readonly property bool hasValue: !!value
				text: hasValue ? value : ""
				opacity: 0.8
				wrapMode: Text.Wrap
			}

		}

		Item {

			WLabel {
				id: updatedAtLabel
				x:0 * scaleFactor
				y:15 * scaleFactor
				horizontalAlignment: Text.AlignHCenter
				font.pixelSize: 10
				readonly property var value: weatherData.oberservationTimestamp
				readonly property bool hasValue: !!value // && !isNaN(new Date(value))
				readonly property date valueDate: hasValue ? new Date(value) : new Date()
				text: {
						var timestamp = Qt.formatTime(valueDate, Qt.DefaultLocaleShortDate)
						if (timestamp) {
							return i18n("Updated at %1", timestamp)
						} else {
							return ""
						}
				}
				opacity: 0.6
				wrapMode: Text.Wrap
			}
		}

	}
	DetailsView {
		id: detailsView
		x: 220 * scaleFactor
		y: 280 * scaleFactor
		visible: plasmoid.configuration.showDetails
		Layout.alignment: Qt.AlignTop
		model: weatherData.detailsModel
	}
}

