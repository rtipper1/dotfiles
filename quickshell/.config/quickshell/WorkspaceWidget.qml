import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

RowLayout {
	required property var theme

	Repeater {
		model: ScriptModel {
			// Hyprland only tracks focused/occupied workspaces; skip named/special (id < 1).
			values: Hyprland.workspaces.values.filter(w => w.id >= 1)
		}

		Text {
			required property var modelData
			text: modelData.id
			color: modelData.focused ? theme.foreground : theme.muted
			font { pixelSize: 12; bold: true }

			MouseArea {
				anchors.fill: parent
				onClicked: modelData.activate()
			}
		}
	}
}
