// config/config.qml
import QtQuick 2.2
import org.kde.plasma.configuration 2.0

ConfigModel {
	ConfigCategory {
		name: i18n("Weather Baro")
		icon: Qt.resolvedUrl('../screenshot.png')
		source: "config/ConfigWeather.qml"
	}
	ConfigCategory {
		name: i18ndc("plasma_applet_org.kde.plasma.weather", "@title", "Units")
		icon: "preferences-other"
		source: "libweather/ConfigUnits.qml"
	}
	ConfigCategory {
		name: i18nc("@title", "Font Appearance")
		icon: "preferences-desktop-color"
		source: "config/ConfigAppearance.qml"
	}
}
