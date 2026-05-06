import QtQuick
import QtQuick.Layouts
//import org.kde.plasma.core as PlasmaCore

Item {
	id: forecastLayout

	//--- Layout
	Image {
		CurrentWeatherView {
			id: currentWeatherView
		}
	}
}
