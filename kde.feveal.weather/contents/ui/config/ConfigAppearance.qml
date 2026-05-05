import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

import "../libconfig" as LibConfig
import "../libweather" as LibWeather

KCM.SimpleKCM {

    id: appearancePage

    GridLayout {
        columns: 2
        Layout.fillWidth: true
        Label {
            text: i18n("Font Family:")
        }

        RowLayout {
            LibConfig.FontFamily {
                configKey: 'fontFamily'
            }
            LibConfig.TextFormat {
                boldConfigKey: 'bold'
            }
        }

        Label {
            text: i18n("Forecast:")
        }
        LibConfig.SpinBox {
            Layout.columnSpan: 1
            configKey: "forecastFontSize"
            suffix: i18nc("font size suffix", "pt")
        }

        Label {
            text: i18n("Temp:")
        }
        LibConfig.SpinBox {
            Layout.columnSpan: 1
            configKey: "tempFontSize"
            suffix: i18nc("font size suffix", "pt")
        }

        Label {
            text: i18n("Date:")
        }
        LibConfig.SpinBox {
            Layout.columnSpan: 1
            configKey: "dateFontSize"
            suffix: i18nc("font size suffix", "pt")
        }

        Label {
            text: i18n("Min/Max Temp:")
        }
        LibConfig.SpinBox {
            Layout.columnSpan: 1
            configKey: "minMaxFontSize"
            suffix: i18nc("font size suffix", "pt")
        }

        Label {
            text: i18n("Details:")
        }
        LibConfig.SpinBox {
            Layout.columnSpan: 1
            configKey: "detailsFontSize"
            suffix: i18nc("font size suffix", "pt")
        }

        Label {
            text: i18n("Text Color:")
        }
        LibConfig.ColorField {
            Layout.columnSpan: 1
            configKey: "textColor"
        }

        Label {
            text: i18n("Outline:")
        }
        RowLayout {
            Layout.columnSpan: 1
            LibConfig.CheckBox {
                id: showOutline
                configKey: "showOutline"
            }
            LibConfig.ColorField {
                configKey: "outlineColor"
                enabled: showOutline.checked
            }
        }


    }
}
