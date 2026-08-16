import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Scope {
	id: root

	required property var theme

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
			color: root.theme.background

			RowLayout {
				anchors.fill: parent
				anchors.margins: 8

				WorkspaceWidget {
					theme: root.theme
				}
			}
			
			ClockWidget {
				anchors.centerIn: parent
				color: root.theme.foreground
			}
		}	
	}
}
