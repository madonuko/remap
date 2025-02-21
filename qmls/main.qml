import QtQuick
import QtQuick.Controls
import Qt.labs.platform as Platform

ApplicationWindow {
    width: 400
    height: 300
    title: "remap"
    Component.onCompleted: visible = true

    TextEdit {
        // anchors.fill: parent
        focus: true
        Keys.onPressed: event => {
            console.warn("pressed: " + event.key);
            console.warn("meow: " + remapKeySeq.keyToString(event.key, event.modifiers))
            event.accepted = true;
        }
        // Keys.onReleased: event => {
        //     console.warn("released: " + event.text);
        // }
    }
}
