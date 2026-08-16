import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Scope {
	Variants {
		model: Quickshell.screens;

		PanelWindow {
			required property var modelData
			screen: modelData

			anchors {
				top: true
				left: true
				right: true
			}

			implicitHeight: 30
			color: "#1E2326"

			RowLayout {
				anchors.fill: parent
				anchors.margins: 8

				WorkspaceWidget {}
			}
			
			ClockWidget {
				anchors.centerIn: parent
				color: "#D3C6AA"
			}
		}	
	}
}
