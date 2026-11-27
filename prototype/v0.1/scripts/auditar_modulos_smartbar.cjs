#!/usr/bin/env node
'use strict';
// Auditoría estática informativa: no ejecuta QML ni modifica archivos.
const fs = require('node:fs');
const path = require('node:path');

const root = path.resolve(__dirname, '..');
const uiRoot = path.join(root, 'package', 'contents', 'ui');
const sourceExt = new Set(['.qml', '.js', '.cjs', '.sh', '.cpp', '.h', '.hpp', '.json']);
const moduleExt = new Set(['.qml', '.js']);

function walk(dir) {
    if (!fs.existsSync(dir)) return [];
    const result = [];
    for (const item of fs.readdirSync(dir, {withFileTypes: true})) {
        if (['.git', 'node_modules', 'tests', 'docs'].includes(item.name)) continue;
        const full = path.join(dir, item.name);
        if (item.isDirectory()) result.push(...walk(full));
        else if (item.isFile() && sourceExt.has(path.extname(item.name))) result.push(full);
    }
    return result;
}
function escapeRegExp(text) {
    return text.replace(/[.*+?^$()|[\]{}\\]/g, '\\$&');
}
function stripComments(source) {
    // Aproximación conservadora; no reemplaza un parser QML/JS/C++.
    return source.replace(/\/\*[\s\S]*?\*\//g, '').replace(/^\s*\/\/.*$/gm, '');
}
function isReference(target, code) {
    const stem = path.basename(target, path.extname(target));
    const ext = path.extname(target);
    // QML: instanciación Tipo {; QML/JS: referencia literal Nombre.qml/js.
    const typeRef = ext === '.qml' && new RegExp('\\b' + escapeRegExp(stem) + '\\s*\\{').test(code);
    const literalRef = new RegExp('\\b' + escapeRegExp(stem) + '\\.' + escapeRegExp(ext.slice(1)) + '\\b').test(code);
    return typeRef || literalRef;
}
if (!fs.existsSync(uiRoot)) {
    console.error('No se encuentra la interfaz: ' + uiRoot);
    process.exitCode = 1;
} else {
    const paths = walk(root);
    const sources = paths.filter(file => file !== __filename)
        .map(file => ({file, code: stripComments(fs.readFileSync(file, 'utf8'))}));
    const modules = paths.filter(file => file.startsWith(uiRoot + path.sep) && moduleExt.has(path.extname(file)));
    const records = modules.map(file => {
        const content = fs.readFileSync(file, 'utf8');
        const references = sources.filter(entry => entry.file !== file && isReference(file, entry.code))
            .map(entry => path.relative(root, entry.file));
        return {
            name: path.relative(uiRoot, file),
            lines: content.split('\n').length,
            hostReferences: (content.match(/\bhost\./g) || []).length,
            references
        };
    });
    const candidates = records.filter(r => r.references.length === 0 &&
        !['main.qml', 'configGeneral.qml'].includes(r.name));
    console.log('Auditoría ESTÁTICA de Plasma SmartBar (solo lectura)');
    console.log('Módulos QML/JS: ' + records.length + ' | archivos de producción inspeccionados: ' + sources.length);
    console.log('Líneas QML/JS: ' + records.reduce((sum, r) => sum + r.lines, 0));
    console.log('\nPosibles módulos sin referencias estáticas (NO equivale a código muerto):');
    if (!candidates.length) console.log('  Ninguno detectado con este método.');
    for (const r of candidates) console.log('  - ' + r.name + ' (' + r.lines + ' líneas)');
    console.log('\nComponentes con más accesos a host (acoplamiento aproximado):');
    for (const r of records.filter(r => r.hostReferences)
        .sort((a, b) => b.hostReferences - a.hostReferences).slice(0, 10)) {
        console.log('  - ' + r.name + ': ' + r.hostReferences + ' accesos / ' + r.lines + ' líneas');
    }
    console.log('\nADVERTENCIA: QML permite carga dinámica y existen archivos de prueba.');
    console.log('No borrar nada por este reporte sin verificar entradas, loaders y casos de uso.');
}
