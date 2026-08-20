package main

import (
	"bufio"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

const (
	managedMarker = "X-Webapp-Managed=true"
	webappBrowser = "google-chrome-stable"
)

type environment struct {
	configHome string
	dataHome   string
}

type manifest struct {
	Webapps []webapp `json:"webapps"`
}

type webapp struct {
	Name    string `json:"name"`
	URL     string `json:"url"`
	IconURL string `json:"iconUrl"`
	ID      string `json:"id"`
}

func main() {
	env := environment{configHome: configHome(), dataHome: dataHome()}
	if err := run(os.Args[1:], os.Stdin, os.Stdout, os.Stderr, env); err != nil {
		fmt.Fprintln(os.Stderr, "webapp:", err)
		os.Exit(1)
	}
}

func run(args []string, input io.Reader, output, errorsOut io.Writer, env environment) error {
	if len(args) != 1 {
		return errors.New("usage: webapp <install|list|remove|sync>")
	}

	switch args[0] {
	case "install":
		return install(input, output, env)
	case "list":
		return list(output, env)
	case "remove":
		return remove(input, output, env)
	case "sync":
		return sync(env)
	default:
		return fmt.Errorf("unknown command %q; expected install, list, remove, or sync", args[0])
	}
}

func install(input io.Reader, output io.Writer, env environment) error {
	reader := bufio.NewReader(input)
	name, err := prompt(reader, output, "Name")
	if err != nil {
		return err
	}
	appURL, err := prompt(reader, output, "URL")
	if err != nil {
		return err
	}
	if err := validateAppURL(appURL); err != nil {
		return err
	}
	iconURL, err := prompt(reader, output, "Dashboard Icons PNG URL")
	if err != nil {
		return err
	}
	if err := validateURL(iconURL); err != nil {
		return fmt.Errorf("icon URL: %w", err)
	}

	item := webapp{Name: name, URL: appURL, IconURL: iconURL, ID: "webapp-" + slug(name)}
	data, err := loadManifest(env)
	if err != nil {
		return err
	}
	for index, existing := range data.Webapps {
		if existing.ID != item.ID {
			continue
		}
		replace, err := prompt(reader, output, fmt.Sprintf("%s already exists; replace? [y/N]", existing.Name))
		if err != nil {
			return err
		}
		if strings.ToLower(replace) != "y" && strings.ToLower(replace) != "yes" {
			return errors.New("installation cancelled")
		}
		data.Webapps[index] = item
		return saveAndSync(data, env)
	}

	data.Webapps = append(data.Webapps, item)
	return saveAndSync(data, env)
}

func list(output io.Writer, env environment) error {
	data, err := loadManifest(env)
	if err != nil {
		return err
	}
	sort.Slice(data.Webapps, func(i, j int) bool { return data.Webapps[i].Name < data.Webapps[j].Name })
	for _, item := range data.Webapps {
		if _, err := fmt.Fprintf(output, "%s\t%s\n", item.Name, item.URL); err != nil {
			return err
		}
	}
	return nil
}

func remove(input io.Reader, output io.Writer, env environment) error {
	reader := bufio.NewReader(input)
	name, err := prompt(reader, output, "Name")
	if err != nil {
		return err
	}
	id := "webapp-" + slug(name)
	data, err := loadManifest(env)
	if err != nil {
		return err
	}
	for index, item := range data.Webapps {
		if item.ID == id {
			data.Webapps = append(data.Webapps[:index], data.Webapps[index+1:]...)
			return saveAndSync(data, env)
		}
	}
	return fmt.Errorf("%q is not installed", name)
}

func sync(env environment) error {
	data, err := loadManifest(env)
	if err != nil {
		return err
	}
	if err := os.MkdirAll(iconDir(env), 0o755); err != nil {
		return err
	}
	if err := os.MkdirAll(applicationsDir(env), 0o755); err != nil {
		return err
	}

	for _, item := range data.Webapps {
		if err := syncIcon(item, env); err != nil {
			return fmt.Errorf("%s: %w", item.Name, err)
		}
		if err := writeAtomic(desktopPath(item, env), []byte(desktopEntry(item, env)), 0o644); err != nil {
			return err
		}
	}
	return removeStaleEntries(data, env)
}

func syncIcon(item webapp, env environment) error {
	icon := iconPath(item, env)
	source := icon + ".source"
	savedURL, _ := os.ReadFile(source)
	if _, err := os.Stat(icon); err == nil && strings.TrimSpace(string(savedURL)) == item.IconURL {
		return nil
	}

	response, err := http.Get(item.IconURL) // #nosec G107 -- URL is supplied explicitly by the user.
	if err != nil {
		return fmt.Errorf("download icon: %w", err)
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusOK {
		return fmt.Errorf("download icon: server returned %s", response.Status)
	}
	contentType := response.Header.Get("Content-Type")
	if !strings.HasPrefix(contentType, "image/png") {
		return fmt.Errorf("download icon: expected image/png, got %q", contentType)
	}
	contents, err := io.ReadAll(io.LimitReader(response.Body, 10<<20))
	if err != nil {
		return fmt.Errorf("read icon: %w", err)
	}
	if len(contents) < 8 || string(contents[:8]) != "\x89PNG\r\n\x1a\n" {
		return errors.New("download icon: response is not a PNG")
	}
	if err := writeAtomic(icon, contents, 0o644); err != nil {
		return err
	}
	return writeAtomic(source, []byte(item.IconURL+"\n"), 0o644)
}

func removeStaleEntries(data manifest, env environment) error {
	expected := make(map[string]bool, len(data.Webapps))
	for _, item := range data.Webapps {
		expected[filepath.Base(desktopPath(item, env))] = true
	}
	entries, err := os.ReadDir(applicationsDir(env))
	if err != nil && !os.IsNotExist(err) {
		return err
	}
	for _, entry := range entries {
		if expected[entry.Name()] || !strings.HasPrefix(entry.Name(), "webapp-") || !strings.HasSuffix(entry.Name(), ".desktop") {
			continue
		}
		path := filepath.Join(applicationsDir(env), entry.Name())
		contents, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		if strings.Contains(string(contents), managedMarker) {
			if err := os.Remove(path); err != nil {
				return err
			}
		}
	}
	return nil
}

func loadManifest(env environment) (manifest, error) {
	contents, err := os.ReadFile(manifestPath(env))
	if os.IsNotExist(err) {
		return manifest{}, nil
	}
	if err != nil {
		return manifest{}, err
	}
	var data manifest
	if err := json.Unmarshal(contents, &data); err != nil {
		return manifest{}, fmt.Errorf("parse manifest: %w", err)
	}
	return data, nil
}

func saveManifest(data manifest, env environment) error {
	sort.Slice(data.Webapps, func(i, j int) bool { return data.Webapps[i].Name < data.Webapps[j].Name })
	contents, err := json.MarshalIndent(data, "", "  ")
	if err != nil {
		return err
	}
	return writeAtomic(manifestWritePath(env), append(contents, '\n'), 0o644)
}

func saveAndSync(data manifest, env environment) error {
	_, existed := os.Stat(manifestPath(env))
	manifestExisted := existed == nil
	if existed != nil && !os.IsNotExist(existed) {
		return existed
	}
	previous, err := loadManifest(env)
	if err != nil {
		return err
	}
	if err := saveManifest(data, env); err != nil {
		return err
	}
	if err := sync(env); err != nil {
		var rollbackErr error
		if manifestExisted {
			rollbackErr = saveManifest(previous, env)
		} else {
			rollbackErr = os.Remove(manifestWritePath(env))
		}
		if rollbackErr != nil {
			return fmt.Errorf("%w (also failed to restore manifest: %v)", err, rollbackErr)
		}
		return err
	}
	return nil
}

func desktopEntry(item webapp, env environment) string {
	return fmt.Sprintf(`[Desktop Entry]
Version=1.0
Name=%s
Exec=%s --app=%s
Terminal=false
Type=Application
Icon=%s
StartupNotify=true
%s
`, item.Name, webappBrowser, item.URL, iconPathForDesktop(item, env), managedMarker)
}

func prompt(reader *bufio.Reader, output io.Writer, label string) (string, error) {
	if _, err := fmt.Fprintf(output, "%s: ", label); err != nil {
		return "", err
	}
	value, err := reader.ReadString('\n')
	if err != nil && !errors.Is(err, io.EOF) {
		return "", err
	}
	value = strings.TrimSpace(value)
	if value == "" {
		return "", fmt.Errorf("%s is required", strings.ToLower(label))
	}
	return value, nil
}

func validateAppURL(raw string) error {
	parsed, err := url.ParseRequestURI(raw)
	if err != nil {
		return fmt.Errorf("invalid URL: %w", err)
	}
	if parsed.Scheme == "https" {
		return nil
	}
	if parsed.Scheme == "http" && (parsed.Hostname() == "localhost" || net.ParseIP(parsed.Hostname()).IsLoopback()) {
		return nil
	}
	return errors.New("URL must use HTTPS, except HTTP localhost")
}

func validateURL(raw string) error {
	parsed, err := url.ParseRequestURI(raw)
	if err != nil {
		return errors.New("must be a valid HTTPS URL")
	}
	if parsed.Scheme == "https" || (parsed.Scheme == "http" && (parsed.Hostname() == "localhost" || net.ParseIP(parsed.Hostname()).IsLoopback())) {
		return nil
	}
	return errors.New("must be an HTTPS URL")
}

var nonSlug = regexp.MustCompile(`[^a-z0-9]+`)

func slug(name string) string {
	result := strings.Trim(nonSlug.ReplaceAllString(strings.ToLower(name), "-"), "-")
	if result == "" {
		return "app"
	}
	return result
}

func manifestPath(env environment) string {
	return filepath.Join(env.configHome, "webapps", "manifest.json")
}

func iconDir(env environment) string {
	return filepath.Join(env.dataHome, "icons", "webapps")
}

func iconPath(item webapp, env environment) string {
	return filepath.Join(iconDir(env), item.ID+".png")
}

func iconPathForDesktop(item webapp, env environment) string {
	return iconPath(item, env)
}

func applicationsDir(env environment) string {
	return filepath.Join(env.dataHome, "applications")
}

func desktopPath(item webapp, env environment) string {
	return filepath.Join(applicationsDir(env), item.ID+".desktop")
}

func writeAtomic(path string, contents []byte, mode os.FileMode) error {
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	file, err := os.CreateTemp(filepath.Dir(path), ".webapp-*")
	if err != nil {
		return err
	}
	name := file.Name()
	defer os.Remove(name)
	if _, err := file.Write(contents); err != nil {
		file.Close()
		return err
	}
	if err := file.Chmod(mode); err != nil {
		file.Close()
		return err
	}
	if err := file.Close(); err != nil {
		return err
	}
	return os.Rename(name, path)
}

func manifestWritePath(env environment) string {
	path := manifestPath(env)
	resolved, err := filepath.EvalSymlinks(path)
	if err == nil {
		return resolved
	}
	return path
}

func configHome() string {
	if value := os.Getenv("XDG_CONFIG_HOME"); value != "" {
		return value
	}
	home, err := os.UserHomeDir()
	if err != nil {
		return ".config"
	}
	return filepath.Join(home, ".config")
}

func dataHome() string {
	if value := os.Getenv("XDG_DATA_HOME"); value != "" {
		return value
	}
	home, err := os.UserHomeDir()
	if err != nil {
		return ".local/share"
	}
	return filepath.Join(home, ".local", "share")
}
