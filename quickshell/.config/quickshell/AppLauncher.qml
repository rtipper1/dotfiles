import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Scope {
	id: root

	required property var theme
	property bool open: false
	property string query: ""
	property int selectedIndex: 0
	readonly property var applications: DesktopEntries.applications.values
	readonly property var results: rankedApplications()

	function toggle() {
		open = !open
		if (open) {
			query = ""
			selectedIndex = 0
		}
	}

	function close() {
		open = false
	}

	function moveSelection(delta) {
		if (results.length === 0)
			return
		selectedIndex = (selectedIndex + delta + results.length) % results.length
	}

	function launchSelected() {
		if (results.length === 0)
			return
		results[selectedIndex].entry.execute()
		close()
	}

	function rankedApplications() {
		const normalizedQuery = query.trim().toLowerCase()
		const matches = []

		for (const entry of applications) {
			const score = matchScore(entry.name, normalizedQuery)
			if (score >= 0)
				matches.push({ entry: entry, score: score })
		}

		matches.sort((left, right) => {
			if (left.score !== right.score)
				return right.score - left.score
			return left.entry.name.localeCompare(right.entry.name)
		})
		return matches
	}

	function matchScore(name, needle) {
		const haystack = name.toLowerCase()
		if (needle.length === 0)
			return 0
		if (haystack === needle)
			return 1000
		if (haystack.startsWith(needle))
			return 800 - haystack.length
		if (acronym(name) === needle)
			return 700

		let cursor = 0
		let firstMatch = -1
		for (const character of needle) {
			cursor = haystack.indexOf(character, cursor)
			if (cursor < 0)
				return -1
			if (firstMatch < 0)
				firstMatch = cursor
			cursor += 1
		}
		return 500 - firstMatch - (cursor - firstMatch - needle.length)
	}

	function acronym(name) {
		return name.toLowerCase().split(/[\s_-]+/).filter(word => word.length > 0).map(word => word[0]).join("")
	}

	Variants {
		model: Quickshell.screens

		PanelWindow {
			required property var modelData
			readonly property var monitor: Hyprland.monitorFor(modelData)
			screen: modelData
			visible: root.open && monitor !== null && monitor.focused
			color: "transparent"
			exclusiveZone: 0
			focusable: true

			anchors {
				top: true
				bottom: true
				left: true
				right: true
			}

			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.namespace: "quickshell-launcher"

			onVisibleChanged: {
				if (visible)
					searchInput.forceActiveFocus()
			}

			MouseArea {
				anchors.fill: parent
				onClicked: root.close()
			}

			Rectangle {
				id: card
				anchors.centerIn: parent
				width: root.theme.launcherWidth
				readonly property int rowHeight: 48
				readonly property int panelMargin: 14
				readonly property int panelSpacing: 8
				height: panelMargin * 2 + panelSpacing + rowHeight + root.theme.launcherRows * rowHeight
				radius: 12
				color: root.theme.background
				opacity: root.theme.launcherOpacity
				border.color: root.theme.muted
				border.width: 1
				clip: true

				MouseArea {
					anchors.fill: parent
					onClicked: {}
				}

				ColumnLayout {
					anchors.fill: parent
					anchors.margins: card.panelMargin
					spacing: card.panelSpacing

					TextField {
						id: searchInput
						Layout.fillWidth: true
						Layout.preferredHeight: card.rowHeight
						text: root.query
						placeholderText: "Search applications"
						color: root.theme.foreground
						placeholderTextColor: root.theme.muted
						font {
							family: "JetBrainsMonoNL Nerd Font"
							pixelSize: 15
						}
						leftPadding: 12
						selectByMouse: true
						verticalAlignment: Text.AlignVCenter

						background: Rectangle {
							radius: 6
							color: "#00000000"
							border.color: root.theme.muted
							border.width: 1
						}

						onTextChanged: {
							root.query = text
							root.selectedIndex = 0
						}

						Keys.onPressed: event => {
							if (event.key === Qt.Key_Escape) {
								root.close()
								event.accepted = true
							} else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
								root.launchSelected()
								event.accepted = true
							} else if (event.key === Qt.Key_Down || (event.key === Qt.Key_N && event.modifiers & Qt.ControlModifier)) {
								root.moveSelection(1)
								event.accepted = true
							} else if (event.key === Qt.Key_Up || (event.key === Qt.Key_P && event.modifiers & Qt.ControlModifier)) {
								root.moveSelection(-1)
								event.accepted = true
							}
						}
					}

					ListView {
						id: resultList
						Layout.fillWidth: true
						Layout.fillHeight: true
						clip: true
						model: root.results
						currentIndex: root.selectedIndex

						delegate: Rectangle {
							required property var modelData
							required property int index
							width: resultList.width
							height: card.rowHeight
							radius: 6
							color: index === root.selectedIndex ? root.theme.selection : "transparent"

							RowLayout {
								anchors.fill: parent
								anchors.leftMargin: 10
								anchors.rightMargin: 10
								spacing: 10

								IconImage {
									Layout.preferredWidth: 24
									Layout.preferredHeight: 24
									source: Quickshell.iconPath(modelData.entry.icon, "application-x-executable")
									implicitSize: 24
								}

								Text {
									Layout.fillWidth: true
									text: modelData.entry.name
									color: root.theme.foreground
									font {
										family: "JetBrainsMonoNL Nerd Font"
										pixelSize: 15
									}
									elide: Text.ElideRight
								}
							}

							MouseArea {
								anchors.fill: parent
								hoverEnabled: true
								onEntered: root.selectedIndex = index
								onClicked: {
									modelData.entry.execute()
									root.close()
								}
							}
						}
					}
				}
			}
		}
	}
}
