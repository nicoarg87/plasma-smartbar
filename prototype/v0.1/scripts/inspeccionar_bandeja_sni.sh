#!/usr/bin/env bash
# Descubrimiento de indicadores KDE SNI en D-Bus: SOLO LECTURA.
# No registra hosts, no instala bandeja ni modifica el panel de Plasma.
set -euo pipefail

if [[ "${1:-}" == "--help" ]]; then
    printf 'Uso: bash prototype/v0.1/scripts/inspeccionar_bandeja_sni.sh\n'
    printf 'Consulta solo lectura de los indicadores KDE publicados en D-Bus.\n'
    exit 0
fi
if (( $# != 0 )); then
    printf 'Opción no reconocida. Usá --help.\n' >&2
    exit 2
fi
if ! command -v busctl >/dev/null 2>&1; then
    printf 'No se encontró busctl; no se ejecutó ningún cambio.\n' >&2
    exit 3
fi

printf 'Plasma SmartBar · inspección SNI (solo lectura)\n'
printf 'Ningún host nuevo será registrado; el panel KDE queda intacto.\n'
found=0
for namespace in org.kde org.freedesktop; do
    service="${namespace}.StatusNotifierWatcher"
    object="/StatusNotifierWatcher"
    interface="$service"
    if items="$(busctl --user --no-pager get-property \
        "$service" "$object" "$interface" RegisteredStatusNotifierItems 2>/dev/null)"; then
        found=1
        printf '\nWatcher: %s\n' "$service"
        printf 'Indicadores registrados: %s\n' "$items"
        if hosts="$(busctl --user --no-pager get-property \
            "$service" "$object" "$interface" IsStatusNotifierHostRegistered 2>/dev/null)"; then
            printf 'Host existente registrado: %s\n' "$hosts"
        fi
        if protocol="$(busctl --user --no-pager get-property \
            "$service" "$object" "$interface" ProtocolVersion 2>/dev/null)"; then
            printf 'Versión del protocolo: %s\n' "$protocol"
        fi
    fi
done
if (( found == 0 )); then
    printf 'No se encontró un StatusNotifierWatcher accesible en la sesión D-Bus.\n' >&2
    printf 'Esto no implica que el escritorio esté dañado; falta comprobar el proveedor disponible.\n' >&2
    exit 4
fi
printf '\nListo: solo se consultaron propiedades. Sin cambios en KDE ni en SmartBar.\n'
