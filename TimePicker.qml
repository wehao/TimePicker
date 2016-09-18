import QtQuick 2.0
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

FocusScope {
    id: timePicker
    width: 300
    height: 400
    visible: true

    property real clockPadding: 24
    property bool  isZeroBased: false
    property bool isHours: true
    property bool prefer24Hour: false

    QtObject {
        id: internal
        property bool resetFlag: false
        property date timePicked
        property bool completed: false

        onTimePickedChanged: {
            if(completed) {
                var hours = timePicked.getHours()
                if(hours > 11 && !prefer24Hour){
                    hours -= 12
                    amPmPicker.isAm = false
                } else {
                    amPmPicker.isAm = true
                }

                pathView.currentIndex = hours

                //var minutes = internal.timePicked.getMinutes()
                //minutesPathView.currentIndex = minutes
            }
        }
    }

    Component.onCompleted: {
        internal.completed = true
        internal.timePicked = new Date(Date.now())
                forceActiveFocus()
    }

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
                id: amPmPicker
                    anchors {
                        bottom: row.bottom
                        left: row.right
                        leftMargin: 12
                    }

                    spacing: 2

                    property bool isAm: true

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

                    Connections {
                        target: pathView
                        onCurrentIndexChanged: {
                            if(isHours)
                                pointer.setAngle()
                        }
                    }

                    Behavior on rotation {
                        RotationAnimation {
                            id: pointerRotation
                            duration: 200
                            direction: RotationAnimation.Shortest
                        }
                    }

                    function setAngle()
                    {
                        //var idx = isHours ? pathView.currentIndex : minutesPathView.currentIndex
                        var idx = pathView.currentIndex
                        var angle
                        if(isHours)
                            angle = (360 / ((prefer24Hour) ? 24 : 12)) * idx
                        else
                            angle = 360 / 60 * idx

                        if(Math.abs(pointer.rotation - angle) == 180)
                            pointerRotation.direction = RotationAnimation.Clockwise
                        else
                            pointerRotation.direction = RotationAnimation.Shortest

                        pointer.rotation = angle
                    }

                }


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
                        width: 20
                        height: 20
                        color: "transparent"

                        property bool isSelected: false


                        Label {
                            anchors.centerIn: parent
                            text: {  //return pathView.model.data < 10 && !isHours ? "0" + modelData : modelData
                                return modelData;
                            }
                        }

                        Connections {
                            target: parentMouseArea

                            onClicked: {
                                checkClick(false)
                            }

                            onPositionChanged: {
                                checkClick(true)
                            }

                            function checkClick(isPress)
                            {
                                if((isPress ? parentMouseArea.leftButtonPressed : true) && rectangle.visible) {
                                    var thisPosition = rectangle.mapToItem(null, 0, 0, width, height)

                                    if(parentMouseArea.globalX > thisPosition.x &&
                                        parentMouseArea.globalY > thisPosition.y &&
                                        parentMouseArea.globalX < (thisPosition.x + width) &&
                                        parentMouseArea.globalY < (thisPosition.y + height)) {

                                        if(!rectangle.isSelected) {
                                            rectangle.isSelected = true

                                            var newDate = new Date(internal.timePicked) // Grab a new date from existing

                                            var time = parseInt(modelData)
                                            if(isHours) {
                                                if(!prefer24Hour && !amPmPicker.isAm && time < 12) {
                                                    time += 12
                                                }
                                                else if(!prefer24Hour && amPmPicker.isAm && time === 12) {
                                                    time = 0
                                                }

                                                newDate.setHours(time)
                                            } else {
                                                newDate.setMinutes(time)
                                            }

                                            internal.timePicked = newDate
                                        }
                                    }
                                    else {
                                        rectangle.isSelected = false
                                    }
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    property bool leftButtonPressed
                    property int globalX
                    property int globalY
                    id: parentMouseArea
                    anchors.fill: circle
                    hoverEnabled: true

                    onClicked: {
                        globalX = parentMouseArea.mapToItem(null, mouse.x, mouse.y).x
                        globalY = parentMouseArea.mapToItem(null, mouse.x, mouse.y).y
                    }

//                    onPositionChanged: {
//                        if(containsPress)
//                        {
//                            leftButtonPressed = true
//                            globalX = parentMouseArea.mapToItem(null, mouse.x, mouse.y).x
//                            globalY = parentMouseArea.mapToItem(null, mouse.x, mouse.y).y
//                        }
//                        else
//                        {
//                            leftButtonPressed = false
//                        }
//                    }
                }

                PathView {
                    id: pathView
                    anchors.fill: parent
                    visible: true
                    model: {
                        return getTimeList(12, isZeroBased)
                    }

                    interactive: false

                    delegate: pathViewItem

                    highlight: pathViewHighlight
                    highlightRangeMode: PathView.NoHighlightRange
                    highlightMoveDuration: 200

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

//                    onCurrentIndexChanged: {
//                        var newText = currentIndex
//                        if(currentIndex == 0 && !prefer24Hour)
//                            newText = 12
//                        hourLabel.text = newText
//                    }
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


