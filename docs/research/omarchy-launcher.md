# Omarchy app launcher — research notes

Research date: 2026-08-15. Primary sources: `basecamp/omarchy` (`quattro` / v4.0.0 and `dev`), Omarchy manual.

## Verdict (for a Quickshell + Hyprland equivalent)

Omarchy **v4 (Quattro)** does **not** use Walker/fuzzel/rofi for launching. The launcher is a **first-party Quickshell menu plugin** inside a long-running `omarchy-shell` process. Web apps are ordinary **XDG `.desktop` entries** that run `omarchy-launch-webapp`, which starts the default Chromium-family browser (Brave included) with `--app=URL`.

Pre-v4 Omarchy used **Walker + elephant**; treat that as historical.

---

## 1. How apps are launched (keybindings)

### Current (v4 / `quattro`)

| Hotkey | Action | Command |
| --- | --- | --- |
| `SUPER + SPACE` | Full Omarchy menu (commands **and** apps, searchable) | `omarchy-menu toggle` → `omarchy-shell shell toggle omarchy.menu '{"menu":"root"}'` |
| `SUPER + ALT + SPACE` | Apps-only menu | `omarchy-menu toggle apps` |

Source: [`default/hypr/bindings/utilities.lua`](https://github.com/basecamp/omarchy/blob/quattro/default/hypr/bindings/utilities.lua), [`bin/omarchy-menu`](https://github.com/basecamp/omarchy/blob/quattro/bin/omarchy-menu).

Direct app hotkeys (terminal, browser, many webapps) live in [`default/hypr/bindings/applications.lua`](https://github.com/basecamp/omarchy/blob/quattro/default/hypr/bindings/applications.lua). Webapp binds use a helper shape like `{ webapp = "https://chatgpt.com" }`.

### Docs skew

Older published manual copy still describes `Super + Space` as “application launcher” and `Super + Alt + Space` as “Omarchy Menu” ([learn.omacom.io](https://learn.omacom.io/2/the-omarchy-manual)). **v4 inverted/merged that:** Space is the unified menu; Alt+Space is apps-only ([v4.0.0 notes](https://github.com/basecamp/omarchy/releases/tag/v4.0.0), [`manual/03-coming-from-mac-or-windows.md`](https://github.com/basecamp/omarchy/blob/quattro/manual/03-coming-from-mac-or-windows.md) on `quattro`).

### Pre-v4 (Walker era)

- `SUPER + SPACE` opened Walker.
- Stack: Walker frontend + `elephant` backend; config under `config/walker/config.toml` (still present on older branches).
- Prefix modes: `.` files, `:` symbols, `=` calc, `@` websearch, `$` clipboard, `/` provider list.
- v4 release explicitly: “Walker is gone.”

---

## 2. Tech stack

| Era | Launcher | Shell UI |
| --- | --- | --- |
| **v4 Quattro** | Native `omarchy.menu` Quickshell plugin | Entire desktop shell in Quickshell (`omarchy-shell`): bar, menu, notifications, OSDs, lock, polkit |
| **Pre-v4** | [Walker](https://github.com/abenz1267/walker) + elephant | Waybar / separate daemons |

Not fuzzel/rofi for the default launcher.

Architecture notes ([`shell/plugins/README.md`](https://github.com/basecamp/omarchy/blob/quattro/shell/plugins/README.md), [`docs/menu.md`](https://github.com/basecamp/omarchy/blob/quattro/docs/menu.md)):

- Menu UI: `shell/plugins/menu/Menu.qml` + `MenuModel.js`
- Apps engine: `shell/services/AppLibrary.qml` + `AppSearch.js` (Quickshell `DesktopEntries`)
- Menu data: `default/omarchy/omarchy-menu.jsonc` + user `~/.config/omarchy/extensions/omarchy-menu.jsonc`
- Summon via IPC (`~30ms` cold path claimed); actions via `Quickshell.execDetached`
- App launch path: `uwsm-app -- gtk-launch <id>.desktop`

---

## 3. UX / design details

**Surface:** Centered floating “card” (~300px default width; some submenus 520px). Header acts as type-to-filter field (“Go…” / submenu title). Keyboard-first; pointer selection gated until mouse moves.

**Navigation:** Nested command palette (drill into Apps / Install / Setup / …). Search flattens: matches in current menu and nested entries, with a **divider** between those sections when both appear.

**Search (menu rows):** Substring match on label, leaf id, aliases; whole-word match on description. Scored tiers (exact label, prefix, substring, etc.). Source: `MenuModel.js`.

**Search (apps):** `AppSearch.js` fuzzy scoring over `name`, `genericName`, `comment`, `keywords`, `id`, plus **acronym** match (first letters of words; terms ≤5 chars). No XDG **Categories** UI — apps are a flat list under `apps` provider, not category browsers.

**Icons:**

- Menu/commands: Nerd Font / glyph in `icon` field (optional `iconFont`)
- Apps: image icons from desktop entry via live **icon index** scan (so newly installed apps get icons without shell restart)
- Launch feedback OSD: “Launching …”

**Hide / cleanup:** `default/omarchy/launcher.hides` lists desktop ids to hide; also respects `Hidden`/`NoDisplay`/`OnlyShowIn`/`NotShowIn` via `hidden-entries.sh`. Users can remove launcher entries (`omarchy-remove-launcher-entry`).

**Not featured in v4 launcher:** Walker-style prefix providers (calc/files/emoji) — emoji/clipboard moved to separate shell overlays (`SUPER+CTRL+E`, `SUPER+CTRL+V`).

---

## 4. Webapps via Brave / Chromium

### Registration

Installer: [`bin/omarchy-webapp-install`](https://github.com/basecamp/omarchy/blob/dev/bin/omarchy-webapp-install)

- Interactive (`gum`) or CLI: name, URL, icon
- Writes `~/.local/share/applications/$APP_NAME.desktop`
- Saves icon to `~/.local/share/applications/icons/` (Google s2 favicon fetch, or manual PNG URL / [dashboardicons.com](https://dashboardicons.com))
- Default `Exec`: `omarchy-launch-webapp $APP_URL`
- Optional MimeType line
- Menu entry: Install → Web App → floating terminal running the installer (`install.webapp` in `omarchy-menu.jsonc`)

Shipped webapps are packaged as `.desktop` files under [`applications/`](https://github.com/basecamp/omarchy/tree/quattro/applications) (e.g. WhatsApp, YouTube, Basecamp) and copied into `~/.local/share/applications` by `omarchy-refresh-applications`.

Example shipped entry:

```desktop
[Desktop Entry]
Version=1.0
Name=WhatsApp
Exec=omarchy-launch-webapp https://web.whatsapp.com/
Terminal=false
Type=Application
Icon=whatsapp
StartupNotify=true
```

### Launch

[`bin/omarchy-launch-webapp`](https://github.com/basecamp/omarchy/blob/dev/bin/omarchy-launch-webapp):

1. `xdg-settings get default-web-browser`
2. Allowlist: `google-chrome*`, `brave*`, `microsoft-edge*`, `opera*`, `vivaldi*`, `helium*`; else fall back to `chromium.desktop`
3. Resolve browser binary from that `.desktop`’s `Exec=`
4. `setsid uwsm-app -- <browser> --app="$URL" …`

“Frameless / native feel” comes from Chromium **`--app=`** mode (no browser chrome), not a custom browser. Hyprland still tiles these like other windows.

Focus-or-launch helper: [`omarchy-launch-or-focus-webapp`](https://github.com/basecamp/omarchy/blob/quattro/bin/omarchy-launch-or-focus-webapp) → window-pattern match then launch.

### Manual / UX notes

- [Web Apps chapter](https://learn.omacom.io/2/the-omarchy-manual/63/web-apps): install via menu; appear in launcher; prefer logging in via full browser first (1Password / thin chrome quirks); `Shift+Alt+L` copies URL in webapp; hotkeys in hypr bindings.
- Isolation / multi-profile: community PRs and issues around `--user-data-dir` (webapps share the main browser process by default).

---

## 5. Implications for a Quickshell + Hyprland clone

1. **One IPC-summoned Quickshell surface** for both “Raycast menu” and “app launcher,” with an apps-only route.
2. **Index XDG desktop entries** (Quickshell `DesktopEntries` or equivalent); launch via `gtk-launch` / `uwsm-app` / desktop Exec — don’t maintain a parallel app DB.
3. **Webapps = `.desktop` + Chromium `--app=`** wrapper; Brave works when it is the xdg default (or explicitly selected).
4. **UX target:** narrow centered card, type-ahead filter, nested menus + flat search, glyph icons for commands / file icons for apps, fuzzy + short acronym matching, hide-list — skip category panes unless you want them.
5. Prefer **v4/quattro sources** over older Walker docs when matching current Omarchy.

---

## Source links

- Repo: https://github.com/basecamp/omarchy
- v4 release (Walker → native menu): https://github.com/basecamp/omarchy/releases/tag/v4.0.0
- Menu plugin README: https://github.com/basecamp/omarchy/blob/quattro/shell/plugins/README.md
- Menu docs: https://github.com/basecamp/omarchy/blob/quattro/docs/menu.md
- Menu.qml / MenuModel.js / AppLibrary.qml / AppSearch.js (quattro)
- Keybinds: https://github.com/basecamp/omarchy/blob/quattro/default/hypr/bindings/utilities.lua
- Webapp install/launch (dev): https://github.com/basecamp/omarchy/blob/dev/bin/omarchy-webapp-install , https://github.com/basecamp/omarchy/blob/dev/bin/omarchy-launch-webapp
- Manual web apps: https://learn.omacom.io/2/the-omarchy-manual/63/web-apps
- Pre-v4 Walker guide (discussion): https://github.com/basecamp/omarchy/discussions/2835
- Desktop-entry / Walker add-apps discussion: https://github.com/basecamp/omarchy/discussions/3946
