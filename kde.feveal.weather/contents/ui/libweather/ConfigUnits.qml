// ConfigUnits.qml

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
	id: units

	Kirigami.FormLayout {

		// Velocidad del viento
		QQC2.ComboBox {
			id: windSpeedComboBox
			Kirigami.FormData.label: i18n("Wind speed:")
			model: ["m/s", "km/h"]

			// Enlace bidireccional seguro
			currentIndex: plasmoid.configuration.windSpeedUnitId
			onActivated: (index) => { plasmoid.configuration.windSpeedUnitId = index }
		}

		// Temperatura
		QQC2.ComboBox {
			id: temperatureComboBox
			Kirigami.FormData.label: i18n("Temperature:")
			model: ["°C", "°F", "K"]

			currentIndex: plasmoid.configuration.temperatureUnitId
			onActivated: (index) => { plasmoid.configuration.temperatureUnitId = index }
		}

		// Presión
		QQC2.ComboBox {
			id: pressureComboBox
			Kirigami.FormData.label: i18n("Pressure:")
			model: ["hPa", "mbar", "mmHg", "inHg"]

			currentIndex: plasmoid.configuration.pressureUnitId
			onActivated: (index) => { plasmoid.configuration.pressureUnitId = index }
		}

		// Visibilidad
		QQC2.ComboBox {
			id: visibilityComboBox
			Kirigami.FormData.label: i18n("Visibility:")
			model: ["km", "miles"]

			currentIndex: plasmoid.configuration.visibilityUnitId
			onActivated: (index) => { plasmoid.configuration.visibilityUnitId = index }
		}
	}
}
