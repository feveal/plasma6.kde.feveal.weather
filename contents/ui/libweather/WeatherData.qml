// Version 10

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasma5support as Plasma5Support

import org.kde.plasma.private.weather as WeatherPlugin

QtObject {
	readonly property string weatherSource: plasmoid.configuration.source

	readonly property bool needsConfiguring: !weatherSource
	readonly property bool hasData: !needsConfiguring && !connectingToSource
	readonly property var data: weatherDataSource.currentData || {}

	property QtObject displayUnits: DisplayUnits { id: displayUnits }

	// EnvCan
	readonly property bool weatherSourceIsEnvcan: weatherSource.indexOf('envcan|') == 0
	readonly property bool dataStartsWithNight: {
		if (weatherSourceIsEnvcan) {
			return todaysDayLabel == i18ndc("plasma_engine_weather", "Short for tonight", "nite")
		} else {
			return false
		}
	}

	readonly property int updateInterval: 30
	property bool connectingToSource: false

	function refresh() {
//		console.log(plasmoid.pluginName, 'WeatherData.refresh()')
		weatherDataSource.disconnectSource(weatherSource)
		weatherDataSource.removeSource(weatherSource)
		refreshTimer.restart()
	}
	property var refreshTimer: Timer {
		id: refreshTimer
		interval: 100
		onTriggered: connectWeatherSource()
	}
	function connectWeatherSource() {
		weatherDataSource.connectSource(weatherSource)
	}
//	onOberservationTimestampChanged: console.log(plasmoid.pluginName, 'oberservationTimestamp', oberservationTimestamp)

	property var weatherDataSource: Plasma5Support.DataSource {
		id: weatherDataSource
		engine: "weather"
		connectedSources: weatherSource
		interval: updateInterval * 60 * 1000

		onConnectedSourcesChanged: {
//			console.log('onConnectedSourcesChanged', connectedSources)
			if (weatherSource && !currentData) {
				connectingToSource = true
				plasmoid.busy = true
				connectionTimeoutTimer.start()
			}
		}

		readonly property var currentData: data[weatherSource]

		onCurrentDataChanged: {
			if (currentData) {
				connectionTimeoutTimer.stop()
				connectingToSource = false
				plasmoid.busy = false
//---->> Visualizar en consola todos los datos proporcionados por el sevidor
				logCurrentData()
			}
		}

		function logCurrentData() {
			var keys = Object.keys(currentData)
			for (var i = 0; i < keys.length; i++) {
				var key = keys[i]
				var value = currentData[key]

//				console.log('currentData["' + key + '"]', value)
			}
		}
	}

	property var connectionTimeoutTimer: Timer {
		id: connectionTimeoutTimer

		interval: 60 * 1000 // 1 min
		repeat: false
		onTriggered: {
			connectingToSource = false
			plasmoid.busy = false
			// TODO: inform user
			var sourceTokens = weatherSource.split("|")
			var foo = i18nd("plasma_applet_org.kde.plasma.weather", "Weather information retrieval for %1 timed out.", sourceTokens[2])
//			console.log(plasmoid.pluginName, foo)
		}
	}

	function parseForecast(dayIndex) {
		var key = "Short Forecast Day " + dayIndex
		var value = data[key]
		var tokens = ["", "weather-none-available", "", "", "", ""]
		if (value) {
			tokens = value.split("|")
			if (tokens.length >= 6) {
				tokens[3] = parseInt(tokens[3], 10)
				tokens[4] = parseInt(tokens[4], 10)
				tokens[5] = parseInt(tokens[5], 10)
				return tokens
			}
		}
//		console.log('parseForecast(' + dayIndex + ')', tokens)
		return tokens
	}

	//-----------------

	function weatherTomorrow() {
		var key = "Short Forecast Day " + 1;
		var value = data[key];
		// Suponiendo que value tiene el formato "weather.showers-scattered|chaparrones suaves"
		var values = value.split("|"); // Separar los dos valores por el carácter "|"
//		console.log (">>>: " + values)
		return values; // Devolver un array con la imagen y la descripción
	}
	//------------------

	function parseForecastLabel(tokens) {
		var condition = tokens[2]
		var probability = tokens[5] // popPercent
		if (probability !== "N/U" && probability !== "N/A" && !!probability) {
			return i18ndc("plasma_applet_org.kde.plasma.weather",
				"certain weather condition (probability percentage)",
				"%1 (%2 %)", condition, probability)
		} else {
			return condition
		}
	}

	property string oberservationTimestamp: {
		return data["Observation Timestamp"] || ""
	}
	property string location: {
		return data["Place"] || ""
	}

	readonly property var todaysWeather: parseForecast(0) // currentData["Short Forecast Day 0"]
	readonly property string todaysDayLabel: todaysWeather[0]
	readonly property string todaysForecastIcon: todaysWeather[1]
	readonly property string todaysCondition: todaysWeather[2]
	readonly property var todaysTempHigh: todaysWeather[3]
	readonly property var todaysTempLow: todaysWeather[4]
	readonly property var todaysPopPercent: todaysWeather[5]
	readonly property string todaysForecastLabel: parseForecastLabel(todaysWeather)

	function existingWeatherIconName(iconName) {
		if (typeof WeatherPlugin["Util"] !== "undefined") {
			// Plasma 5.13+
			return WeatherPlugin.Util.existingWeatherIconName(iconName)
		} else {
			// <= Plasma 5.12
			return iconName
		}
	}
	function percentToDisplayString(percent) {
		if (typeof WeatherPlugin["Util"] !== "undefined") {
			// Plasma 5.13+
			return WeatherPlugin.Util.percentToDisplayString(percent)
		} else {
			// <= Plasma 5.12
			return percent + ' %'
		}
	}
	function valueToDisplayString(displayUnitType, value, valueUnitType, precision) {
		if (typeof WeatherPlugin["Util"] !== "undefined") {
			// Plasma 5.13+
			return WeatherPlugin.Util.valueToDisplayString(displayUnitType, value, valueUnitType, precision)
		} else {
			// <= Plasma 5.12
			return value.toFixed(precision)
		}
	}
	function temperatureToDisplayString(displayUnitType, value, valueUnitType, rounded, degreesOnly) {
		if (typeof WeatherPlugin["Util"] !== "undefined") {

			return WeatherPlugin.Util.temperatureToDisplayString(displayUnitType, value, valueUnitType, rounded, degreesOnly)
		} else {
			// <= Plasma 5.12
			return Math.round(value) + '°'
		}
	}

	property string currentConditionIconName: {
		var conditionIconName = data["Condition Icon"]
		if (!conditionIconName || conditionIconName == "weather-none-available") {
			conditionIconName = todaysForecastIcon
		}
		return conditionIconName ? existingWeatherIconName(conditionIconName) : "weather-none-available"
	}

	property string currentConditions: {
		return data["Current Conditions"] || todaysForecastLabel || ""
	}

	property var currentTemp: {
		return isNaN(data["Temperature"]) ? NaN : data["Temperature"]
	}

	readonly property int forecastDayCount: parseInt((data && data["Total Weather Days"]) || "", 10)
	function parseDailyForecastModel() {
		var model = []

		if (isNaN(forecastDayCount) || forecastDayCount <= 0) {
			return model
		}

		for (var i = 0; i < forecastDayCount; i++) {
			if (typeof data["Short Forecast Day " + i] === "undefined") {
				// "Total Weather Days" can be "7", however there might not be a "Short Forecast Day 6"
				break
			}
			var tokens = parseForecast(i)
			var item = {
				dayLabel: tokens[0],
				forecastIcon: existingWeatherIconName(tokens[1]),
				condition: tokens[2],
				tempHigh: tokens[3],
				tempLow: tokens[4],
				popPercent: tokens[5],
				forecastLabel: parseForecastLabel(tokens),
			}
			model.push(item)
		}
		return model
	}
	property var dailyForecastModel: data ? parseDailyForecastModel() : []
	// onDailyForecastModelChanged: console.log('dailyForecastModel', JSON.stringify(dailyForecastModel, null, '  '))

	// To find a specific to test warnings, check the EnvCan national map at:
	// https://weather.gc.ca/warnings/index_e.html
	function parseNoticeList(totalKey, itemKey) {
		var model = []
		var noticesCount = parseInt(data["Total "+totalKey+" Issued"] || "", 10) // data["Total Warnings Issued"]
		if (isNaN(noticesCount)) {
			noticesCount = 0
		}
		for (var i = 0; i < noticesCount; ++i) {
			var notice = {
				"description": data[itemKey+" Description "+i], // data["Warning Description 0"]
				"url": data[itemKey+" Info "+i], // data["Warning Info 0"]
			}
			model.push(notice)
		}
		// console.log(totalKey, JSON.stringify(model, null, '  '))
		return model
	}
	property var warningsModel: parseNoticeList("Warnings", "Warning")
	property var watchesModel: parseNoticeList("Watches", "Watch")


	readonly property int invalidUnit: -1 //TODO: make KUnitConversion::InvalidUnit usable here
	function getNumber(key) {
		var number = data[key];
		if (typeof number === "string") {
			var parsedNumber = parseFloat(number);
			return isNaN(parsedNumber) ? null : parsedNumber;
		}
		return (typeof number !== "undefined") && (number !== "") ? number : null;
	}
	function getNumberOrString(key) {
		var number = data[key]
		return (typeof number !== "undefined") && (number !== "") ? number : null
	}

	function formatTemp(value, rounded, degreesOnly) {
		var valueUnitType = data["Temperature Unit"] || invalidUnit
		var displayUnitType = displayUnits.temperatureUnitId
		var text = temperatureToDisplayString(displayUnitType, value, valueUnitType, rounded, degreesOnly)
		if (degreesOnly) {
			// Remove space between number and degree symbol
			text = text.replace(' ', '')
		}
		return text
	}
	function formatTempShort(value) {
		return formatTemp(value, true, true)
	}

	//--------------------------------------------------------
	function intWindSpeed(value) {
		//		var value = getNumberOrString("Wind Speed")
		var value = data["Wind Speed"]
		return value
	}
	//--------------------------------------------------------

	function getDetailsItemAndUnits(valueKey, reportUnitKey) {
		var reportUnit = data[reportUnitKey] || invalidUnit
		var displayUnit
		if (reportUnitKey == "Temperature Unit") {
			displayUnit = displayUnits.temperatureUnitId
		} else if (reportUnitKey == "Visibility Unit") {
			displayUnit = displayUnits.visibilityUnitId
		} else if (reportUnitKey == "Pressure Unit") {
			displayUnit = displayUnits.pressureUnitId
		} else {
			displayUnit = reportUnit
		}
		var value = getNumberOrString(valueKey)
		if (value) {
			if (reportUnit !== invalidUnit) {
				value = valueToDisplayString(displayUnit, value, reportUnit, 1)
			}
			return value
		} else {
			return null
		}
	}
	readonly property var detailsModel: {
		var model = []

		// windchill
		var windchill = getDetailsItemAndUnits("Windchill", "Temperature Unit")
		if (windchill) {
			model.push({
				"label": i18ndc("plasma_applet_org.kde.plasma.weather", "@label", "Windchill:"),
				"text": windchill,
			})
		}

		// speedUnitId: LocaleDefault = 0, MeterPerSecond = 9000, KilometerPerHour = 9001, MilePerHour = 9002, Knot = 9005, Beaufort = 9008
		var reportWindSpeedUnit = data["Wind Speed Unit"] || invalidUnit
		var displaySpeedUnit = displayUnits.windSpeedUnitId

		var windDirection = data["Wind Direction"] || ""
		var windSpeed = getNumberOrString("Wind Speed")
		var windSpeedText
		if (windSpeed !== null && windSpeed !== "") {
			var windSpeedNumeric = (typeof windSpeed !== 'number') ? parseFloat(windSpeed) : windSpeed
			if (!isNaN(windSpeedNumeric)) {
				if (windSpeedNumeric !== 0) {
					windSpeedText = valueToDisplayString(displaySpeedUnit, windSpeedNumeric, reportWindSpeedUnit, 1)
					if (windDirection) {
						windSpeedText = i18ndc("plasma_applet_org.kde.plasma.weather", "winddirection windspeed", "%1 %2", windDirection, windSpeedText)
					}
				} else {
					windSpeedText = i18ndc("plasma_applet_org.kde.plasma.weather", "Wind condition", "Calm")
				}
			} else {
				// TODO: i18n?
				windSpeedText = windSpeed
			}
			model.push({
				"label": i18n("Wind:"),
				"text": windSpeedText,
			})
		}

		// visibilityUnitId: LocaleDefault = 0, Kilometer = 2007, Mile = 2024
		var visibility = getDetailsItemAndUnits("Visibility", "Visibility Unit")
		if (visibility) {
			model.push({
				"label": i18ndc("plasma_applet_org.kde.plasma.weather", "@label", "Visibility:"),
				"text": visibility,
			})
		}

		// pressureUnitId: LocaleDefault = 0, Hectopascal = 5008, Kilopascal = 5007, Millibar = 5022, InchesOfMercury = 5028
		var pressure = getDetailsItemAndUnits("Pressure", "Pressure Unit")
		if (pressure) {
			model.push({
				"label": i18ndc("plasma_applet_org.kde.plasma.weather", "@label", "Pressure:"),
				"text": pressure,
			})
		}

		// humitity
		var humidity = getNumber("Humidity")
		if (humidity !== null) {
			model.push({
				"label": i18ndc("plasma_applet_org.kde.plasma.weather", "@label", "Humidity:"),
				"text": percentToDisplayString(humidity),
			})
		}

//		console.log('model', JSON.stringify(model, null, '\t'))
		return model
	}

}
