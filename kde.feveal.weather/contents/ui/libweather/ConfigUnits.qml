// ConfigUnits.qml

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
	id: units

	Kirigami.FormLayout {

		// Velocidad del viento - versión QQC2.ComboBox
		QQC2.ComboBox {
			id: windSpeedComboBox
			Kirigami.FormData.label: i18n("Wind speed:")
			model: ["m/s", "km/h"]

			onCurrentIndexChanged: {
				if (enabled) {
					plasmoid.configuration.windSpeedUnitId = currentIndex
					console.log("Wind speed changed to:", currentText)
				}
			}

			Component.onCompleted: {
				currentIndex = plasmoid.configuration.windSpeedUnitId || 0
				enabled = true
			}
		}

		// Temperatura
		QQC2.ComboBox {
			id: temperatureComboBox
			Kirigami.FormData.label: i18n("Temperature:")
			model: ["°C", "°F", "K"]

			onCurrentIndexChanged: {
				if (enabled) {
					plasmoid.configuration.temperatureUnitId = currentIndex
				}
			}

			Component.onCompleted: {
				currentIndex = plasmoid.configuration.temperatureUnitId || 0
				enabled = true
			}
		}

		// Presión
		QQC2.ComboBox {
			id: pressureComboBox
			Kirigami.FormData.label: i18n("Pressure:")
			model: ["hPa", "mbar", "mmHg", "inHg"]

			onCurrentIndexChanged: {
				if (enabled) {
					plasmoid.configuration.pressureUnitId = currentIndex
				}
			}

			Component.onCompleted: {
				currentIndex = plasmoid.configuration.pressureUnitId || 0
				enabled = true
			}
		}

		// Visibilidad
		QQC2.ComboBox {
			id: visibilityComboBox
			Kirigami.FormData.label: i18n("Visibility:")
			model: ["km", "miles"]

			onCurrentIndexChanged: {
				if (enabled) {
					plasmoid.configuration.visibilityUnitId = currentIndex
				}
			}

			Component.onCompleted: {
				currentIndex = plasmoid.configuration.visibilityUnitId || 0
				enabled = true
			}
		}
	}
}
