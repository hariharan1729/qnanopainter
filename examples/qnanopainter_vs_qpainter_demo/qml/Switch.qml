import QtQuick 2.0

Item {
    id: root

    property alias text: textItem.text
    property bool checked: false
    property string textOn: "ON"
    property string textOff: "OFF"

    QtObject {
        id: priv
        property real switchWidth: Math.max(76*dp, textOnItem.paintedWidth + 60*dp)
        property real barHeight: 19 * dp
        property real knobMovement: switchWidth - knobSize + 2
        property real knobSize: 32 * dp
        property real knobState: knob.x / knobMovement

        function releaseSwitch() {
            // Don't switch if we are in correct side
            if ((knob.x == -2 && !checked) || (knob.x == priv.knobMovement && checked)) {
                return;
            }
            checked = !checked;
        }
    }

    width: parent ? parent.width : 200 * dp
    height: 60 * dp

    MouseArea {
        width: parent.width
        height: parent.height
        onClicked: {
            root.checked = !root.checked;
        }
    }

    Text {
        id: textItem
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 20 * dp
        anchors.right: switchBackgroundImage.left
        anchors.rightMargin: 20 * dp
        //horizontalAlignment: Text.AlignHCenter
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideRight
        font.pixelSize: 16 * dp
        color: "#ffffff"
        style: Text.Outline
        styleColor: "#000000"
    }

    Rectangle {
        id: switchBackgroundImage
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 32 * dp
        height: priv.barHeight
        width: priv.switchWidth
        radius: height/2
        color: "#404040"
    }
    Rectangle {
        id: switchFrameImage
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 32 * dp
        height: priv.barHeight
        width: priv.switchWidth
        radius: height/2
        color: "transparent"
        border.width: 1 * dp
        border.color: "#808080"
        z: 2
    }

    Item {
        id: switchItem
        anchors.fill: switchBackgroundImage

        Text {
            id: textOnItem
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: knob.left
            anchors.rightMargin: 6
            color: "#ffffff"
            font.pixelSize: 12 * dp
            text: textOn
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: knob.right
            anchors.leftMargin: 4
            color: "#808080"
            font.pixelSize: 12 * dp
            text: textOff
        }

        Item {
            id: knob
            anchors.verticalCenter: parent.verticalCenter
            height: priv.knobSize
            width: height
            x: checked ? priv.knobMovement : -2
            MouseArea {
                anchors.fill: parent
                drag.target: knob; drag.axis: Drag.XAxis; drag.minimumX: -2; drag.maximumX: priv.knobMovement
                onClicked: checked = !checked;
                onReleased: priv.releaseSwitch();
            }
            Behavior on x {
                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }
        }
    }

    Rectangle {
        id: knobVisual
        property real colorValue: 0.6 + priv.knobState*0.4
        anchors.verticalCenter: parent.verticalCenter
        height: priv.knobSize
        width: height
        x: switchBackgroundImage.x + knob.x
        z: 10
        radius: height/2
        color: Qt.rgba(colorValue, colorValue, colorValue, 1.0)
        border.width: 1 * dp
        border.color: "#404040"
    }

    // Mask out switch parts which should be hidden
    ShaderEffect {
        id: shaderItem
        property variant source: ShaderEffectSource { sourceItem: switchItem; hideSource: true }
        property variant maskSource: ShaderEffectSource { sourceItem: switchBackgroundImage; hideSource: false }

        anchors.fill: switchBackgroundImage

        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform highp float qt_Opacity;
            uniform sampler2D source;
            uniform sampler2D maskSource;
            void main(void) {
                gl_FragColor = texture2D(source, qt_TexCoord0.st) * (texture2D(maskSource, qt_TexCoord0.st).a) * qt_Opacity;
            }
        "
    }
}
