package main

import (
	"bytes"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestInstallCreatesManifestIconAndDesktopEntry(t *testing.T) {
	t.Parallel()

	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "image/png")
		_, _ = w.Write([]byte{0x89, 'P', 'N', 'G', '\r', '\n', 0x1a, '\n'})
	}))
	t.Cleanup(server.Close)

	configHome := t.TempDir()
	dataHome := t.TempDir()
	var output bytes.Buffer
	err := run(
		[]string{"install"},
		strings.NewReader("GitHub\nhttps://github.com\n"+server.URL+"/github.png\n"),
		&output,
		&output,
		environment{configHome: configHome, dataHome: dataHome},
	)
	if err != nil {
		t.Fatalf("install returned an error: %v\n%s", err, output.String())
	}

	manifest, err := os.ReadFile(filepath.Join(configHome, "webapps", "manifest.json"))
	if err != nil {
		t.Fatalf("read manifest: %v", err)
	}
	if !strings.Contains(string(manifest), `"name": "GitHub"`) {
		t.Fatalf("manifest did not contain the webapp: %s", manifest)
	}

	iconPath := filepath.Join(dataHome, "icons", "webapps", "webapp-github.png")
	if _, err := os.Stat(iconPath); err != nil {
		t.Fatalf("expected downloaded icon: %v", err)
	}

	entry, err := os.ReadFile(filepath.Join(dataHome, "applications", "webapp-github.desktop"))
	if err != nil {
		t.Fatalf("read desktop entry: %v", err)
	}
	if !strings.Contains(string(entry), "Exec=brave --app=https://github.com") {
		t.Fatalf("desktop entry does not launch Brave app mode: %s", entry)
	}
	if !strings.Contains(string(entry), "X-Webapp-Managed=true") {
		t.Fatalf("desktop entry lacks management marker: %s", entry)
	}
}

func TestInstallDoesNotPersistWhenIconIsNotPNG(t *testing.T) {
	t.Parallel()

	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/plain")
		_, _ = w.Write([]byte("not an icon"))
	}))
	t.Cleanup(server.Close)

	configHome := t.TempDir()
	var output bytes.Buffer
	err := run(
		[]string{"install"},
		strings.NewReader("GitHub\nhttps://github.com\n"+server.URL+"/github.png\n"),
		&output,
		&output,
		environment{configHome: configHome, dataHome: t.TempDir()},
	)
	if err == nil {
		t.Fatal("install succeeded with a non-PNG icon")
	}
	if _, err := os.Stat(filepath.Join(configHome, "webapps", "manifest.json")); !os.IsNotExist(err) {
		t.Fatalf("manifest persisted after failed install: %v", err)
	}
}
