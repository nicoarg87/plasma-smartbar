#!/usr/bin/env python3
"""Escucha exclusivamente selecciones de tema; no instala ni sustituye paneles."""
import configparser
import hashlib
import json
import os
import shutil
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "package/contents/ui/assets/wallpapers"
CONFIG_DIR = Path(os.environ.get("XDG_CONFIG_HOME") or (Path.home() / ".config"))
EVENTS = CONFIG_DIR / "plasma-smartbar-wallpapers.ini"
KDE_CONFIG = CONFIG_DIR / "plasma-org.kde.plasma.desktop-appletsrc"
STATE = Path(os.environ.get("XDG_STATE_HOME") or (Path.home() / ".local/state")) / "plasma-smartbar"
THEMES = {"day": "day.png", "sunset": "sunset.png", "night": "night.png"}


def event():
    if not EVENTS.is_file():
        return 0, ""
    reader = configparser.ConfigParser(interpolation=None)
    reader.read(EVENTS, encoding="utf-8")
    if not reader.has_section("ThemeWallpaper"):
        return 0, ""
    section = reader["ThemeWallpaper"]
    try:
        revision = int(section.get("revision", "0"))
    except ValueError:
        return 0, ""
    return revision, section.get("theme", "")


def asset_for(theme):
    if theme not in THEMES:
        raise ValueError("Tema no reconocido: " + repr(theme))
    manifest = ASSETS / "manifest.json"
    if not manifest.is_file():
        raise FileNotFoundError("Falta el manifiesto del ZIP de wallpapers.")
    data = json.loads(manifest.read_text(encoding="utf-8"))
    matches = [x for x in data.get("assets", []) if x.get("theme") == theme]
    if len(matches) != 1:
        raise ValueError("Metadatos de wallpaper incompletos para " + theme)
    record = matches[0]
    asset = ASSETS / THEMES[theme]
    if not asset.is_file() or asset.is_symlink():
        raise FileNotFoundError("Falta el wallpaper: " + str(asset))
    if not str(record.get("file", "")).endswith("/wallpapers/" + THEMES[theme]):
        raise ValueError("La ruta del wallpaper no coincide con el manifiesto.")
    if record.get("fillMode") != "stretch":
        raise ValueError("El tema no establece el ajuste Estirar.")
    if asset.stat().st_size != record.get("bytes"):
        raise ValueError("Tamaño incorrecto: " + str(asset))
    if hashlib.sha256(asset.read_bytes()).hexdigest() != record.get("sha256"):
        raise ValueError("El wallpaper original fue modificado: " + str(asset))
    return asset


def backup_kde_settings():
    if not KDE_CONFIG.is_file():
        return
    STATE.mkdir(mode=0o700, parents=True, exist_ok=True)
    # El respaldo se crea solo antes del primer cambio de esta ejecución.
    destination = STATE / ("plasma-desktop-previo-" + datetime.now().strftime("%Y%m%d-%H%M%S") + ".backup")
    shutil.copy2(KDE_CONFIG, destination)
    destination.chmod(0o600)
    print("Copia de seguridad del escritorio:", destination, flush=True)


def main():
    if "--check" in sys.argv:
        for name in THEMES:
            img = asset_for(name)
            print(name, img, flush=True)
        return 0
    tool = shutil.which("plasma-apply-wallpaperimage")
    if tool is None:
        print("SmartBar wallpapers: falta plasma-apply-wallpaperimage; no se cambió el escritorio.", flush=True)
        return 1
    revision, _ = event()
    did_backup = False
    print("SmartBar wallpapers: monitoreo activo, solo al elegir un tema.", flush=True)
    try:
        while True:
            time.sleep(0.4)
            try:
                new_revision, theme = event()
                if new_revision == revision:
                    continue
                revision = new_revision
                image = asset_for(theme)   # Fallar cerrado, no reemplazar por otras fotos.
                if not did_backup:
                    backup_kde_settings()
                    did_backup = True
                cmd = [tool, "--fill-mode", "stretch", str(image)]
                done = subprocess.run(cmd, capture_output=True, text=True,
                                      timeout=15, check=False)
                if done.returncode != 0:
                    print("No se pudo aplicar wallpaper:", (done.stderr or done.stdout).strip(), flush=True)
                else:
                    print("Tema", theme, "→ wallpaper estirado:", image, flush=True)
            except Exception as exc:
                print("SmartBar wallpapers: no se aplicó el cambio:", exc, flush=True)
    except KeyboardInterrupt:
        return 0


if __name__ == "__main__":
    sys.exit(main())
