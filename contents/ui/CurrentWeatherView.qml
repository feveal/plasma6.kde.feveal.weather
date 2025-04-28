import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import "images"

Item {
	id:temp
	//--- Settings
	readonly property int forecastFontSize: plasmoid.configuration.forecastFontSize * Screen.devicePixelRatio
	readonly property int tempFontSize: plasmoid.configuration.tempFontSize * Screen.devicePixelRatio

	Images {
		id: images
	}
	WLabel {
		Layout.fillWidth: true
		Layout.preferredWidth: 38 * Kirigami.Units.devicePixelRatio
		id: currentConditionsLabel
		x: 12 * scaleFactor
		y: 256 * scaleFactor

		text: weatherData.todaysForecastLabel
		font.pixelSize: forecastFontSize
//		wrapMode: Text.WordWrap

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
		x: 12 * scaleFactor
		y: 280 * scaleFactor

		Layout.fillHeight: true

		Item {
			implicitHeight: currentTempLabel.font.pixelSize
			implicitWidth: currentTempLabel.implicitWidth
			WLabel {
				id: currentTempLabel
				anchors.verticalCenter: parent.verticalCenter
				font.pixelSize: tempFontSize
				readonly property var value: weatherData.currentTemp
				readonly property bool hasValue: !isNaN(value)

				Connections {
					target: weatherData
					onCurrentTempChanged: {
						// Actions to take when the temperature changes
						var value = weatherData.currentTemp;
						var hasValue = !isNaN(value);
						var valor = hasValue ? weatherData.formatTempShort(value) : "";
//						console.log ("------->:  " + valor)
					}
				}

				text: hasValue ? weatherData.formatTempShort(value) : ""

			}
		}

		Item {

			WLabel {
				id: updatedAtLabel
				x:0 * scaleFactor
				y:3 * scaleFactor
				horizontalAlignment: Text.AlignHCenter

				font.pixelSize: plasmoid.configuration.detailsFontSize * Kirigami.Units.devicePixelRatio

				readonly property var value: weatherData.oberservationTimestamp
				readonly property bool hasValue: !!value // && !isNaN(new Date(value))
				readonly property date valueDate: hasValue ? new Date(value) : new Date()
				text: {
					if (hasValue) {
						var timestamp = Qt.formatTime(valueDate, Qt.DefaultLocaleShortDate)
						if (timestamp) {
							return i18n("Updated at %1", timestamp)
						} else {
							return ""
						}
					} else {
						return ""
					}
				}
				opacity: 0.6
				wrapMode: Text.Wrap
			}
		}

		Item {
			WLabel {
				id: locationLabel
				x:0 * scaleFactor
				y:12 * scaleFactor
				Layout.fillWidth: true
				horizontalAlignment: Text.AlignHCenter
				//				font.pixelSize: detailsView.detailsFontSize
				readonly property var value: weatherData.location
				readonly property bool hasValue: !!value
				text: hasValue ? value : ""
				opacity: 0.6
				wrapMode: Text.Wrap
			}

			NoticesListView {
				Layout.fillWidth: true
				model: weatherData.watchesModel
				readonly property bool showWatches: plasmoid.configuration.showWarnings
				visible: showWatches && model.length > 0
				state: "Watches"
				horizontalAlignment: Text.AlignHCenter
			}

			NoticesListView {
				Layout.fillWidth: true
				model: weatherData.warningsModel
				readonly property bool showWarnings: plasmoid.configuration.showWarnings
				visible: showWarnings && model.length > 0
				state: "Warnings"
				horizontalAlignment: Text.AlignHCenter
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

