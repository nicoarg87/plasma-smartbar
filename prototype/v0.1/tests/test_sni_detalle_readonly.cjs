#!/usr/bin/env node
"use strict";
// Busctl simulado: se verifican las llamadas sin acceder a la bandeja de KDE.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const {spawnSync} = require("node:child_process");
const script = path.resolve(__dirname, "../scripts/inspeccionar_bandeja_sni_detalle.cjs");
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "smartbar-sni-detail-"));
try {
    const fakeBusctl = [
        "#!/usr/bin/env bash",
        "printf '%s\\n' \"$*\" >> \"$SMARTBAR_MOCK_CALLS\"",
        "[[ \"$3\" == \"get-property\" ]] || exit 9",
        "if [[ -n \"$SMARTBAR_NO_WATCHER\" && \"$7\" == 'RegisteredStatusNotifierItems' ]]; then exit 1; fi",
        "case \"$7\" in",
        " RegisteredStatusNotifierItems) printf 'as 1 \":1.54/StatusNotifierItem\"\\n' ;;",
        " Id) printf 's \"demo-app\"\\n' ;;",
        " Title) printf 's \"Aplicación de prueba\"\\n' ;;",
        " Status) printf 's \"Active\"\\n' ;;",
        " IconName) printf 's \"sample-icon\"\\n' ;;",
        " Menu) printf 'o \"/MenuBar\"\\n' ;;",
        " *) exit 1 ;;",
        "esac"
    ].join("\n") + "\n";
    fs.writeFileSync(path.join(tmp, "busctl"), fakeBusctl, {mode:0o755});
    const calls = path.join(tmp, "calls.txt");
    const env = {...process.env, PATH:tmp + path.delimiter + process.env.PATH,
        SMARTBAR_MOCK_CALLS:calls};
    const run = extraEnv => spawnSync(process.execPath, [script], {
        env:{...env, ...extraEnv}, encoding:"utf8", timeout:10000
    });
    const result = run({});
    assert.equal(result.status, 0, result.stderr);
    assert.match(result.stdout, /Indicadores SNI registrados: 1/);
    assert.match(result.stdout, /Servicio: :1\.54/);
    assert.match(result.stdout, /Aplicación: demo-app/);
    assert.match(result.stdout, /Título: Aplicación de prueba/);
    assert.match(result.stdout, /Nombre de icono: sample-icon/);
    assert.match(result.stdout, /Menú remoto anunciado: sí/);
    const recorded = fs.readFileSync(calls, "utf8").trim().split("\n");
    assert.ok(recorded.length >= 6);
    assert.ok(recorded.every(line => line.includes("get-property")));
    assert.ok(recorded.every(line => !/\bcall\b|set-property|RegisterStatusNotifier/.test(line)));
    const missing = run({SMARTBAR_NO_WATCHER:"1"});
    assert.equal(missing.status, 4);
    assert.match(missing.stderr, /No se pudo consultar un watcher SNI/);
    console.log("OK: identificación SNI, sin llamadas que modifiquen KDE.");
} finally {
    fs.rmSync(tmp, {recursive:true,force:true});
}
