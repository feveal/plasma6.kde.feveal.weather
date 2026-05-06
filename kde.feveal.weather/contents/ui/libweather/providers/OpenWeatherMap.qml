/*
 * Copyright 2015  Martin Kotelnik <clearmartin@seznam.cz>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick
import QtQml.XmlListModel
import org.kde.plasma.plasma5support as Plasma5Support
import "../../../code/model-utils.js" as ModelUtils
import "../../../code/data-loader.js" as DataLoader
import "../../../code/unit-utils.js" as UnitUtils

Item {
    id: owm

    property string providerId: 'owm'
    property string urlPrefix: 'http://api.openweathermap.org/data/2.5'
    property string appIdAndModeSuffix: '&units=metric&mode=xml&appid=5819a34c58f8f07bc282820ca08948f1'
    property real latitude: 0
    property real longitude: 0
    property string placeIdentifier: ""
    property int timezoneOffset: 0
    property int timezoneType: 0
    property var currentPlace: QtObject {
        property int timezoneOffset: 0
        property string timezoneShortName: ""
    }

    property var dataSource: QtObject {
        property var data: ({
            "Local": { "Offset": 0 }
        })
    }
    property var successCallback: null
    property var failureCallback: null

    property int xmlModelCurrentStatus: xmlModelCurrent.status
    property int xmlModelLongTermStatus: xmlModelLongTerm.status
    property int xmlModelHourByHourStatus: xmlModelHourByHour.status
    property bool xmlModelComplete: (xmlModelCurrent.status === XmlListModel.Ready) && (xmlModelHourByHour.status === XmlListModel.Ready) && (xmlModelLongTerm.status  === XmlListModel.Ready)

    function dbgprint(msg) {
//        console.log("OWM DEBUG:", msg)
    }

    function dbgprint2(msg) {
//        console.log("OWM DEBUG2:", msg)
    }

    function getLocalTimeZone() {
        var offset = -new Date().getTimezoneOffset()
        var hours = Math.floor(offset / 60)
        var minutes = offset % 60
        var sign = hours >= 0 ? "+" : "-"

        if (minutes === 0) {
            return "UTC" + sign + Math.abs(hours)
        } else {
            return "UTC" + sign + Math.abs(hours) + ":" + Math.abs(minutes)
        }
    }

    onXmlModelCompleteChanged: {
        if (xmlModelComplete == false) {
            return
        }
        getTimeZoneName()
        updatecurrentWeather()
        updateNextDaysModel()
        loadCompleted()

        if (owm.successCallback) {
            dbgprint2("Calling successCallback")
            owm.successCallback()
        }
    }

    function parseISOString(s) {
        var b = s.split(/\D+/)
        return new Date(Date.UTC(b[0], --b[1], b[2], b[3], b[4], b[5], b[6]))
    }

    function loadDataFromInternet(successCallback, failureCallback, locationObject) {
        dbgprint2("OWM loadDataFromInternet")
        dbgprint2("placeIdentifier: " + placeIdentifier)

        owm.successCallback = successCallback
        owm.failureCallback = failureCallback

        var loadedData = {
            current: null,
            hourByHour: null,
            longTerm: null
        }
        let url1 = ""
        let url2 = ""
        let url3 = ""

        var versionParam = '&v=' + new Date().getTime()

        // IMPORTANTE: Aquí debe usar placeIdentifier
        url1 = urlPrefix + '/weather?id=' + placeIdentifier + appIdAndModeSuffix + versionParam
        url2 = urlPrefix + '/forecast/daily?id=' + placeIdentifier + '&cnt=9' + appIdAndModeSuffix + versionParam
        url3 = urlPrefix + '/forecast?id=' + placeIdentifier + appIdAndModeSuffix + versionParam

        dbgprint("xmlModelCurrent = " + url1)
        dbgprint("xmlModelLongTerm = " + url2)
        dbgprint("xmlModelHourByHour = " + url3)

        xmlModelCurrent.source = url1
        xmlModelLongTerm.source = url2
        xmlModelHourByHour.source = url3
    }

    function updatecurrentWeather() {
        dbgprint2('updatecurrentWeather (OWM)')

        var now = new Date()
        dbgprint('now: ' + now)

        let obj = xmlModelCurrent.get(0)
        let obj2 = xmlModelHourByHour.get(1)

        var weatherInfo = getWeatherInfo(obj.iconName, currentWeatherModel.isDay === 0)

        // Llenar currentWeatherModel
        currentWeatherModel.temperature = parseFloat(obj.temperature)
        currentWeatherModel.iconName = weatherInfo.iconName
        currentWeatherModel.conditionDescription = weatherInfo.description
        currentWeatherModel.windDirection = parseFloat(obj.windDirection)
        currentWeatherModel.windSpeedMps = parseFloat(obj.windSpeedMps)
        currentWeatherModel.pressureHpa = parseFloat(obj.pressureHpa)
        currentWeatherModel.humidity = parseFloat(obj.humidity)
        currentWeatherModel.cloudiness = parseFloat(obj.cloudiness)
        currentWeatherModel.cityName = obj.cityName

        var weatherInfo = getWeatherInfo(obj.iconName, currentWeatherModel.isDay === 0)

        var weatherInfoFuture = getWeatherInfo(obj2.iconName, currentWeatherModel.isDay === 0)
        currentWeatherModel.nearFutureWeather = {
            iconName: weatherInfoFuture.iconName,
            temperature: parseFloat(obj2.temperature)
        }

        let sunRise = Date.parse(obj.rise)
        let sunSet = Date.parse(obj.set)
        let updated = Date.parse(obj.updated)
        let tzms = parseInt(obj.timezoneOffset) * 1000

        currentPlace.timezoneOffset = parseInt(obj.timezoneOffset)
        currentWeatherModel.sunRiseTime = new Date(sunRise + tzms).toTimeString()
        currentWeatherModel.sunSetTime = new Date(sunSet + tzms).toTimeString()

        currentWeatherModel.isDay = ((updated > sunRise) && (updated < sunSet)) ? 0 : 1

        dbgprint("Updated=" + new Date(updated).toTimeString() +
        "\t Sunrise=" + currentWeatherModel.sunRiseTime +
        "\tSunset=" + currentWeatherModel.sunSetTime + "\t" +
        ((currentWeatherModel.isDay === 0) ? "isDay\n" : "isNight\n"))

        dbgprint2("=== currentWeatherModel values ===")
        dbgprint2("temperature: " + currentWeatherModel.temperature)
        dbgprint2("iconName: " + currentWeatherModel.iconName)
        dbgprint2("windDirection: " + currentWeatherModel.windDirection)
        dbgprint2("humidity: " + currentWeatherModel.humidity)
        dbgprint2("pressureHpa: " + currentWeatherModel.pressureHpa)
        dbgprint2("isDay: " + currentWeatherModel.isDay)
        dbgprint2("=================================")
        dbgprint2('EXIT updatecurrentWeather')


    }

    function updateNextDaysModel() {
        dbgprint2("updateNextDaysModel")

        // Validar xmlModelCurrent
        if (!xmlModelCurrent || xmlModelCurrent.count === 0) {
            dbgprint("updateNextDaysModel: no current data")
            return
        }

        // Validar xmlModelLongTerm
        if (!xmlModelLongTerm || xmlModelLongTerm.count === 0) {
            dbgprint("updateNextDaysModel: no long term data")
            return
        }

        // Obtener updatedDateTime con validación
        var currentData = xmlModelCurrent.get(0)
        if (!currentData || !currentData.updated) {
            dbgprint("updateNextDaysModel: invalid current data")
            return
        }

        function blankObject() {
            const myblankObject={}
            for (let f = 0; f < 4; f++) {
                myblankObject["temperature" + f] = -999
                myblankObject["iconName" + f] = ''
                myblankObject['hidden' + f] = true
                myblankObject['partOfDay' + f] = 0

            }
            return myblankObject
        }

        //        dbgprint2("updateNextDaysModel")
        nextDaysModel.clear()

        var offset = 0
        switch (timezoneType) {
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
        let updatedDateTime = xmlModelCurrent.get(0).updated
        let timezoneOffset = xmlModelCurrent.get(0).timezoneOffset

        let updatedDateTimeStamp = Date.parse(updatedDateTime)
        // let updatedDateTimeStampLocal = convertToLocalTime(Date.parse(updatedDateTime),timezoneOffset * 1000)
        let updatedDateTimeStampLocal = new Date(convertToLocalTime(updatedDateTime + "Z", offset))
        let hr = new Date(updatedDateTimeStampLocal).getHours()
        let y = parseInt((hr + 3) / 6)

        let dataTime = new Date(updatedDateTimeStamp)
        if (isNaN(dataTime.getTime())) {
            dbgprint("updateNextDaysModel: invalid dataTime, usando fecha actual")
            dataTime = new Date()
        }
        dataTime = new Date(dataTime)

        dbgprint("XML Updated At:\t"+ updatedDateTime + "\t" + new Date(updatedDateTimeStamp) + "\t" + new Date(updatedDateTimeStampLocal))
        // dbgprint("XML Updated At:\t"+ t1 + "Z" + militaryGMTOffsetFromNumeric(tz1))
        // let t2 = Date.parse(t1 + "Z" + militaryGMTOffsetFromNumeric(tz1))
        // let t3 = new Date(t2)
        // dbgprint("XML Updated At:\t" + t3 + " (local)")
        // let timeArray = t1.split(/[T:-]/)
        // let hr = parseInt(timeArray[3])
        // let x = 0
        // let y = parseInt((hr + 3) / 6)

        dbgprint2("HR = " + hr + "\tY = " + y)



        let ptr = 0
        let x = 0
        dbgprint("*********************************************************************")
        dbgprint("Parsing Data starting at Row " + ptr + " of xmlModelLongTerm")

        let t = 0
        switch (timezoneType) {
            case (0):
                t =  (dataSource.data["Local"]["Offset"] * 1000) - (timezoneOffset * 1000)
                break;
            case (1):
                t = 0
                break;
            case (2):
                t = (timezoneOffset * 1000)
                break;
        }
        let timeArray=["T03:00:00Z","T09:00:00Z","T15:00:00Z","T21:00:00Z"]
        dbgprint2(t / 3600000)
        let nextDaysData = blankObject()
        while (ptr < xmlModelLongTerm.count) {
            let obj = xmlModelLongTerm.get(ptr)

            dbgprint("Processing row " + ptr + ": date=" + obj.date +
            ", morning=" + obj.temperatureMorning +
            ", day=" + obj.temperatureDay +
            ", evening=" + obj.temperatureEvening +
            ", night=" + obj.temperatureNight)

            for (var i = 0; i < 4; i++) {
                let str=timeArray[i]
                let localtime = convertToLocalTime(obj.date + str,  t)
                let hr = new Date(localtime).getUTCHours()
                let y = parseInt((hr) / 6)
                //                dbgprint(new Date(localtime) + "\t" + new Date(localtime).toUTCString() + "\tt=" + t + "\thr=" + hr + "\ty=" + y)
                //                dbgprint("***" + new Date(updatedDateTimeStamp) + "\t" + localtime)
                if (localtime >= new Date(updatedDateTimeStamp)) {
                    if (y === 0) {
                        nextDaysData['temperature0'] = parseInt(obj.temperatureMorning)
                        nextDaysData['iconName0'] = obj.iconName
                        // nextDaysData['partOfDay' + y] = isDayTime
                        dbgprint("Added data for Row " + (x + 1) + " Column " + (y + 1))
                        nextDaysData['hidden0'] = false
                    }
                    if (y === 1) {
                        nextDaysData['temperature1'] = parseInt(obj.temperatureDay)
                        nextDaysData['iconName1'] = obj.iconName
                        // nextDaysData['partOfDay' + y] = isDayTime
                        //                        dbgprint("Added data for Row " + (x + 1) + " Column " + (y + 1))
                        nextDaysData['hidden1'] = false
                    }
                    if (y === 2) {
                        nextDaysData['temperature2'] = parseInt(obj.temperatureEvening)
                        nextDaysData['iconName2'] = obj.iconName
                        // nextDaysData['partOfDay' + y] = isDayTime
                        dbgprint("Added data for Row " + (x + 1) + " Column " + (y + 1))
                        nextDaysData['hidden2'] = false
                    }
                    if (y === 3) {
                        // Crear una copia independiente de dataTime
                        var newDate = new Date(dataTime)
                        var weatherInfo = getWeatherInfo(obj.iconName, true)

                        var tempLow = parseInt(obj.temperatureMorning)
                        var tempHigh = parseInt(obj.temperatureDay)

                        dbgprint("*** ADDING DAY: " + composeNextDayTitle(newDate))
                        dbgprint("    tempLow (morning): " + tempLow)
                        dbgprint("    tempHigh (day): " + tempHigh)
                        //                        dbgprint("    icon: " + weatherInfo.iconName)

                        nextDaysData['dayLabel'] = composeNextDayTitle(newDate)
                        nextDaysData['tempLow'] = tempLow
                        nextDaysData['tempHigh'] = tempHigh
                        nextDaysData['forecastIcon'] = weatherInfo.iconName
                        nextDaysData['hidden3'] = false
                        nextDaysModel.append(nextDaysData)
                        nextDaysData = blankObject()
                        x++

                        // Incrementar dataTime en 1 día
                        var newTime = new Date(dataTime)
                        newTime.setDate(dataTime.getDate() + 1)
                        dataTime = newTime
                    }
                }
            }
            ptr++
        }

        x = 0
        y = 0
        ptr = 0
        nextDaysData=blankObject()
        var offset = 0
        switch (timezoneType) {
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

        dbgprint2("***************************************************")
        while (ptr < xmlModelHourByHour.count) {
            let obj = xmlModelHourByHour.get(ptr)
            dbgprint(obj.from)
            let t = convertToLocalTime(obj.from, offset * 1000)
            let h = 3 + (parseInt(t.getHours() / 6) * 6)
            y = parseInt(h / 6)
            //            dbgprint("GetHours=" + t.getHours() + "\th=" + h + "\ty=" + y)

            // Verificar que existe el elemento antes de usarlo
            if (x < nextDaysModel.count) {
                var existingItem = nextDaysModel.get(x)
                if (existingItem && existingItem.dayLabel) {
                    nextDaysData['dayLabel'] = existingItem.dayLabel
                } else {
                    nextDaysData['dayLabel'] = "?"
                }
            } else {
                nextDaysData['dayLabel'] = "?"
            }

            var weatherInfo = getWeatherInfo(obj.iconName, true)
            nextDaysData['forecastIcon'] = weatherInfo.iconName

            nextDaysData['tempLow'] = parseInt(obj.temperature)  // Temperatura como mínima
            nextDaysData['tempHigh'] = parseInt(obj.temperature) // Temperatura como máxima
            nextDaysData['hidden' + y] = false

            if (y === 3) {
                //                dbgprint("*** Replaced ROW " + x + "\t" + nextDaysData['dayLabel'])
                if (x < nextDaysModel.count) {
                    nextDaysModel.remove(x, 1)
                    nextDaysModel.insert(x, nextDaysData)
                } else {
                    nextDaysModel.append(nextDaysData)
                }
                nextDaysData = blankObject()
                x++
                y = 0
            }
            ptr = ptr + 2
        }
        //        dbgprint("nextDaysModel Count:" + nextDaysModel.count)
        dbgprint2("EXIT updateNextDaysModel")
    }

    function convertToLocalTime(dateString, timezoneOffset) {
        if (!dateString) {
            dbgprint("convertToLocalTime: empty dateString")
            return new Date()
        }

        var timestamp
        if (dateString instanceof Date) {
            timestamp = dateString.getTime()
        } else if (typeof dateString === 'string') {
            timestamp = Date.parse(dateString)
        } else {
            timestamp = dateString
        }

        if (isNaN(timestamp)) {
            dbgprint("convertToLocalTime: invalid timestamp")
            return new Date()
        }

        return new Date(timestamp + timezoneOffset)
    }

    function composeNextDayTitle(date) {
        // Asegurar que date es un objeto Date
        if (!(date instanceof Date)) {
            date = new Date(date)
        }

        if (isNaN(date.getTime())) {
            dbgprint("composeNextDayTitle: invalid date")
            return "?"
        }

        var dayName = Qt.locale().dayName(date.getDay(), Locale.ShortFormat)
        var dayNum = date.getDate()
        var monthNum = date.getMonth() + 1
        var result = dayName + ' ' + dayNum + '/' + monthNum
        dbgprint2("composeNextDayTitle result: " + result)
        return result
    }

    function getCreditLabel(placeIdentifier) {
        return i18n("Forecast data provided by OpenWeather")
    }

    function getCreditLink(placeIdentifier) {
        return 'http://openweathermap.org/city/' + placeIdentifier
    }

    function getTimeZoneName() {
        dbgprint2("getTimeZoneName")
        switch (timezoneType) {
            case 0:
                currentPlace.timezoneShortName = getLocalTimeZone()
                break
            case 1:
                currentPlace.timezoneShortName =  i18n("UTC")
                break
            case 2:
                currentPlace.timezoneShortName = getLocalTimeZone()
                break
        }
        dbgprint("timezoneName changed to:" + currentPlace.timezoneShortName)
    }

    function localTime(date){
        let t = Date.parse(date) + parseInt(currentPlace.timezoneOffset)
        return new Date(t)
    }
    function formatTime(ISOdate) {
        return ISOdate.substr(11,5)
    }

    function loadCompleted() {
        //       main.loadingDataComplete = true
        dbgprint2("loadCompleted - OWM data loaded")
        //       dataLoadedFromInternet()
    }

    XmlListModel {
        id: xmlModelCurrent
        query: "/current"

        XmlListModelRole { name: "temperature"; elementName: "temperature"; attributeName: "value" }
        XmlListModelRole { name: "iconName"; elementName: "weather"; attributeName: "number" }
        XmlListModelRole { name: "humidity"; elementName: "humidity"; attributeName: "value" }
        XmlListModelRole { name: "pressureHpa"; elementName: "pressure"; attributeName: "value" }
        XmlListModelRole { name: "windSpeedMps"; elementName: "wind/speed"; attributeName: "value" }
        XmlListModelRole { name: "windDirection"; elementName: "wind/direction"; attributeName: "value" }
        XmlListModelRole { name: "cloudiness"; elementName: "clouds"; attributeName: "value" }
        XmlListModelRole { name: "updated"; elementName: "lastupdate"; attributeName: "value" }
        XmlListModelRole { name: "rise"; elementName: "city/sun"; attributeName: "rise" }
        XmlListModelRole { name: "set"; elementName: "city/sun"; attributeName: "set" }
        XmlListModelRole { name: "cityName"; elementName: "city"; attributeName: "name"  }
        XmlListModelRole { name: "timezoneOffset"; elementName: "city/timezone" }

        function get(i) {
            var o = {}
            for (var j = 0; j < roles.length; ++j)
            {
                o[roles[j].name] = data(index(i,0), Qt.UserRole + j)
            }
            return o
        }
    }
    onXmlModelCurrentStatusChanged: {
        if (xmlModelCurrent.status == XmlListModel.Error) {
            dbgprint(xmlModelCurrent.errorString())
            if (owm.failureCallback) {
                owm.failureCallback(xmlModelCurrent.errorString())
            }
        }
        if (xmlModelCurrent.status != XmlListModel.Ready) {
            return
        } else {
            dbgprint("***xmlModelCurrent Done***")
        }
    }


    XmlListModel {
        id: xmlModelLongTerm
        query: '/weatherdata/forecast/time'
        XmlListModelRole { name: "date"; elementName: ""; attributeName: "day"  }
        XmlListModelRole { name: "temperatureMorning"; elementName: "temperature"; attributeName: "morn"  }
        XmlListModelRole { name: "temperatureDay"; elementName: "temperature"; attributeName: "day"  }
        XmlListModelRole { name: "temperatureEvening"; elementName: "temperature"; attributeName: "eve"  }
        XmlListModelRole { name: "temperatureNight"; elementName: "temperature"; attributeName: "night"  }
        XmlListModelRole { name: "iconName"; elementName: "symbol"; attributeName: "number"  }
        XmlListModelRole { name: "windDirection"; elementName: "windDirection"; attributeName: "deg"  }
        XmlListModelRole { name: "windSpeedMps"; elementName: "windSpeed"; attributeName: "mps"  }
        XmlListModelRole { name: "pressureHpa"; elementName: "pressure"; attributeName: "value"  }

        function get(i) {
            var o = {}
            for (var j = 0; j < roles.length; ++j)
            {
                o[roles[j].name] = data(index(i,0), Qt.UserRole + j)
            }
            return o
        }
    }
    onXmlModelLongTermStatusChanged: {
        if (xmlModelLongTerm.status == XmlListModel.Error) {
            dbgprint(xmlModelLongTerm.errorString())
        }
        if (xmlModelLongTerm.status != XmlListModel.Ready) {
            return
        } else {
            dbgprint("***xmlModelLongTerm Done***")
        }
    }

    XmlListModel {
        id: xmlModelHourByHour
        query: '/weatherdata/forecast/time'
        XmlListModelRole { name: "from"; elementName: ""; attributeName: "from"  }
        XmlListModelRole { name: "to"; elementName: ""; attributeName: "to"  }
        XmlListModelRole { name: "temperature"; elementName: "temperature"; attributeName: "value"  }
        XmlListModelRole { name: "iconName"; elementName: "symbol"; attributeName: "number"  }
        XmlListModelRole { name: "windDirection"; elementName: "windDirection"; attributeName: "deg"  }
        XmlListModelRole { name: "windSpeedMps"; elementName: "windSpeed"; attributeName: "mps"  }
        XmlListModelRole { name: "pressureHpa"; elementName: "pressure"; attributeName: "value"  }

        function get(i) {
            var o = {}
            for (var j = 0; j < roles.length; ++j)
            {
                o[roles[j].name] = data(index(i,0), Qt.UserRole + j)
            }
            return o
        }
    }
    onXmlModelHourByHourStatusChanged: {
        dbgprint("xmlModelHourByHour: " + xmlModelHourByHour.status)
        if (xmlModelHourByHour.status == XmlListModel.Error) {
            dbgprint(xmlModelHourByHour.errorString())
        }
        if (xmlModelHourByHour.status != XmlListModel.Ready) {
            return
        } else {
            dbgprint("***xmlModelHourByHour Done***")
        }
    }

    // ---
    // ================================================================
    // Modelos para exportar a WeatherData.qml
    // ================================================================

    property alias currentWeatherModel: currentWeatherModel
    property alias nextDaysModel: nextDaysModel
//    property alias meteogramModel: meteogramModel

    QtObject {
        id: currentWeatherModel
        property real temperature: 0
        property string iconName: ""
        property string conditionDescription: ""
        property string cityName: ""
        property real windDirection: 0
        property real windSpeedMps: 0
        property real pressureHpa: 0
        property real humidity: 0
        property real cloudiness: 0
        property int isDay: 0
        property var sunRise: null
        property var sunSet: null
        property string sunRiseTime: ""
        property string sunSetTime: ""
        property string updated: ""
        property var nearFutureWeather: ({})
    }

    ListModel {
        id: nextDaysModel
    }

    // Función que devuelve objeto con icono y descripción
    function getWeatherInfo(owmCode, isDay) {
        var code = parseInt(owmCode)
        var info = {
            iconName: "weather-none-available",
            description: "Weather data available"
        }

        if (isNaN(code)) {
//            console.log("getWeatherInfo: invalid code", owmCode)
            return info
        }

        // Determinar sufijo según día/noche
        var suffix = isDay ? "" : "-night"

        // Despejado
        if (code === 800) {
            info.iconName = "weather-clear"
            info.description = "Clear sky"
            return info
        }

        // Poco nublado
        if (code === 801) {
            info.iconName = "weather-few-clouds"
            info.description = "Few clouds"
            return info
        }

        // Nublado
        if (code === 802 || code === 803) {
            info.iconName = "weather-clouds"
            info.description = "Cloudy"
            return info
        }

        // Muy nublado
        if (code === 804) {
            info.iconName = "weather-overcast"
            info.description = "Overcast"
            return info
        }

        // Llovizna
        if (code >= 300 && code <= 399) {
            info.iconName = "weather-drizzle"
            info.description = "Drizzle"
            return info
        }

        // Lluvia
        if (code >= 500 && code <= 531) {
            info.iconName = "weather-showers"
            info.description = "Rain"
            return info
        }

        // Tormenta
        if (code >= 200 && code <= 232) {
            info.iconName = "weather-storm"
            info.description = "Thunderstorm"
            return info
        }

        // Nieve
        if (code >= 600 && code <= 622) {
            info.iconName = "weather-snow"
            info.description = "Snow"
            return info
        }

        // Niebla
        if (code >= 700 && code <= 781) {
            info.iconName = "weather-fog"
            info.description = "Fog"
            return info
        }

        return info
    }

}
