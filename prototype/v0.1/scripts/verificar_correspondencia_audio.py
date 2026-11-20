#!/usr/bin/env python3
"""Relacionar un AppId observado en KDE con streams PipeWire (solo lectura).

Ejecución Fish:
    python3 prototype/v0.1/scripts/verificar_correspondencia_audio.py --kde-app-id com.brave.Browser
Para pruebas sintéticas: ... --kde-app-id com.brave.Browser --stdin < fixture.json

No consulta el modelo KDE en vivo: el AppId se copia del visor de KDE.
No escribe en PipeWire ni controla volumen, y no retiene IDs entre llamadas.
"""
import argparse
import json
import subprocess
import sys

from audio_stream_match import match_kde_app_id

MESSAGES = {
    "none": "Sin coincidencias de AppId en los streams actuales.",
    "single": "Un stream declara exactamente el AppId consultado.",
    "multiple": "Varios streams declaran exactamente el AppId consultado.",
    "conflict": "Metadatos de identidad en conflicto. No hay asociación segura.",
}


def main(argv=None):
    parser = argparse.ArgumentParser(
        description="Cruza un AppId de KDE con streams PipeWire sin modificarlos.")
    parser.add_argument("--kde-app-id", required=True,
                        help="ID exacto que se ve en el visor de ventanas de KDE")
    parser.add_argument("--stdin", action="store_true",
                        help="recibir un pw-dump de prueba por entrada estándar")
    args = parser.parse_args(argv)
    try:
        if args.stdin:
            raw = sys.stdin.read()
        else:
            # Único comando externo: lectura de PipeWire, nunca cambios de volumen.
            raw = subprocess.run(
                ["pw-dump"], capture_output=True, text=True,
                check=True, timeout=12).stdout
        result = match_kde_app_id(args.kde_app_id, json.loads(raw))
    except (ValueError, UnicodeError) as error:
        print("Datos de PipeWire inválidos: {}".format(error),
              file=sys.stderr)
        return 2
    except FileNotFoundError:
        print("No se encontró pw-dump; no se modificó audio.",
              file=sys.stderr)
        return 2
    except subprocess.TimeoutExpired:
        print("PipeWire excedió el tiempo de consulta; sin cambios.",
              file=sys.stderr)
        return 2
    except subprocess.CalledProcessError as error:
        print("No se pudo consultar PipeWire (código {}).".format(
            error.returncode), file=sys.stderr)
        return 2

    print("Plasma SmartBar · correspondencia KDE/PipeWire · SOLO LECTURA")
    if result["status"] == "invalid":
        print("AppId inválido. Copiá exactamente la línea ID: del visor KDE.")
        return 2
    print("AppId aportado desde KDE: {}".format(result["app_id"]))
    print("Streams de reproducción observados: {}".format(
        result["streams_seen"]))
    print("Streams sin identidad verificable: {}".format(
        result["unidentified"]))
    print("Resultado: {}".format(MESSAGES[result["status"]]))
    if result["nodes"]:
        print("Nodos de esta captura (temporales): {}".format(
            ", ".join(map(str, result["nodes"]))))
    if result["conflicts"]:
        print("Nodos con identidad contradictoria: {}".format(
            ", ".join(map(str, result["conflicts"]))))
    print("La igualdad de AppId es una correlación declarada, NO una")
    print("autorización de control. NO usar los IDs para wpctl set-mute")
    print("ni set-volume. No se alteró el sonido ni el panel KDE.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
