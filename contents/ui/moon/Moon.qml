// Moon.qml
import QtQuick
import QtQuick.Layouts

Item {
    id: moon
    opacity: 0.01
    x: 72 * scaleFactor
    y: 168 * scaleFactor

    // --- Container for image and background (scale)
    Item {
        id: moonVisual
        anchors.centerIn: parent
        scale: 1.0

        Image {
            id: moonImage
            width: 25 * scaleFactor
            height: 25 * scaleFactor
            x: -10 * scaleFactor
            y: 2 * scaleFactor
            z: 2
            opacity: 1
            source: "../moon/" + moonPhase + ".png"

            MouseArea {
                id: mouseMoon
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    moonData.state = moonData.state === "clicked" ? "" : "clicked";
                }
            }

            Rectangle {
                id: backgroundRect
                width: 60 * scaleFactor
                height: 15 * scaleFactor
                color: "lightgray"
                radius: 2 * scaleFactor
                x: moonLabelIlu.x - 5 * scaleFactor
                y: moonLabelIlu.y + 24 * scaleFactor

            }
        }
    }

    // Content text
    Column {
        id: moonTexts
        x: -35 * scaleFactor
        y: 80 * scaleFactor
        z: 3

        opacity: moonData.state === "clicked" ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }

        Text {
            id: moonLabelIlu

            color: "black"
            font.pixelSize: 12 * scaleFactor
            text: i18n(moonPhase) + i18n(" Lightning: ") + percentIlu + "%"
        }

        Text {
            id: moonDaysPhase
            color: "black"
            font.pixelSize: 12 * scaleFactor
            text: daysPhase + i18n(" days for ") + i18n(nextPhase)
        }
    }

    // --- State and Transitions
    Item {
        id: moonData
        states: [
            State {
                name: "clicked"
                PropertyChanges {
                    target: moonVisual
                    scale: 3
                }
                PropertyChanges {
                    target: moon
                    opacity: 1
                    x: -120 * scaleFactor
                    y: 40 * scaleFactor
                }
            }
        ]

        transitions: [
            Transition {
                from: "clicked"; to: "*"
                NumberAnimation { properties: "scale, opacity"; duration: 2000 }
                NumberAnimation { properties: "x, y"; duration: 700 }
            },
            Transition {
                from: "*"; to: "clicked"
                NumberAnimation { properties: "scale, opacity"; duration: 700 }
                NumberAnimation { properties: "x, y"; duration: 2000 }
            }
        ]
    }
}



