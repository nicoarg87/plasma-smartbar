// Prueba aislada y reversible de la politica pura de Malvina.
// Ejecutar desde raiz del repo: node prototype/v0.1/tests/test_malvina_url_policy.cjs
// No inicia Qt, navegador, ventanas KDE ni altera preferencias.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const policyPath = path.resolve(__dirname, "../package/contents/ui/MalvinaUrlPolicy.js");
const code = fs.readFileSync(policyPath, "utf8").replace(/^\.pragma library\s*$/m, "");
const sandbox = {};
vm.createContext(sandbox);
vm.runInContext(code, sandbox, { filename: policyPath });
const good = sandbox.resolve("https://www.google.com/search?q={query}", "hola mundo & ñ", false);
assert.equal(good.ok, true);
assert.equal(good.url, "https://www.google.com/search?q=hola%20mundo%20%26%20%C3%B1");
assert.equal(sandbox.resolve("https://chatgpt.com/", "hola", true).url, "https://chatgpt.com/");
for (const bad of [
    "http://google.com/?q={query}",
    "file:///tmp/test",
    "https://usuario:clave@example.com/?q={query}",
    "https://usuario@example.com/?q={query}",
    "https://localhost/?q={query}",
    "https://example.com:1234/?q={query}",
    "https://example.com\\@evil.com/?q={query}",
    "https://example.com/ a?q={query}"
]) {
    assert.equal(sandbox.resolve(bad, "texto", false).ok, false, bad);
}
assert.equal(sandbox.resolve("https://example.com/search", "texto", false).ok, false);
assert.equal(sandbox.resolve("https://example.com/?q={query}", "", false).ok, false);
console.log("MalvinaUrlPolicy: pruebas aisladas OK");
