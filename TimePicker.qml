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

    Keys.onUpPressed: {
        var date = internal.timePicked

        if(isHours)
            date.setHours(internal.timePicked.getHours() + 1)
        else
            date.setMinutes(internal.timePicked.getMinutes() + 1)

        internal.timePicked = date
    }

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

                hoursPathView.currentIndex = hours

                var minutes = internal.timePicked.getMinutes()
                minutesPathView.currentIndex = minutes
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
            color: "black"

            Row {
                id: row
                anchors.centerIn: parent
                height: parent.height/2

                Label {
                    id: hourLabel
                    anchors.verticalCenter: parent.verticalCenter
                    text: internal.timePicked.getHours()
                    font.pixelSize: 56
                    color: isHours? "white" : "#99ffffff"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if(!isHours){
                                setIsHours(true)
                            }
                        }
                    }
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: ":"
                    font.pixelSize: 56
                    color: "white"
                    MouseArea {

                    }
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: internal.timePicked.getMinutes() < 10 ? "0" + internal.timePicked.getMinutes() : internal.timePicked.getMinutes()
                    font.pixelSize: 56
                    color: !isHours? "white" : "#99ffffff"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if(isHours){
                                setIsHours(false)
                            }
                        }
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
                    visible: !prefer24Hour

                    spacing: 2

                    property bool isAm: true

                Label {
                    text: "AM"
                    font.pixelSize: 16
                    color: amPmPicker.isAm ? "white" : "#99ffffff"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: amPmPicker.isAm = true
                    }
                }

                Label {
                    text: "PM"
                    font.pixelSize: 16
                    color: !amPmPicker.isAm ? "white" : "#99ffffff"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: amPmPicker.isAm = false
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
                    antialiasing: true

                    Connections {
                        target: hoursPathView
                        onCurrentIndexChanged: {
                            if(isHours)
                                pointer.setAngle()
                        }
                    }

                    Connections {
                        target: minutesPathView
                        onCurrentIndexChanged: {
                            if(!isHours)
                                pointer.setAngle()
                        }
                    }

                    Connections {
                        target: timePicker
                        onIsHoursChanged: pointer.setAngle()
                    }

                    Behavior on rotation {
                        RotationAnimation {
                            id: pointerRotation
                            duration: 180
                            direction: RotationAnimation.Shortest
                        }
                    }

                    function setAngle()
                    {
                        //console.log("fff")
                        var idx = isHours ? hoursPathView.currentIndex : minutesPathView.currentIndex
                        //var idx = hoursPathView.currentIndex
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
                        antialiasing: true
                    }
                }

                Component {
                    id: pathViewItem

                    Rectangle {
                        id: rectangle
                        width: !isHours && modelData % 5 == 0 ? 12  : isHours ? 30  : 8
                        height: !isHours && modelData % 5 == 0 ? 12  : isHours ? 30  : 8
                        color: "transparent"

                        property bool isSelected: false


                        Label {
                            anchors.centerIn: parent
                            visible: modelData >= 0 && (isHours ? true : modelData % 5 == 0)
                            text: {  //return pathView.model.data < 10 && !isHours ? "0" + modelData : modelData
                                //return modelData;
                                var model = isHours ? hoursPathView.model : minutesPathView.model
                                return model.data < 10 && !isHours ? "0" + modelData : modelData
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

                    onPositionChanged: {
                        if(parentMouseArea.pressed)
                        {
                            leftButtonPressed = true
                            globalX = parentMouseArea.mapToItem(null, mouse.x, mouse.y).x
                            globalY = parentMouseArea.mapToItem(null, mouse.x, mouse.y).y
                        }
                        else
                        {
                            leftButtonPressed = false
                        }
                    }
                }

                PathView {
                    id: hoursPathView
                    anchors.fill: parent
                    visible: isHours
                    model: {
                        return getTimeList(12, isZeroBased)
                    }

                    interactive: false

                    delegate: pathViewItem

                    highlight: pathViewHighlight

                    highlightRangeMode: PathView.NoHighlightRange   //control the number of clock not to move
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

                    //connect the pathview currentIndex to hourLabel
                    onCurrentIndexChanged: {
                        var newText = currentIndex
                        if(currentIndex == 0 && !prefer24Hour)
                            newText = 12
                        hourLabel.text = newText
                    }
                }

                PathView {
                    id: minutesPathView
                    anchors.fill: parent
                    visible: !isHours
                    model: {
                        return getTimeList(60, true)
                    }
                    highlightRangeMode: PathView.NoHighlightRange
                    highlightMoveDuration: 200
                    delegate: pathViewItem
                    highlight: pathViewHighlight
                    interactive: false

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

    function setIsHours(_isHours) {
        if(_isHours == isHours)
            return

        if(!internal.resetFlag)
            internal.resetFlag = true

        var prevRotation = pointerRotation.duration
        pointerRotation.duration = 0
        isHours = _isHours
        pointerRotation.duration = prevRotation
    }

}


