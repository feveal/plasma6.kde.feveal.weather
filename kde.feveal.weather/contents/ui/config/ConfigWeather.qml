// config/ConfigWeather.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM  {
    id: page

    property alias cfg_locationId: locationField.text
    property alias cfg_cityName: cityNameField.text
    property alias cfg_latitude: latitudeField.text
    property alias cfg_longitude: longitudeField.text
    property alias cfg_altitude: altitudeField.text
//    property int cfg_showNumDays: 5
    property int cfg_updateInterval: 30
    property string cfg_fontFamily: ""
    property int cfg_tempFontSize: 40
    property int cfg_forecastFontSize: 12
    property int cfg_dateFontSize: 12
    property int cfg_detailsFontSize: 12
    property bool cfg_showBackground: true
    property bool cfg_showDailyBackground: false
    property bool cfg_showDetails: true
    property bool cfg_showOutline: false
    property bool cfg_bold: false
    property string cfg_textColor: ""
    property string cfg_outlineColor: ""
    property int cfg_temperatureUnitId: 0
    property int cfg_windSpeedUnitId: 0
    property int cfg_pressureUnitId: 0
    property int cfg_visibilityUnitId: 0
    property int cfg_timezoneOffset: 2
    property string cfg_provider: "metno"
    property bool cfg_showMinTempBelow: true
    property int cfg_minMaxFontSize: 12
    property string cfg_showBackgroundDefault: "true"
    property int cfg_updateIntervalDefault: 30


    contentItem: ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        Kirigami.FormLayout {
            Layout.fillWidth: true

            ComboBox {
                id: providerCombo
                Kirigami.FormData.label: i18n("Weather provider:")
                model: [
                    { text: "MET Norway (yr.no)", value: "metno" },
                    { text: "OpenWeatherMap", value: "owm" }
                ]
                textRole: "text"
                valueRole: "value"
                currentIndex: {
                    for (var i = 0; i < model.length; i++) {
                        if (model[i].value === cfg_provider) return i
                    }
                    return 0
                }
                onCurrentValueChanged: {
                    cfg_provider = currentValue
                    // Limpiar campos al cambiar de proveedor
                    if (providerCombo.currentValue === "metno") {
                        var lat = parseFloat(latitudeField.text) || 0
                        var lon = parseFloat(text) || 0
                        var alt = parseFloat(altitudeField.text) || 0
                        if (lat !== 0 || lon !== 0) {
                            locationField.text = "lat=" + lat + "&lon=" + lon + "&altitude=" + alt
                            cfg_locationId = locationField.text
                        }
                    } else if (currentValue === "om") {
                        // Construir locationId desde lat/lon
                        var lat2 = parseFloat(latitudeField.text) || 0
                        var lon2 = parseFloat(longitudeField.text) || 0
                        if (lat2 !== 0 || lon2 !== 0) {
                            locationField.text = "latitude=" + lat2 + "&longitude=" + lon2
                        }
                    }
                }
            }

            TextField {
                id: cityNameField
                Kirigami.FormData.label: i18n("City name:")
                placeholderText: "e.g., Burgos"
                text: plasmoid.configuration.cityName || ""
                enabled: providerCombo.currentValue === "metno"
                onTextChanged: {
                    plasmoid.configuration.cityName = text
//                    console.log("City name saved:", text, "→ config:", plasmoid.configuration.cityName)
                }
            }

            // Campo Coordinates - solo visible para MET Norway y OpenWeatherMap
            TextField {
                id: locationField
                Kirigami.FormData.label: i18n("City ID:")
                placeholderText: "City ID (e.g., 3127461)"
                enabled: providerCombo.currentValue === "owm"
                visible: providerCombo.currentValue === "owm"
                onTextChanged: {
                    if (providerCombo.currentValue === "owm") {
                        cfg_locationId = text
                    }
                }
            }

            // Campo Latitude - visible y editable para MET Norway y Open-Meteo
            TextField {
                id: latitudeField
                Kirigami.FormData.label: i18n("Latitude:")
                placeholderText: "e.g. 42.3410"
                enabled: providerCombo.currentValue === "metno" || providerCombo.currentValue === "om"
                visible: true
                onTextChanged: {
                    cfg_latitude = text
                    // Para MET Norway, construir locationId
                    if (providerCombo.currentValue === "metno") {
                        var lat = parseFloat(text) || 0
                        var lon = parseFloat(longitudeField.text) || 0
                        if (lat !== 0 || lon !== 0) {
                            locationField.text = "lat=" + lat + "&lon=" + lon + "&altitude=0"
                            cfg_locationId = locationField.text
                        }
                    }
                    // Para Open-Meteo, construir locationId
                    if (providerCombo.currentValue === "om") {
                        var lat2 = parseFloat(text) || 0
                        var lon2 = parseFloat(longitudeField.text) || 0
                        if (lat2 !== 0 || lon2 !== 0) {
                            locationField.text = "latitude=" + lat2 + "&longitude=" + lon2
                            cfg_locationId = locationField.text
                        }
                    }
                }
            }

            // Campo Longitude - visible y editable para MET Norway y Open-Meteo
            TextField {
                id: longitudeField
                Kirigami.FormData.label: i18n("Longitude:")
                placeholderText: "e.g. -3.7018"
                enabled: providerCombo.currentValue === "metno"
                visible: true
                onTextChanged: {
                    cfg_longitude = text
                    // Para MET Norway, construir locationId
                    if (providerCombo.currentValue === "metno") {
                        var lat = parseFloat(latitudeField.text) || 0
                        var lon = parseFloat(text) || 0
                        if (lat !== 0 || lon !== 0) {
                            locationField.text = "lat=" + lat + "&lon=" + lon + "&altitude=0"
                            cfg_locationId = locationField.text
                        }
                    }
                    // Para Open-Meteo, construir locationId
                    if (providerCombo.currentValue === "om") {
                        var lat2 = parseFloat(latitudeField.text) || 0
                        var lon2 = parseFloat(text) || 0
                        if (lat2 !== 0 || lon2 !== 0) {
                            locationField.text = "latitude=" + lat2 + "&longitude=" + lon2
                            cfg_locationId = locationField.text
                        }
                    }
                }
            }

            // Campo Altitude - para MET Norway
            TextField {
                id: altitudeField
                Kirigami.FormData.label: i18n("Altitude (meters):")
                placeholderText: "e.g. 856"
                enabled: providerCombo.currentValue === "metno"
                visible: true
                text: plasmoid.configuration.altitude || "0"
                onTextChanged: {
                    cfg_altitude = text
                    // Reconstruir locationId para MET Norway
                    if (providerCombo.currentValue === "metno") {
                        var lat = parseFloat(latitudeField.text) || 0
                        var lon = parseFloat(longitudeField.text) || 0
                        var alt = parseFloat(text) || 0
                        if (lat !== 0 || lon !== 0) {
                            locationField.text = "lat=" + lat + "&lon=" + lon + "&altitude=" + alt
                            cfg_locationId = locationField.text
                        }
                    }
                }
            }

            // metno
            ColumnLayout {
                visible: providerCombo.currentValue === "metno"
                spacing: Kirigami.Units.smallSpacing

                Label {
                    id: attribution1
                    font: Kirigami.Theme.smallFont
                    text: i18n("Met.no forecast data provided by The Norwegian Meteorological Institute")
                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: attribution1
                        hoverEnabled: true
                        onClicked: {
                            Qt.openUrlExternally('https://www.met.no/en/About-us')
                        }
                        onEntered: {
                            attribution1.font.underline = true
                        }
                        onExited: {
                            attribution1.font.underline = false
                        }
                    }
                }

                Label {
                    id: geonamesInfo
                    font: Kirigami.Theme.smallFont
                    text: i18n("Find your city data by searching here") + ":"
                }

                Label {
                    id: geonamesLink
                    font: Kirigami.Theme.smallFont
                    text: 'https://www.geonames.org/'

                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Qt.openUrlExternally('https://www.geonames.org/')
                        onEntered: parent.font.underline = true
                        onExited: parent.font.underline = false
                    }
                }

                Label {
                    id: geonamesInfo2
                    font: Kirigami.Theme.smallFont
                    text: i18n("and then paste the appropriate data into the corresponding fields")
                }
                Label {
                    id: geonamesInfo3
                    font: Kirigami.Theme.smallFont
                    text: i18n("e.g. Latitude: 40.4165 Longitude: -3.7025 Altitude: 665")
                }
                Label {
                    id: geonamesInfo4
                    font: Kirigami.Theme.smallFont
                    text: i18n("for Madrid City, Spain")
                }
                Label {
                    id: geonamesInfo5
                    font: Kirigami.Theme.smallFont
                    text: i18n(" (Maximum of 4 decimal places)")
                }
            }

            // owm
            ColumnLayout {
                visible: providerCombo.currentValue === "owm"
                spacing: Kirigami.Units.smallSpacing

                Label {
                    id: owmprovider1
                    text: i18n("OWM forecast data provided by OpenWeather")

                     MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Qt.openUrlExternally('https://openweathermap.org/about-us')
                        onEntered: parent.font.underline = true
                        onExited: parent.font.underline = false
                    }
                }

                Label {
                    id: owmprovider2
                    text: i18n("Find your City ID at: https://openweathermap.org/find")

                     MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Qt.openUrlExternally('https://openweathermap.org/find')
                        onEntered: parent.font.underline = true
                        onExited: parent.font.underline = false
                    }
                }
            }
        }

        Kirigami.Separator { Layout.fillWidth: true }

        Kirigami.FormLayout {

            SpinBox {
                id: updateIntervalSpin
                Kirigami.FormData.label: i18n("Update interval (minutes):")
                from: 15
                to: 240
                stepSize: 15
                value: cfg_updateInterval
                onValueChanged: cfg_updateInterval = value
            }
/*
            SpinBox {
                id: numDaysSpin
                Kirigami.FormData.label: i18n("Number of forecast days:")
                from: 1
                to: 5
                value: cfg_showNumDays
                onValueChanged: cfg_showNumDays = value
            }
*/
        }
    }
}
