// libweather/DisplayUnits.qml
import QtQuick

QtObject {
	id: displayUnits

	// Leer unidades directamente de la configuración
	property int temperatureUnitId: plasmoid.configuration.temperatureUnitId || 0
	property int pressureUnitId: plasmoid.configuration.pressureUnitId || 0
	property int windSpeedUnitId: plasmoid.configuration.windSpeedUnitId || 0
	property int visibilityUnitId: plasmoid.configuration.visibilityUnitId || 0

	// Conversión de temperatura
	function convertTemperature(celsius) {
		switch(temperatureUnitId) {
			case 0: return celsius  // °C
			case 1: return (celsius * 9/5) + 32  // °F
			case 2: return celsius + 273.15  // K
			default: return celsius
		}
	}

	function formatTemperature(celsius, rounded) {
		var temp = convertTemperature(celsius)
		if (rounded) temp = Math.round(temp)
			var unit = ""
			switch(temperatureUnitId) {
				case 0: unit = "°C"; break
				case 1: unit = "°F"; break
				case 2: unit = "K"; break
				default: unit = "°C"
			}
			return temp + unit
	}

	// Conversión de velocidad del viento (m/s a la unidad seleccionada)
	function convertWindSpeed(mps) {
		switch(windSpeedUnitId) {
			case 0: return mps  // m/s
			case 1: return mps * 3.6  // km/h
			default: return mps
		}
	}

	function formatWindSpeed(mps) {
		var speed = convertWindSpeed(mps)
		var unit = windSpeedUnitId === 0 ? "m/s" : "km/h"
		return speed.toFixed(1) + " " + unit
	}

	// Conversión de presión (hPa a la unidad seleccionada)
	function convertPressure(hpa) {
		switch(pressureUnitId) {
			case 0: return hpa  // hPa
			case 1: return hpa  // mbar (1 hPa = 1 mbar)
			case 2: return hpa * 0.750062  // mmHg
			case 3: return hpa * 0.02953  // inHg
			default: return hpa
		}
	}

	function formatPressure(hpa) {
		var pressure = convertPressure(hpa)
		var unit = ""
		switch(pressureUnitId) {
			case 0: unit = "hPa"; break
			case 1: unit = "mbar"; break
			case 2: unit = "mmHg"; break
			case 3: unit = "inHg"; break
			default: unit = "hPa"
		}
		return pressure.toFixed(1) + " " + unit
	}

	// Conversión de visibilidad (km a la unidad seleccionada)
	function convertVisibility(km) {
		switch(visibilityUnitId) {
			case 0: return km  // km
			case 1: return km * 0.621371  // millas
			default: return km
		}
	}

	function formatVisibility(km) {
		var visibility = convertVisibility(km)
		var unit = visibilityUnitId === 0 ? "km" : "mi"
		return visibility.toFixed(1) + " " + unit
	}
}
