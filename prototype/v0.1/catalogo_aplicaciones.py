#!/usr/bin/env python3
"""Lista SOLO metadatos públicos de entradas .desktop para el visor QML v0.1.
No ejecuta aplicaciones, no lee archivos personales, no accede a la red.
"""
import configparser
import json
import os
from pathlib import Path
import sys


def directories():
    home = Path.home()
    roots = [Path(os.getenv("XDG_DATA_HOME", str(home / ".local/share")))]
    roots.extend(Path(p) for p in os.getenv("XDG_DATA_DIRS",
                                            "/usr/local/share:/usr/share").split(":") if p)
    roots.extend([home / ".local/share/flatpak/exports/share",
                  Path("/var/lib/flatpak/exports/share")])
    return [root / "applications" for root in roots]


def desktop_info(filename):
    parser = configparser.ConfigParser(interpolation=None, strict=False)
    parser.optionxform = str
    try:
        with filename.open("r", encoding="utf-8", errors="replace") as handle:
            parser.read_file(handle)
        if not parser.has_section("Desktop Entry"):
            return None
        section = parser["Desktop Entry"]
        if section.get("Type", "Application") != "Application":
            return None
        if section.get("Hidden", "false").lower() == "true":
            return None
        if section.get("NoDisplay", "false").lower() == "true":
            return None
        name = (section.get("Name[es_AR]") or section.get("Name[es]")
                or section.get("Name", "")).strip()
        if not name:
            return None
        categories = set(x for x in section.get("Categories", "").split(";") if x)
        if categories & {"Network", "WebBrowser", "Email", "InstantMessaging"}:
            category = "Internet"
        elif "Office" in categories:
            category = "Oficina"
        elif categories & {"AudioVideo", "Audio", "Video", "Music", "Player"}:
            category = "Multimedia"
        elif categories & {"System", "Settings"}:
            category = "Sistema"
        elif "Utility" in categories:
            category = "Utilidades"
        elif "Education" in categories:
            category = "Educación"
        elif "Game" in categories:
            category = "Juegos"
        elif "Graphics" in categories:
            category = "Gráficos"
        elif "Development" in categories:
            category = "Desarrollo"
        elif "Science" in categories:
            category = "Ciencia"
        else:
            category = "Otras"
        # Solo metadatos del lanzador KDE; no ejecutar Exec= ni cargar
        # archivos de usuario. Los iconos de tema se resuelven localmente.
        icon_value = section.get("Icon", "").strip()
        icon_name = ""
        icon_source = ""
        if icon_value.startswith("/") and Path(icon_value).suffix.lower() in {
            ".png", ".svg", ".svgz", ".xpm", ".jpg", ".jpeg", ".webp"
        }:
            icon_source = Path(icon_value).as_uri()
        elif icon_value and "/" not in icon_value and "\\" not in icon_value:
            icon_name = icon_value[:180]
        return {"name": name[:160], "category": category,
                "desktopId": filename.name,
                "icon": icon_name, "iconSource": icon_source}
    except (OSError, UnicodeError, configparser.Error):
        return None


def main():
    if len(sys.argv) != 2:
        raise SystemExit("Uso: catalogo_aplicaciones.py /ruta/catalogo.json")
    output = Path(sys.argv[1])
    seen = set()
    results = []
    for folder in directories():
        if not folder.is_dir():
            continue
        try:
            candidates = sorted(folder.glob("*.desktop"))
        except OSError:
            continue
        for file in candidates:
            desktop_id = file.name.casefold()
            if desktop_id in seen:
                continue
            seen.add(desktop_id)
            parsed = desktop_info(file)
            if parsed is not None:
                results.append(parsed)
    results.sort(key=lambda item: (item["category"], item["name"].casefold()))
    with output.open("x", encoding="utf-8") as stream:
        json.dump(results, stream, ensure_ascii=False)
    print(f"SmartBar: {len(results)} aplicaciones .desktop detectadas (solo lectura).")


if __name__ == "__main__":
    main()
