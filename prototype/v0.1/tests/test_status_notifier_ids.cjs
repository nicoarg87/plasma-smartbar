#!/usr/bin/env node
"use strict";
// Contratos de SNI: no abrir bus de sesión ni ejecutar comandos.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const ui = path.resolve(__dirname, "../package/contents/ui");
const source = fs.readFileSync(path.join(ui, "StatusNotifierIds.js"), "utf8");
assert.match(source, /^\.pragma library\s/);
const sandbox = {};
vm.runInNewContext(source.replace(/^\.pragma library\s*/, ""), sandbox);
function same(actual, expected) {
    assert.deepEqual(JSON.parse(JSON.stringify(actual)), expected);
}
same(sandbox.parseRegisteredId("org.kde.StatusNotifierItem-102-1"), {
    service: "org.kde.StatusNotifierItem-102-1",
    objectPath: "/StatusNotifierItem",
    key: "org.kde.StatusNotifierItem-102-1/StatusNotifierItem"
});
same(sandbox.parseRegisteredId(":1.987/Custom_Item"), {
    service: ":1.987", objectPath: "/Custom_Item", key: ":1.987/Custom_Item"
});
const invalid = [
    null, 0, {}, "", "solo", ".org.kde.App", "org.kde.App ",
    "org.kde.App/../X", "org.kde.App//X", "org.kde.App/X-Y",
    "org.kde.App/X\nY", "org.kde.App/X;rm", "org.kde.App/X?foo=1",
    "org.kde.App/\u0000", "org.kde.App/../etc/passwd",
    "org.kde.App".repeat(60)
];
for (const item of invalid)
    assert.equal(sandbox.parseRegisteredId(item), null, "descartar ID inválido");
same(sandbox.normalizeRegisteredIds([
    "org.kde.StatusNotifierItem-102-1",
    "org.kde.StatusNotifierItem-102-1/StatusNotifierItem",
    ":1.987/Custom_Item", "no válido", ":1.987/Custom_Item"
]), [
    {service:"org.kde.StatusNotifierItem-102-1",objectPath:"/StatusNotifierItem",
     key:"org.kde.StatusNotifierItem-102-1/StatusNotifierItem"},
    {service:":1.987",objectPath:"/Custom_Item",key:":1.987/Custom_Item"}
]);
same(sandbox.normalizeRegisteredIds(undefined), []);
same(sandbox.normalizeRegisteredIds("texto"), []);
const original = ["org.kde.App/StatusNotifierItem"];
const normalized = sandbox.normalizeRegisteredIds(original);
normalized.pop();
assert.equal(original.length, 1, "no mutar el registro recibido");
assert.doesNotMatch(source, /QProcess|exec\(|dbus-send|system\(|spawn\(/);
console.log("OK: identificadores SNI, deduplicación y validación sin E/S.");
