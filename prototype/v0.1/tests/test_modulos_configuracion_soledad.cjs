#!/usr/bin/env node
"use strict";
// Las vistas modulares no son dueñas del guardado ni de las preferencias.
// Protege el traslado de las secciones "Cajón y ventanas" y "Ayuda".
// No inicia Qt, KDE ni toca las configuraciones personales.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "../package/contents/ui");
const read = name => fs.readFileSync(path.join(base, name), "utf8");
const host = read("SoledadSettings.qml");
const task = read("SoledadTaskStylesPage.qml");
const about = read("SoledadAboutPage.qml");

assert.match(host, /SoledadTaskStylesPage\s*\{\s*settingsTarget: settings\s*colorDialog: taskFrameColorDialog/);
assert.match(host, /SoledadAboutPage\s*\{/);
assert.match(host, /function applyChanges\(\)/,
    "Aplicar sigue bajo control de la ventana existente");
assert.match(host, /function discardPendingEdits\(\)/,
    "Cerrar y Cancelar continúan descartando cambios sin aplicar");
assert.match(host, /function captureSettingsBaseline\(\)/,
    "el centro sigue controlando los valores aplicados");
assert.match(host, /readonly property var editableSettingsKeys:/,
    "las preferencias no se duplican en las páginas");
assert.match(host, /id: taskFrameColorDialog/,
    "el diálogo de colores existente continúa siendo compartido");

assert.match(task, /QQC2\.ScrollView\s*\{\s*id: page/);
assert.match(task, /property var settingsTarget: null/);
assert.match(task, /property var colorDialog: null/);
assert.match(task, /width: Math\.max\(0, page\.availableWidth - 32\)/);
assert.match(task, /model: \["Solo nombre", "Icono y nombre", "Solo icono"\]/);
assert.match(task, /page\.settingsTarget\.taskDisplayMode = \["text", "both", "icon"\]\[i\]/);
assert.match(task, /model: \["X en ficha y vista previa",/);
assert.match(task, /page\.settingsTarget\.taskCloseMode = \["both", "preview", "chip"\]\[i\]/);
assert.match(task, /Accessible\.name: "Ubicación del cierre de ventanas SO"/);
for (const field of ["taskActiveGlowEnabled", "taskActiveDoubleBorderEnabled",
                    "taskFrameShape", "taskFrameColor", "taskFrameOpacity",
                    "taskFrameWidth"])
    assert(task.includes("page.settingsTarget." + field), "Falta preferencia " + field);
assert.match(task, /page\.colorDialog\.selectedColor = page\.settingsTarget\.taskFrameColor/);
assert.match(task, /page\.colorDialog\.open\(\)/);
assert.doesNotMatch(task, /\btaskStylesScroll\b|\btaskFrameColorDialog\b|\bsettings\./,
    "La vista nueva no puede depender de IDs privados de la ventana");
assert.doesNotMatch(task, /function applyChanges\(|QtCore\.Settings|qdbus|QProcess/,
    "El guardado y los accesos a KDE siguen en el anfitrión");
assert(!host.includes('id: taskStylesScroll'),
    "No crear una segunda instancia del editor anterior");

assert.match(about, /QQC2\.ScrollView\s*\{\s*id: page/);
assert.match(about, /width: Math\.max\(0, page\.availableWidth - 32\)/);
for (const fragment of ["Ayuda rápida", "Abrir manual del proyecto",
      "Autor: nicoarg87", "Contacto para consultas: nicoarg87@gmail.com",
      "Enviar una consulta por correo", "Abrir repositorio oficial",
      "SIN NINGUNA GARANTÍA", "Leer licencia MIT",
      "Licencias de recursos gráficos"])
    assert(about.includes(fragment), "Contenido histórico de Ayuda perdido: " + fragment);
assert.doesNotMatch(about, /\baboutScroll\b|\bsettings\./,
    "La página de ayuda no debe depender del estado del centro");
assert(!host.includes('id: aboutScroll'), "No duplicar la página Ayuda");
assert(!/text: "Guardar ajustes"/.test(task + about),
       "No crear botones de guardado adicionales");
console.log("OK: páginas de fichas SO y Ayuda desacopladas; Aplicar y preferencias intactos.");
