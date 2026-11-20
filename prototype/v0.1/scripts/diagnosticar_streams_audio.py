#!/usr/bin/env python3
"""Diagnóstico de streams de salida PipeWire, estrictamente de solo lectura.

Uso: python3 prototype/v0.1/scripts/diagnosticar_streams_audio.py
Pruebas: cat muestra.json | python3 .../diagnosticar_streams_audio.py --stdin

Lee un instante con pw-dump. No ejecuta wpctl, no modifica volumen,
no conserva IDs entre ejecuciones y no muestra metadatos de reproducción.
"""
import argparse
import json
import re
import subprocess
import sys

STREAM_CLASS = "Stream/Output/Audio"
NODE_TYPE = "PipeWire:Interface:Node"
CLIENT_TYPE = "PipeWire:Interface:Client"


def valid_id(value):
    """Aceptar solo identificadores numéricos; nunca inferir otros tipos."""
    if isinstance(value, bool):
        return None
    try:
        candidate = int(value)
    except (TypeError, ValueError):
        return None
    return candidate if candidate >= 0 and str(value).strip() == str(candidate) else None


def clean(value, limit=72):
    """Salida humana breve sin caracteres de control ni secuencias ANSI."""
    if value is None:
        return "—"
    text = re.sub(r"[\x00-\x1f\x7f-\x9f]", " ", str(value))
    text = " ".join(text.split()).strip()
    return text[:limit] if text else "—"


def props_of(item):
    info = item.get("info")
    if not isinstance(info, dict):
        return {}
    props = info.get("props")
    return props if isinstance(props, dict) else {}


def type_is(item, expected):
    return str(item.get("type", "")).split("/")[0] == expected


def streams_from_dump(objects):
    """Solo Nodes de salida de audio; completar metadatos desde Clients."""
    if not isinstance(objects, list):
        raise ValueError("pw-dump debe devolver un arreglo JSON de objetos")

    clients = {}
    for item in objects:
        if not isinstance(item, dict) or not type_is(item, CLIENT_TYPE):
            continue
        client_id = valid_id(item.get("id"))
        if client_id is not None:
            clients[client_id] = props_of(item)

    found = []
    for item in objects:
        if not isinstance(item, dict) or not type_is(item, NODE_TYPE):
            continue
        props = props_of(item)
        if props.get("media.class") != STREAM_CLASS:
            continue
        stream_id = valid_id(item.get("id"))
        if stream_id is None:
            continue
        client_props = clients.get(valid_id(props.get("client.id")), {})

        def field(*keys):
            for key in keys:
                for source in (props, client_props):
                    value = source.get(key)
                    if value is not None and str(value).strip():
                        return clean(value)
            return "—"

        # No imprimir títulos multimedia, URLs, rutas personales ni el JSON.
        found.append({
            "id": stream_id,
            "application": field("application.name"),
            "desktop_id": field("application.id", "pipewire.access.portal.app_id"),
            "process": field("application.process.binary"),
            "pid": field("application.process.id"),
            "state": clean(item.get("info", {}).get("state"))
                if isinstance(item.get("info"), dict) else "—",
        })
    return sorted(found, key=lambda s: s["id"])


def main(argv=None):
    parser = argparse.ArgumentParser(
        description="Muestra solo los streams de reproducción de PipeWire.")
    parser.add_argument(
        "--stdin", action="store_true",
        help="leer un volcado JSON de prueba desde la entrada estándar")
    args = parser.parse_args(argv)

    try:
        if args.stdin:
            raw = sys.stdin.read()
        else:
            # ÚNICA operación externa: consulta de solo lectura.
            raw = subprocess.run(
                ["pw-dump"], capture_output=True, text=True,
                check=True, timeout=12).stdout
        streams = streams_from_dump(json.loads(raw))
    except FileNotFoundError:
        print("No se encontró pw-dump. No se modificó el audio.", file=sys.stderr)
        return 2
    except subprocess.TimeoutExpired:
        print("pw-dump excedió el tiempo de consulta. Sin cambios.", file=sys.stderr)
        return 2
    except subprocess.CalledProcessError as error:
        print("No se pudo consultar PipeWire (código {}).".format(
            error.returncode), file=sys.stderr)
        return 2
    except (ValueError, UnicodeError) as error:
        print("Respuesta JSON inválida: {}".format(error), file=sys.stderr)
        return 2

    print("Plasma SmartBar · diagnóstico de audio de SOLO LECTURA")
    print("Streams de reproducción detectados: {}".format(len(streams)))
    for stream in streams:
        print("")
        print("  Nodo temporal: {}".format(stream["id"]))
        print("  Aplicación: {}".format(stream["application"]))
        print("  ID de aplicación: {}".format(stream["desktop_id"]))
        print("  Binario: {}".format(stream["process"]))
        print("  PID informado: {}".format(stream["pid"]))
        print("  Estado del nodo: {}".format(stream["state"]))
    print("")
    print("No se alteró el volumen ni el silencio de ninguna aplicación.")
    print("Los nodos pueden desaparecer o cambiar de ID; esta lista NO")
    print("autoriza usar esos números para set-mute ni set-volume.")
    print("La correspondencia con ventanas KDE todavía NO está validada.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
