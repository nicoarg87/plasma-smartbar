#!/usr/bin/env bash
# Plasma SmartBar — diagnóstico no invasivo de miniaturas de ventanas Wayland.
# Solo inspecciona paquetes KDE instalados; NO solicita capturas, no muta audio,
# no altera KWin/Plasma ni lee los archivos personales del usuario.
set -u

echo "Plasma SmartBar: compatibilidad de miniaturas (solo lectura)"
echo "Sesión: ${XDG_SESSION_TYPE:-desconocida}"
if [[ "${XDG_SESSION_TYPE:-}" != "wayland" ]]; then
    echo "AVISO: esta prueba está diseñada para KDE/Wayland."
fi

for command_name in qml6 kpackagetool6; do
    if command -v "$command_name" >/dev/null 2>&1; then
        echo "$command_name: disponible"
    else
        echo "$command_name: no encontrado"
    fi
done

qml_root=""
if command -v qtpaths6 >/dev/null 2>&1; then
    qml_root="$(qtpaths6 --query QT_INSTALL_QML 2>/dev/null || true)"
fi
qml_candidates=()
if [[ -n "$qml_root" ]]; then qml_candidates+=("$qml_root"); fi
qml_candidates+=("/usr/lib/qt6/qml" "/usr/lib64/qt6/qml")
found_pipewire=0
found_tasks=0
for folder in "${qml_candidates[@]}"; do
    if [[ -f "$folder/org/kde/pipewire/qmldir" ]]; then found_pipewire=1; fi
    if [[ -f "$folder/org/kde/taskmanager/qmldir" ]]; then found_tasks=1; fi
done
echo "Módulo QML org.kde.pipewire: $([[ $found_pipewire == 1 ]] && echo disponible || echo no-detectado)"
echo "Módulo QML org.kde.taskmanager: $([[ $found_tasks == 1 ]] && echo disponible || echo no-detectado)"

tooltip=""
for candidate in \
    "/usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/ui/PipeWireThumbnail.qml" \
    "/usr/share/plasma/plasmoids/org.kde.plasma.icontasks/contents/ui/PipeWireThumbnail.qml"; do
    if [[ -f "$candidate" ]]; then tooltip="$candidate"; break; fi
done
if [[ -n "$tooltip" ]]; then
    echo "Componente de miniatura del gestor KDE: presente"
    for signature in "ScreencastingRequest" "PipeWireSourceItem" "isReadyForPainting" "IsMapped"; do
        if grep -qF "$signature" "$tooltip"; then
            echo "  $signature: referencia encontrada"
        else
            echo "  $signature: sin referencia (puede estar en otra pieza del gestor)"
        fi
    done
else
    echo "Componente de miniatura del gestor KDE: no localizado en rutas estándar"
fi

echo "Capturas solicitadas: ninguna"
echo "Permisos nuevos concedidos: ninguno"
echo "Panel instalado y volumen de audio: sin modificaciones"
