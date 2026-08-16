import Quickshell
import Quickshell.Io

Scope {
	id: root

	Theme {
		id: themeTokens
	}

	Bar {
		theme: themeTokens
	}

	AppLauncher {
		id: launcher
		theme: themeTokens
	}

	IpcHandler {
		target: "launcher"

		function toggle(): void {
			launcher.toggle()
		}
	}
}
