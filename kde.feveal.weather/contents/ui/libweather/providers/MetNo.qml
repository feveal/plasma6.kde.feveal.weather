import QtQuick 2.15
import "../../../code/model-utils.js" as ModelUtils
import "../../../code/data-loader.js" as DataLoader
import "../../../code/unit-utils.js" as UnitUtils

QtObject {
    id: metno

// ---
property var main: QtObject {
    property int timezoneType: 2
    property bool loadingDataComplete: false
    property var dataSource: QtObject {
        property var data: ({})
    }
}

property bool useOnlineWeatherData: true

// Propiedades que se reciben desde WeatherData
property string placeIdentifier: ""
property real latitude: 0
property real longitude: 0
property int timezoneOffset: 0

// Propiedades simuladas para reemplazar "currentPlace"
property var currentPlace: QtObject {
    property int timezoneOffset: metno.timezoneOffset
    property string identifier: placeIdentifier
    property string alias: ""
    property string timezoneShortName: ""
    property int timezoneID: -1
}

// Modelos de salida
property var currentWeatherModel: ({})
property var dailyForecastModel: ListModel { id: nextDaysListModel }
property var meteogramModel: ListModel { id: meteogramListModel }

    property var locale: Qt.locale()
    property string providerId: 'metno'
    property string urlPrefix: 'https://api.met.no/weatherapi/locationforecast/2.0/compact?'
    property string forecastPrefix: 'https://www.yr.no/en/forecast/daily-table/'

    property bool weatherDataFlag: false
    property bool sunRiseSetFlag: false

    function getCreditLabel(placeIdentifier) {
        return i18n("Forecast data provided by Met.no")
    }

    function dbgprint(msg) {
//        console.log("OWM DEBUG:", msg)
    }

    function dbgprint2(msg) {
//        console.log("OWM DEBUG2:", msg)
    }

    function getCreditLink(placeIdentifier) {
        var weatherURLTest = urlPrefix + placeIdentifier
        var creditLink = weatherURLTest
        return creditLink
        // urlPrefix + extLongLat(placeIdentifier)
    }

    function parseDate(dateString) {
        return new Date(dateString + '.000Z')
    }

    function loadDataFromInternet(successCallback, failureCallback, locationObject) {

        dbgprint2("loadDataFromInternet: " + currentPlace.alias)

        var finalPlaceId = placeIdentifier

        // Si no viene, usar locationObject como respaldo
        if (!finalPlaceId && locationObject && locationObject.placeIdentifier) {
            finalPlaceId = locationObject.placeIdentifier
        }

//        console.log("MetNo: Using placeIdentifier:", finalPlaceId)

        // Construir URL con finalPlaceId
        var latMatch = placeIdentifier.match(/lat=([^&]+)/)
        var lonMatch = placeIdentifier.match(/lon=([^&]+)/)
        var altMatch = placeIdentifier.match(/altitude=([^&]+)/)

        if (latMatch && lonMatch) {
            var lat = latMatch[1]
            var lon = lonMatch[1]
            var alt = altMatch ? altMatch[1] : "0"
            var weatherURL = "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=" + lat + "&lon=" + lon + "&altitude=" + alt
//            console.log("MetNo: Corrected URL:", weatherURL)
        } else {
//            console.log("MetNo: Could not parse lat/lon from:", placeIdentifier)
            dataError("Invalid location format")
            return
        }


        weatherDataFlag = false
        sunRiseSetFlag = false
        var TZURL = ""

        if (currentPlace.timezoneID === -1) {
//            console.log("[weatherWidget] Timezone Data not available - using sunrise-sunset.org API")
            TZURL = "https://api.sunrise-sunset.org/json?formatted=0&" + placeIdentifier
        } else {
//            dbgprint("Timezone Data is available - using met.no API")

            TZURL = 'https://api.met.no/weatherapi/sunrise/3.0/sun?' + placeIdentifier.replace(/&altitude=[^&]+/,"") + "&date=" + formatDate(new Date().toISOString())
            TZURL += "&offset=" + calculateOffset(currentPlace.timezoneOffset)
        }
//        dbgprint("Downloading Sunrise / Sunset Data from: " + TZURL)
        var xhr1 = DataLoader.fetchJsonFromInternet(TZURL, successSRAS, failureCallback)
        return [xhr1]

        function successWeather(jsonString) {
//            console.log("=== successWeather started ===")

            var readingsArray = JSON.parse(jsonString)
            updatecurrentWeather(readingsArray)
            loadCompleted()

            // Procesar previsión diaria
            var timeseries = readingsArray.properties.timeseries
            var dailyForecast = processDailyForecast(timeseries)

//            console.log("Daily forecast days:", dailyForecast.length)

            // Limpiar y llenar dailyForecastModel
            if (!weatherData.dailyForecastModel) {
//                console.log("ERROR: dailyForecastModel doesn't exist!")
                return
            }

            weatherData.dailyForecastModel.clear()

            for (var d = 0; d < dailyForecast.length; d++) {
                var weatherCode = dailyForecast[d].weatherCode || "unknown"
                var forecastCode = weatherCode.replace(/_night$/, "")
                var iconNumber = geticonNumber(forecastCode)

                weatherData.dailyForecastModel.append({
                    dayLabel: dailyForecast[d].date,
                    tempHigh: dailyForecast[d].maxTemp,
                    tempLow: dailyForecast[d].minTemp,
                    forecastIcon: iconNumber + ".png",
                        forecastLabel: weatherCode
                })
            }

//            console.log("Final dailyForecastModel count:", weatherData.dailyForecastModel.count)
        }

        function parseISOString(s) {
            var b = s.split(/\D+/)
            return new Date(Date.UTC(b[0], --b[1], b[2], b[3], b[4], b[5], b[6]))
        }

        function updatecurrentWeather(readingsArray) {
            dbgprint2("Build Current Weather")

            var currentWeather = readingsArray.properties.timeseries[0]
            var futureWeather = readingsArray.properties.timeseries[1]
            var symbolCode = currentWeather.data.next_1_hours.summary.symbol_code

            currentWeatherModel.conditionDescription = getConditionDescription(symbolCode)
            currentWeatherModel.iconName = geticonNumber(currentWeather.data.next_1_hours.summary.symbol_code)
            currentWeatherModel.windDirection = currentWeather.data.instant.details["wind_from_direction"]
            currentWeatherModel.windSpeedMps = currentWeather.data.instant.details["wind_speed"]
            currentWeatherModel.pressureHpa = currentWeather.data.instant.details["air_pressure_at_sea_level"]
            currentWeatherModel.humidity = currentWeather.data.instant.details["relative_humidity"]
            currentWeatherModel.cloudiness = currentWeather.data.instant.details["cloud_area_fraction"]
            currentWeatherModel.temperature = currentWeather.data.instant.details["air_temperature"]

            let sunRise = UnitUtils.convertDate(currentWeatherModel.sunRise,2,currentPlace.timezoneOffset)
            let sunSet = UnitUtils.convertDate(currentWeatherModel.sunSet,2,currentPlace.timezoneOffset)
            let updated = UnitUtils.convertDate(new Date(readingsArray.properties.timeseries[0].time) , 2 , currentPlace.timezoneOffset)

            dbgprint("Updated=" + readingsArray.properties.timeseries[0].time + "\t" + currentWeatherModel.sunRise + "\t" + currentWeatherModel.sunSet)
            dbgprint("Updated=" + updated/1000 + "\t" + sunRise/1000 + "\t" + sunSet/1000)
            dbgprint("Updated=" + updated/1000 + "\t" + (updated > sunRise) + "\t" + (updated < sunSet))
            currentWeatherModel.isDay = ((updated > sunRise) && (updated < sunSet)) ? 0 : 1

            dbgprint(JSON.stringify(currentWeatherModel))
        }

        function createDate(t) {
            let arr = t.split(":")
            return Date.parse(new Date(1970, 1, 1, arr[0], arr[1], 0))/1000
        }

        function updatedailyForecastModel(readingsArray) {
            dbgprint2("updatedailyForecastModel")
            dailyForecastModel.clear()

            function blankObject() {
                const myblankObject = {}
                for(let f = 0; f < 4; f++) {
                    myblankObject["temperature" + f] = -999
                    myblankObject["iconName" + f] = ""
                    myblankObject['hidden' + f] = true
                }
                return myblankObject
            }

            let offset = 0
            switch (main.timezoneType) {
                case (0):
                    offset = dataSource.data["Local"]["Offset"]
                    break;
                case (1):
                    offset = 0
                    break;
                case (2):
                    offset = currentPlace.timezoneOffset
                    break;
            }

            let wd = readingsArray.properties.timeseries
            let wdPtr = 0
            var localTime =  UnitUtils.convertDate(new Date(wd[wdPtr].time), 2, currentPlace.timezoneOffset)
            var displayTime = UnitUtils.convertDate(new Date(wd[wdPtr].time), main.timezoneType, offset)
            while ((wdPtr < wd.length) && ((displayTime.getHours() - 3) % 6 ) != 0) {

                wdPtr++
                displayTime = UnitUtils.convertDate(new Date(wd[wdPtr].time), main.timezoneType, offset)
            }
            let x = 0
            let y = 0
            let nextDaysData = blankObject()
            let airTemp = -999

            var sunrise1 = UnitUtils.convertDate(currentWeatherModel.sunRise,2,currentPlace.timezoneOffset)
            var sunset1 = UnitUtils.convertDate(currentWeatherModel.sunSet,2,currentPlace.timezoneOffset)
            dbgprint("**********************")
            dbgprint(sunrise1 + "\t" + sunset1)
            var ss = Date.parse(sunset1) / 1000
            var sr = Date.parse(sunrise1) / 1000

            while (wd[wdPtr].data.next_1_hours !== undefined) {
                localTime = UnitUtils.convertDate(new Date(wd[wdPtr].time), 2, currentPlace.timezoneOffset)
                displayTime = UnitUtils.convertDate(new Date(wd[wdPtr].time), main.timezoneType, offset)
                let lt = Date.parse(localTime) / 1000

                while (lt > (sr + 86400)) {
                    dbgprint("+")
                    sr = sr + 86400
                    ss = ss + 86400
                }

                wdPtr++
            }

            if ((y < 3) && (x < 7)) {
                 dailyForecastModel.append(nextDaysData)
            }
            dbgprint("dailyForecastModel Count:" + dailyForecastModel.count)
        }

        function formatTime(ISOdate) {
            return ISOdate.substr(11,5)
        }

        function formatDate(ISOdate) {
            return ISOdate.substr(0,10)
        }

        function composeNextDayTitle(date) {
            return Qt.locale().dayName(date.getDay(), Locale.ShortFormat) + ' ' + date.getDate() + '/' + (date.getMonth() + 1)
        }

        function successSRAS(jsonString) {
            dbgprint2("successSRAS")
            var readingsArray = JSON.parse(jsonString)
            let offset = 0
            switch (main.timezoneType) {
                case (0):
                    offset = dataSource.data["Local"]["Offset"]
                    break;
                case (1):
                    offset = 0
                    break;
                case (2):
                    offset = currentPlace.timezoneOffset
                    break;
            }

            if ((readingsArray.properties !== undefined)) {
                currentWeatherModel.sunRise = new Date(readingsArray.properties.sunrise.time)
                currentWeatherModel.sunSet = new Date(readingsArray.properties.sunset.time)

                currentWeatherModel.sunRiseTime = UnitUtils.convertDate(currentWeatherModel.sunRise, main.timezoneType, offset).toTimeString()
                currentWeatherModel.sunSetTime = UnitUtils.convertDate(currentWeatherModel.sunSet, main.timezoneType, offset).toTimeString()
            }
            dbgprint(JSON.stringify(currentWeatherModel))
            sunRiseSetFlag = true
            var weatherURL = urlPrefix + placeIdentifier
            if (! useOnlineWeatherData) {
                weatherURL = Qt.resolvedUrl('../../code/weather/weather.json')
            }
            dbgprint("Downloading Weather Data from: " + weatherURL)
            var xhr2 = DataLoader.fetchJsonFromInternet(weatherURL, successWeather, failureCallback)
        }

        function failureCallback() {
            dbgprint("DOH!")
            currentWeatherModel = emptyWeatherModel()
            main.loadingDataComplete = true
        }

        function loadCompleted() {
            successCallback()
        }

        function calculateOffset(seconds) {
            let hrs = String("0" + Math.floor(Math.abs(seconds) / 3600)).slice(-2)
            let mins = String("0" + (seconds % 3600)).slice(-2)
            let sign = (seconds >= 0) ? "+" : "-"
            return(sign + hrs + ":" + mins)
        }

    }

    function reloadMeteogramImage(placeIdentifier) {
        main.overviewImageSource = ""
    }

    function geticonNumber(text, forceDay) {
        var parts = text.split("_")
        var baseCode = parts[0]
        var suffix = parts[1] || ""

        var baseIcon = {
            "clearsky": "weather-clear",
            "fair": "weather-few-clouds",
            "partlycloudy": "weather-clouds",
            "cloudy": "weather-clouds",
            "fog": "weather-fog",
            "heavyrain": "weather-showers",
            "heavyrainandthunder": "weather-storm",
            "heavyrainshowers": "weather-showers",
            "heavyrainshowersandthunder": "weather-storm",
            "heavysleet": "weather-sleet",
            "heavysleetandthunder": "weather-storm",
            "heavysleetshowers": "weather-sleet",
            "heavysleetshowersandthunder": "weather-storm",
            "heavysnow": "weather-snow",
            "heavysnowandthunder": "weather-storm",
            "heavysnowshowers": "weather-snow",
            "heavysnowshowersandthunder": "weather-storm",
            "lightrain": "weather-showers-scattered",
            "lightrainandthunder": "weather-storm",
            "lightrainshowers": "weather-showers",
            "lightrainshowersandthunder": "weather-storm",
            "lightsleet": "weather-sleet",
            "lightsleetandthunder": "weather-storm",
            "lightsleetshowers": "weather-sleet",
            "lightsnow": "weather-snow",
            "lightsnowandthunder": "weather-storm",
            "lightsnowshowers": "weather-snow",
            "lightssleetshowersandthunder": "weather-storm",
            "lightssnowshowersandthunder": "weather-storm",
            "rain": "weather-freezing-rain",
            "rainandthunder": "weather-storm",
            "rainshowers": "weather-showers",
            "rainshowersandthunder": "weather-storm",
            "sleet": "weather-sleet",
            "sleetandthunder": "weather-storm",
            "sleetshowers": "weather-sleet",
            "sleetshowersandthunder": "weather-storm",
            "snow": "weather-snow",
            "snowandthunder": "weather-storm",
            "snowshowers": "weather-snow",
            "snowshowersandthunder": "weather-storm"
        }
        var iconName = baseIcon[baseCode]
        if (!iconName) return "weather-none-available"

            // Añadir sufijo nocturno solo para ciertos iconos
            if (suffix === "night" && (baseCode === "clearsky" || baseCode === "fair" || baseCode === "partlycloudy")) {
                return iconName + "-night"
            }

            return iconName
    }

    function windDirection(bearing) {
        var Directions = ['N','NNE','NE','ENE','E','ESE','SE','SSE','S','SSW','SW','WSW','W','WNW','NW','NNW','N']
        var brg = Math.round((bearing + 11.25) / 22.5)
        return(Directions[brg])
    }

    function processDailyForecast(timeseries) {
        console.log("processDailyForecast input length:", timeseries ? timeseries.length : 0)

        var dailyData = {}

        for (var i = 0; i < timeseries.length; i++) {
            var item = timeseries[i]
            var time = item.time
            var date = time.split('T')[0]  // "2026-05-08"
            var temp = item.data.instant.details.air_temperature

            if (temp === undefined || temp === null) continue

                if (!dailyData[date]) {
                    dailyData[date] = {
                        minTemp: temp,
                        maxTemp: temp,
                        date: date,
                        weatherCode: null
                    }
                } else {
                    if (temp < dailyData[date].minTemp) dailyData[date].minTemp = temp
                        if (temp > dailyData[date].maxTemp) dailyData[date].maxTemp = temp
                }

                if (item.data.next_6_hours?.summary?.symbol_code && !dailyData[date].weatherCode) {
                    dailyData[date].weatherCode = item.data.next_6_hours.summary.symbol_code
                }
        }

        // Convertir a array
        var result = []
        for (var date in dailyData) {
            result.push(dailyData[date])
        }

        // ORDENAR POR FECHA (de más antigua a más nueva)
        result.sort(function(a, b) {
            return new Date(a.date) - new Date(b.date)
        })

        // Formatear la fecha para mostrar (solo día/mes)
        for (var d = 0; d < result.length; d++) {
            var dateObj = new Date(result[d].date)
            result[d].date = (dateObj.getDate()) + "/" + (dateObj.getMonth() + 1)
        }

        console.log("processDailyForecast returning", result.length, "days (ordered)")
        return result
    }

    function getConditionDescription(weatherCode) {
        var cleanCode = weatherCode.split("_")[0]

        var descriptions = {
            "clearsky": "Clear sky",
            "cloudy": "Cloudy",
            "fair": "Fair",
            "fog": "Fog",
            "heavyrain": "Heavy rain",
            "lightrain": "Light rain",
            "partlycloudy": "Partly cloudy",
            "rain": "Rain",
            "rainshowers": "Rain showers",
            "snow": "Snow",
            "sleet": "Sleet",
            "wind": "Windy",
            "strongwind": "Strong wind"
        }
        return descriptions[cleanCode] || "Variable conditions"
    }

}
