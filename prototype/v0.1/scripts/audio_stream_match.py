"""Asociación conservadora de AppId KDE con streams PipeWire.

Módulo puro, sin llamadas al sistema, sin control de volumen y sin caché.
No infiere identidad por nombre, PID, binario ni número de nodo.
"""
import re

NODE_TYPE = "PipeWire:Interface:Node"
CLIENT_TYPE = "PipeWire:Interface:Client"
OUTPUT_STREAM = "Stream/Output/Audio"
IDENTITY_KEYS = ("application.id", "pipewire.access.portal.app_id")


def valid_app_id(value):
    """Solo AppId explícitos, exactos y no ambiguos; no corregir sufijos."""
    if (not isinstance(value, str) or not 1 <= len(value) <= 255
            or re.fullmatch(r"[A-Za-z0-9_.-]+", value) is None):
        return None
    return value


def numeric_id(value):
    """Node/Client ID temporal: solo número entero no negativo canónico."""
    if isinstance(value, bool):
        return None
    try:
        number = int(value)
    except (TypeError, ValueError, OverflowError):
        return None
    if number < 0 or str(value).strip() != str(number):
        return None
    return number


def is_type(item, expected):
    return isinstance(item, dict) and (
        str(item.get("type", "")).split("/")[0] == expected)


def properties(item):
    info = item.get("info", {})
    if not isinstance(info, dict):
        return {}
    props = info.get("props", {})
    return props if isinstance(props, dict) else {}


def identity_from_sources(*sources):
    """Devuelve (AppId, conflicto, candidatos): falla cerrado ante desacuerdos."""
    identities = set()
    malformed = False
    for source in sources:
        for key in IDENTITY_KEYS:
            value = source.get(key)
            if value is None or value == "":
                continue
            candidate = valid_app_id(value)
            if candidate is None:
                malformed = True
            else:
                identities.add(candidate)
    if malformed or len(identities) > 1:
        return None, True, identities
    return next(iter(identities)) if identities else None, False, identities


def match_kde_app_id(app_id, objects):
    """Busca coincidencias puntuales de AppId, sin autorizar acciones.

    status: invalid, conflict, none, single, multiple
    nodes: IDs informativos solo de esta captura, NO reutilizables para mutear.
    conflicts: nodos donde una de las identidades apunta al AppId consultado
               pero otra fuente declara una identidad distinta.
    """
    if not isinstance(objects, list):
        raise ValueError("pw-dump debe proporcionar un arreglo JSON")
    target = valid_app_id(app_id)
    result = {"app_id": target, "status": "invalid", "nodes": [],
              "conflicts": [], "streams_seen": 0, "unidentified": 0}
    if target is None:
        return result

    clients = {}
    for item in objects:
        if not is_type(item, CLIENT_TYPE):
            continue
        client_id = numeric_id(item.get("id"))
        if client_id is not None:
            clients[client_id] = properties(item)

    for item in objects:
        if not is_type(item, NODE_TYPE):
            continue
        node = properties(item)
        if node.get("media.class") != OUTPUT_STREAM:
            continue
        node_id = numeric_id(item.get("id"))
        if node_id is None:
            continue
        result["streams_seen"] += 1
        client = clients.get(numeric_id(node.get("client.id")), {})
        identity, conflict, candidates = identity_from_sources(node, client)
        if conflict:
            if target in candidates:
                result["conflicts"].append(node_id)
            continue
        if identity is None:
            result["unidentified"] += 1
        elif identity == target:
            result["nodes"].append(node_id)

    result["nodes"].sort()
    result["conflicts"].sort()
    # Un conflicto relevante invalida cualquier aparente vínculo único.
    if result["conflicts"]:
        result["status"] = "conflict"
    elif not result["nodes"]:
        result["status"] = "none"
    elif len(result["nodes"]) == 1:
        result["status"] = "single"
    else:
        result["status"] = "multiple"
    return result
