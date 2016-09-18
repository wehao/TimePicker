import QtQuick 2.0
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

FocusScope {
    id: timePicker
    width: 300
    height: 400
    visible: true

    property real clockPadding: 24
    property bool  isZeroBased: true
    property bool isHours: true
    property bool prefer24Hour: false

    Column {
        id: column
        anchors.fill: parent
        width: parent.width
        height: parent.height
        Rectangle {
            id: titleRec
            width: parent.width
            height: 80
            color: "lightyellow"

            Row {
                id: row
                anchors.centerIn: parent
                height: parent.height/2

                Label {
                    id: hourLabel
                    anchors.verticalCenter: parent.verticalCenter
                    text: "24"
                    font.pixelSize: 56

                    MouseArea {

                    }
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: ":"
                    font.pixelSize: 56

                    MouseArea {

                    }
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "59"
                    font.pixelSize: 56

                    MouseArea {

                    }
                }
            }

            Column {
                id: amandpm
                    anchors {
                        bottom: row.bottom
                        left: row.right
                        leftMargin: 12
                    }

                    spacing: 2

                Label {
                    text: "AM"
                    font.pixelSize: 16

                    MouseArea {

                    }
                }

                Label {
                    text: "PM"
                    font.pixelSize: 16

                    MouseArea {

                    }
                }
            }
        }

        Rectangle {
            id: picker
            width: parent.width
            height: width
            //border.color: "red"
            Rectangle {
                id: circle
                anchors.centerIn: parent
                width: parent.width * 0.9
                height: width
                radius: width/2
                color: "#eee"

                Rectangle {
                    id: centerPoint
                    anchors.centerIn: parent
                    width: 8
                    height: width
                    radius: width/2
                    color: "red"
                    antialiasing: true
                }

                Rectangle {
                    id: pointer
                    width: 2
                    height: circle.width/2 - clockPadding
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: clockPadding
                    color: "red"
                    transformOrigin: Item.Bottom

//                    Connections {
//                        target: pathView
//                        onCurrentIndexChanged: {
//                            if(isHours)
//                                pointer.setAngle()
//                        }
//                    }

                }



                Behavior on rotation {
                    RotationAnimation {
                        id: pointerRotation
                        duration: 200
                        direction: RotationAnimation.Shortest
                    }
                }
            //}

                Component {
                    id: pathViewHighlight
                    Rectangle {
                        id: highlight
                        width: 40
                        height: 40
                        color: "red"
                        radius: width / 2
                    }
                }

                Component {
                    id: pathViewItem

                    Rectangle {
                        id: rectangle
                        width: 8
                        height: 8
                        color: "transparent"


                        Label {
                            anchors.centerIn: parent
                            text: {  //return pathView.model.data < 10 && !isHours ? "0" + modelData : modelData
                                return modelData;
                            }
                        }
                    }
                }

                PathView {
                    id: pathView
                    anchors.fill: parent
                    visible: true
                    model: {
                        return getTimeList(24, isZeroBased)
                    }

                    interactive: false

                    delegate: pathViewItem

                    highlight: pathViewHighlight

                    path: Path {
                        startX: circle.width / 2
                        startY: clockPadding

                        PathArc {
                            x: circle.width / 2
                            y: circle.height - clockPadding
                            radiusX: circle.width / 2 - clockPadding
                            radiusY: circle.width / 2 - clockPadding
                            useLargeArc: false
                        }

                        PathArc {
                            x: circle.width / 2
                            y: clockPadding
                            radiusX: circle.width / 2 - clockPadding
                            radiusY: circle.width / 2 - clockPadding
                            useLargeArc: false
                        }
                    }
                }
            }
        }
    }

    function getTimeList(limit, isZeroBased) {
        var items = []
        if(!isZeroBased) {
            items[0] = limit
        }

        var start = isZeroBased? 0 : 1
        for(var i = start; i < limit; i++) {
            items[i] = i;
        }
        return items;
    }

}


