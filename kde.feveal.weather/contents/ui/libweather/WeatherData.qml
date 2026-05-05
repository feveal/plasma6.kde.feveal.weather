// WeatherData.qml - Versión para Plasma 6 / Kubuntu 26.04
import QtQuick
import org.kde.plasma.core as PlasmaCore
import "providers" as Providers
import "../../code/model-utils.js" as ModelUtils

QtObject {
	id: weatherData

	// Propiedades de configuración (las defines en tu config)
	property string selectedProvider: plasmoid.configuration.provider // "metno", "om", "owm"
	property string locationId: plasmoid.configuration.locationId
	property string location: plasmoid.configuration.cityName || ""
	property double latitude: plasmoid.configuration.latitude
	property double longitude: plasmoid.configuration.longitude
	property int timezoneOffset: plasmoid.configuration.timezoneOffset

	// Propiedades que expone tu UI
	property bool isLoading: false
	property string errorMessage: ""
	property string currentConditions: ""
	property real currentTemp: 0
	property string oberservationTimestamp: ""
//	property string todaysForec
	property string currentConditionIconName: "weather-none-available"

	// Modelos de datos
	property var currentWeather: ({})
	property var nextDaysModel: []
	property var meteogramModel: []
	property var dailyForecastModel: ListModel { id: dailyForecastModel }

	// El proveedor activo
	property var activeProvider: null

	// Unidad de medida (para mostrar)
	property var displayUnits: DisplayUnits { id: displayUnits }

	// Al leer la configuración, usa valores por defecto
	property int temperatureUnitId: plasmoid.configuration.temperatureUnitId || 0
	property int windSpeedUnitId: plasmoid.configuration.windSpeedUnitId || 0
	property int pressureUnitId: plasmoid.configuration.pressureUnitId || 0
	property int visibilityUnitId: plasmoid.configuration.visibilityUnitId || 0

	// ------------------------------------------------------------------
	// Función principal para cargar datos
	// ------------------------------------------------------------------
	function refresh() {
/*
		console.log("=== WeatherData.refresh() called ===")
		console.log("locationId:", plasmoid.configuration.locationId)
		console.log("latitude:", plasmoid.configuration.latitude)
		console.log("longitude:", plasmoid.configuration.longitude)
		console.log("provider:", plasmoid.configuration.provider)

		if (!plasmoid.configuration.locationId &&
			(!plasmoid.configuration.latitude || !plasmoid.configuration.longitude)) {
			console.log("ERROR: No location configured!")
			return
			}

			if (!selectedProvider) {
				console.warn("WeatherData: Provider not configured")
				return
			}

			if (!locationId && (!latitude || !longitude)) {
				console.warn("WeatherData: No location configured (need locationId or lat/lon)")
				return
			}

		isLoading = true
		errorMessage = ""
*/
		// Crear o recargar el proveedor
		loadProvider()
	}

	// ------------------------------------------------------------------
	// Carga el proveedor correspondiente
	// ------------------------------------------------------------------
	function loadProvider() {
		var providerComponent

		switch(selectedProvider) {
			case "metno":
				providerComponent = Qt.createComponent("providers/MetNo.qml")
				break
			case "om":
				providerComponent = Qt.createComponent("providers/OpenMeteo.qml")
				break
			case "owm":
				providerComponent = Qt.createComponent("providers/OpenWeatherMap.qml")
				break
			default:
//				console.error("Unknown provider:", selectedProvider)
				isLoading = false
				return
		}

		if (providerComponent.status === Component.Ready) {
			finishProviderCreation(providerComponent)
		} else if (providerComponent.status === Component.Loading) {
			providerComponent.statusChanged.connect(() => {
				if (providerComponent.status === Component.Ready) {
					finishProviderCreation(providerComponent)
				} else if (providerComponent.status === Component.Error) {
//					console.error("Error loading provider:", providerComponent.errorString())
					isLoading = false
					errorMessage = providerComponent.errorString()
				}
			})
		} else {
//			console.error("Component error:", providerComponent.errorString())
			isLoading = false
			errorMessage = providerComponent.errorString()
		}
	}

	function finishProviderCreation(component) {
		if (activeProvider) {
			activeProvider.destroy()
		}

		// Usa los valores actuales, no los iniciales
		var currentLat = latitude !== undefined ? latitude : plasmoid.configuration.latitude || 0
		var currentLon = longitude !== undefined ? longitude : plasmoid.configuration.longitude || 0
		var currentPlaceId = locationId || ("lat=" + currentLat + "&lon=" + currentLon + "&altitude=0")

//		console.log("Creating provider with:", currentLat, currentLon, currentPlaceId)

		activeProvider = component.createObject(weatherData, {
			"latitude": currentLat,
			"longitude": currentLon,
			"placeIdentifier": currentPlaceId,
			"timezoneOffset": timezoneOffset
		})

		if (activeProvider) {
			activeProvider.loadDataFromInternet(
				() => onDataLoaded(),           // success callback
				(err) => onDataError(err)       // error callback
			)
		} else {
			isLoading = false
			errorMessage = "Failed to create provider"
		}
	}

	// ------------------------------------------------------------------
	// Callbacks
	// ------------------------------------------------------------------

	function onDataLoaded() {
		if (!activeProvider) return

//			console.log("Provider:", selectedProvider)
//			console.log("=== DATA LOADED ===")
//			console.log("Temperature:", activeProvider.currentWeatherModel?.temperature)
//			console.log("Icon:", activeProvider.currentWeatherModel?.iconName)
//			console.log("Next days count:", activeProvider.nextDaysModel?.count)


			// Copiar los datos del proveedor a nuestras propiedades
			currentWeather = {
				temperature: activeProvider.currentWeatherModel?.temperature,
				iconName: activeProvider.currentWeatherModel?.iconName,
				windDirection: activeProvider.currentWeatherModel?.windDirection,
				windSpeedMps: activeProvider.currentWeatherModel?.windSpeedMps,
				pressureHpa: activeProvider.currentWeatherModel?.pressureHpa,
				humidity: activeProvider.currentWeatherModel?.humidity,
				cloudiness: activeProvider.currentWeatherModel?.cloudiness,
				isDay: activeProvider.currentWeatherModel?.isDay,
				sunRiseTime: activeProvider.currentWeatherModel?.sunRiseTime,
				sunSetTime: activeProvider.currentWeatherModel?.sunSetTime,
				nearFutureWeather: activeProvider.currentWeatherModel?.nearFutureWeather || {}
			}

			currentTemp: currentWeather.temperature || 0
			todaysForecastLabel: currentConditions || ""
			location: plasmoid.configuration.cityName // || "Burgos"
			currentConditionIconName = currentWeather.iconName || "weather-none-available" // MetNo
			(activeProvider.currentWeatherModel?.iconName) || "weather-none-available" // owm

//			console.log("currentConditionIconName set to:", currentConditionIconName)

			if (selectedProvider === "metno") {
				// Copiar modelos
				nextDaysModel = []
				if (activeProvider.nextDaysModel) {
					for (var i = 0; i < activeProvider.nextDaysModel.count; i++) {
						nextDaysModel.push(activeProvider.nextDaysModel.get(i))
					}
				}

				currentTemp = currentWeather.temperature
				currentTempChanged()

				// Actualizar currentConditions
				currentConditions = activeProvider.currentWeatherModel?.conditionDescription ||
				"Weather data available"

				// Forzar actualización de la UI
				currentWeatherChanged()

				if (!currentWeather.iconName || currentWeather.iconName === "") {  // Para owm
					currentWeather.iconName = "weather-none-available"
//					console.log("Warning: No icon name from provider, using default")
				}

				isLoading = false
			}

			// Modificación para owm
			else if (selectedProvider === "owm") {
//				console.log("=== nextDaysModel content in WeatherData ===")

				if (activeProvider.currentWeatherModel?.cityName) {
					location = activeProvider.currentWeatherModel.cityName
//					console.log("OWM city name:", location)
				}
/*
				if (activeProvider.nextDaysModel) {
					for (var i = 0; i < activeProvider.nextDaysModel.count; i++) {
						var item = activeProvider.nextDaysModel.get(i)
						console.log("Row " + i + ": dayLabel=" + item.dayLabel +
						", tempLow=" + item.tempLow +
						", tempHigh=" + item.tempHigh +
						", forecastIcon=" + item.forecastIcon)
					}
				}
*/
				currentConditions = activeProvider.currentWeatherModel?.conditionDescription ||
				activeProvider.currentWeatherModel?.description ||
				"Weather data available"
//				console.log("currentConditions set to:", currentConditions)

				currentTemp = currentWeather.temperature
				currentTempChanged()

				// Limpiar y llenar dailyForecastModel
				dailyForecastModel.clear()
				for (var i = 0; i < activeProvider.nextDaysModel.count; i++) {
					var item = activeProvider.nextDaysModel.get(i)
					dailyForecastModel.append({
						dayLabel: item.dayLabel,
						tempLow: item.tempLow,
						tempHigh: item.tempHigh,
						forecastIcon: item.forecastIcon || "weather-none-available"
					})
				}
//				console.log("dailyForecastModel count after append:", dailyForecastModel.count)
			}
	}

	function onDataError(error) {
//		console.error("Weather data error:", error)
		isLoading = false
		errorMessage = "Error loading weather data"
	}

	// ------------------------------------------------------------------
	// Utilidades para mostrar (manteniendo compatibilidad con tu UI)
	// ------------------------------------------------------------------
	function formatTemp(value, rounded, degreesOnly) {
		if (!value && value !== 0) return "N/A"
			return displayUnits.formatTemperature(value, rounded)
	}

	function windDirection(bearing) {
		var directions = ['N','NNE','NE','ENE','E','ESE','SE','SSE','S','SSW','SW','WSW','W','WNW','NW','NNW']
		if (!bearing && bearing !== 0) return "N/A"
			var brg = Math.round((bearing + 11.25) / 22.5)
			return directions[brg % 16]
	}

	function formatTempShort(value) {
    if (!value && value !== 0) return "N/A"
    return displayUnits.formatTemperature(value, true)
}

	// Función para velocidad del viento (si la necesita Baro.qml)
	function intWindSpeed() {
		if (!currentWeather.windSpeedMps && currentWeather.windSpeedMps !== 0) return 0
		return Math.round(displayUnits.convertWindSpeed(currentWeather.windSpeedMps))
	}

	// Propiedad computada para el texto del viento
	property string windDisplay: {
		if (!currentWeather.windSpeedMps && currentWeather.windSpeedMps !== 0) return ""
			var speed = displayUnits.formatWindSpeed(currentWeather.windSpeedMps)
			var dir = windDirection(currentWeather.windDirection)
			return dir + " " + speed
	}

	property var detailsModel: [
		{ label: i18n("Wind:"), text: windDisplay },
		{ label: i18n("Pressure:"), text: currentWeather.pressureHpa ? displayUnits.formatPressure(currentWeather.pressureHpa) : "" },
		{ label: i18n("Humidity:"), text: currentWeather.humidity ? currentWeather.humidity + "%" : "" },
		{ label: i18n("Cloudiness:"), text: currentWeather.cloudiness ? currentWeather.cloudiness + "%" : "" }
	]

	property string currentTempFormatted: {
		if (!currentTemp && currentTemp !== 0) return "N/A"
			return displayUnits.formatTemperature(currentTemp, true)
	}

	// ------------------------------------------------------------------
	// Timer para actualización automática
	// ------------------------------------------------------------------
	property int updateIntervalMinutes: 30
	property Timer updateTimer: Timer {
		interval: updateIntervalMinutes * 60 * 1000
		repeat: true
		running: true
		onTriggered: refresh()
	}

	// ==================================================================
	// Conectar cambios de configuración
	// ==================================================================
	onLocationIdChanged: {
//		console.log("locationId changed to:", locationId)
		if (locationId) refresh()
	}

	onSelectedProviderChanged: {
//		console.log("provider changed to:", selectedProvider)
		if (locationId) refresh()
	}

	onLatitudeChanged: {
//		console.log("latitude changed to:", latitude)
		if (!locationId && latitude && longitude) refresh()
	}

	onLongitudeChanged: {
//		console.log("longitude changed to:", longitude)
		if (!locationId && latitude && longitude) refresh()
	}

	// Inicializar al cargar
	//	Component.onCompleted: refresh()
	Component.onCompleted: {
/*
		console.log("=== WeatherData INITIALIZED ===")
		console.log("selectedProvider:", selectedProvider)
		console.log("locationId:", locationId)
		console.log("latitude:", latitude)
		console.log("longitude:", longitude)
*/
		refresh()
	}
}
