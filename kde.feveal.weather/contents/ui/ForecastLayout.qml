import QtQuick
import QtQuick.Layouts

Item {
	id: forecastLayout

	//--- Layout
	Image {
		CurrentWeatherView {
			id: currentWeatherView
		}
	}
}
