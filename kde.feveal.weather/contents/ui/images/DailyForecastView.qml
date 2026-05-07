import QtQuick
import QtQuick.Layouts

GridLayout {
	id: testView
	columns: 5

	readonly property int minMaxFontSize: plasmoid.configuration.minMaxFontSize || 12
	readonly property int dateFontSize: plasmoid.configuration.dateFontSize || 10

	property var model: null

		GridLayout {
			columns: 1

			Text {
				text: {
					var model = weatherData.dailyForecastModel
					if (!model || model.count < 1) return "No data"
						var item = model.get(1)
						if (!item) return "No data"
						return (item.dayLabel)
				}
				Layout.alignment: Qt.AlignHCenter
				color: plasmoid.configuration.textColor || "white"
				font.pixelSize: dateFontSize
			}

			Image {
				source: {
					var model = weatherData.dailyForecastModel
					if (!model || model.count < 1) return ""
						var item = model.get(1)
						if (!item) return ""
						return item.forecastIcon
				}
				Layout.preferredWidth: 64 * scaleFactor
				Layout.preferredHeight: 50 * scaleFactor
			}

			Text {
				text: {
					var model = weatherData.dailyForecastModel
					if (!model || model.count < 1) return "No data"
						var item = model.get(1)
						if (!item) return "No data"
						return (item.tempLow + "°")
				}
				Layout.alignment: Qt.AlignHCenter
				color: plasmoid.configuration.textColor || "white"
				font.pixelSize: minMaxFontSize
			}

			Text {
				text: {
					var model = weatherData.dailyForecastModel
					if (!model || model.count < 1) return "No data"
						var item = model.get(1)
						if (!item) return "No data"
							return (item.tempHigh + "°")
				}
				Layout.alignment: Qt.AlignHCenter
				color: plasmoid.configuration.textColor || "white"
				font.pixelSize: minMaxFontSize
			}

		}

		GridLayout {
			columns: 1
			Text {
				text: {
					var model = weatherData.dailyForecastModel
					if (!model || model.count < 2) return "No data"
						var item = model.get(2)
						if (!item) return "No data"
						return (item.dayLabel)
				}
				Layout.alignment: Qt.AlignHCenter
				color: plasmoid.configuration.textColor
				font.pixelSize: dateFontSize
			}

			Image {
				source: {
					var model = weatherData.dailyForecastModel
					if (!model || model.count < 2) return ""
						var item = model.get(2)
						if (!item) return ""
						return item.forecastIcon
				}
				Layout.preferredWidth: 64 * scaleFactor
				Layout.preferredHeight: 50 * scaleFactor
			}

			Text {
				text: {
					var model = weatherData.dailyForecastModel
					if (!model || model.count < 2) return "No data"
						var item = model.get(2)
						if (!item) return "No data"
						return (item.tempLow + "°")
				}
				Layout.alignment: Qt.AlignHCenter
				color: plasmoid.configuration.textColor
				font.pixelSize: minMaxFontSize
			}

			Text {
				text: {
					var model = weatherData.dailyForecastModel
					if (!model || model.count < 2) return "No data"
						var item = model.get(2)
						if (!item) return "No data"
							return (item.tempHigh + "°")
				}
				Layout.alignment: Qt.AlignHCenter
				color: plasmoid.configuration.textColor
				font.pixelSize: minMaxFontSize
			}
		}

		GridLayout {
			columns: 1
			Text {
				text: {
					var model = weatherData.dailyForecastModel
					if (!model || model.count < 3) return "No data"
						var item = model.get(3)
						if (!item) return "No data"
						return (item.dayLabel)
				}
				Layout.alignment: Qt.AlignHCenter
				color: plasmoid.configuration.textColor
				font.pixelSize: dateFontSize
			}

			Image {
				source: {
					var model = weatherData.dailyForecastModel
					if (!model || model.count < 3) return ""
						var item = model.get(3)
						if (!item) return ""
						return item.forecastIcon
				}
				Layout.preferredWidth: 64 * scaleFactor
				Layout.preferredHeight: 50 * scaleFactor
			}

			Text {
				text: {
					var model = weatherData.dailyForecastModel
					if (!model || model.count < 3) return "No data"
						var item = model.get(3)
						if (!item) return "No data"
						return (item.tempLow + "°")
				}
				Layout.alignment: Qt.AlignHCenter
				color: plasmoid.configuration.textColor
				font.pixelSize: minMaxFontSize
			}

			Text {
				text: {
					var model = weatherData.dailyForecastModel
					if (!model || model.count < 3) return "No data"
						var item = model.get(3)
						if (!item) return "No data"
							return (item.tempHigh + "°")
				}
				Layout.alignment: Qt.AlignHCenter
				color: plasmoid.configuration.textColor
				font.pixelSize: minMaxFontSize
			}
		}

		GridLayout {
			columns: 1
			Text {
				text: {
					var model = weatherData.dailyForecastModel
					if (!model || model.count < 4) return "No data"
						var item = model.get(4)
						if (!item) return "No data"
							return (item.dayLabel)
				}
				Layout.alignment: Qt.AlignHCenter
				color: plasmoid.configuration.textColor
				font.pixelSize: dateFontSize
			}

			Image {
				source: {
					var model = weatherData.dailyForecastModel
					if (!model || model.count < 4) return ""
						var item = model.get(4)
						if (!item) return ""
							return item.forecastIcon
				}
				Layout.preferredWidth: 64 * scaleFactor
				Layout.preferredHeight: 50 * scaleFactor
			}

			Text {
				text: {
					var model = weatherData.dailyForecastModel
					if (!model || model.count < 4) return "No data"
						var item = model.get(4)
						if (!item) return "No data"
							return (item.tempLow + "°")
				}
				Layout.alignment: Qt.AlignHCenter
				color: plasmoid.configuration.textColor
				font.pixelSize: minMaxFontSize
			}

			Text {
				text: {
					var model = weatherData.dailyForecastModel
					if (!model || model.count < 4) return "No data"
						var item = model.get(4)
						if (!item) return "No data"
							return (item.tempHigh + "°")
				}
				Layout.alignment: Qt.AlignHCenter
				color: plasmoid.configuration.textColor
				font.pixelSize: minMaxFontSize
			}
		}

		GridLayout {
			columns: 1
			Text {
				text: {
					var model = weatherData.dailyForecastModel
					if (!model || model.count < 5) return "No data"
						var item = model.get(5)
						if (!item) return "No data"
							return (item.dayLabel)
				}
				Layout.alignment: Qt.AlignHCenter
				color: plasmoid.configuration.textColor
				font.pixelSize: dateFontSize
			}

			Image {
				source: {
					var model = weatherData.dailyForecastModel
					if (!model || model.count < 5) return ""
						var item = model.get(5)
						if (!item) return ""
							return item.forecastIcon
				}
				Layout.preferredWidth: 64 * scaleFactor
				Layout.preferredHeight: 50 * scaleFactor
			}

			Text {
				text: {
					var model = weatherData.dailyForecastModel
					if (!model || model.count < 5) return "No data"
						var item = model.get(5)
						if (!item) return "No data"
							return (item.tempLow + "°")
				}
				Layout.alignment: Qt.AlignHCenter
				color: plasmoid.configuration.textColor
				font.pixelSize: minMaxFontSize
			}

			Text {
				text: {
					var model = weatherData.dailyForecastModel
					if (!model || model.count < 5) return "No data"
						var item = model.get(5)
						if (!item) return "No data"
							return (item.tempHigh + "°")
				}
				Layout.alignment: Qt.AlignHCenter
				color: plasmoid.configuration.textColor
				font.pixelSize: minMaxFontSize
			}
		}
}

