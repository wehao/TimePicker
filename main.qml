import QtQuick 2.6
import QtQuick.Controls 1.5

ApplicationWindow {
    visible: true
    width: 300
    height: 440
    title: qsTr("Hello World")

    TimePicker {
        id: timePicker
    }

}
