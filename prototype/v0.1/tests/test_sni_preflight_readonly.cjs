#!/usr/bin/env node
"use strict";
// El ensayo SNI usa un busctl simulado; NO consulta la bandeja real.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const {spawnSync} = require("node:child_process");
const bash = "bash";
const script = path.resolve(__dirname, "../scripts/inspeccionar_bandeja_sni.sh");
const source = fs.readFileSync(script, "utf8");
assert.doesNotMatch(source, /\bsudo\b|\bdbus-send\b|\bset-property\b|\bRegisterStatusNotifierHost\s*\(/);
assert.match(source, /RegisteredStatusNotifierItems/);
assert.match(source, /IsStatusNotifierHostRegistered/);
const syntax = spawnSync(bash, ["-n", script], {encoding:"utf8"});
assert.equal(syntax.status, 0, syntax.stderr);
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "smartbar-sni-mock-"));
try {
    const mock = path.join(tmp, "busctl");
    fs.writeFileSync(mock, [
        "#!/usr/bin/env bash",
        "case \"$*\" in",
        "  *org.kde.StatusNotifierWatcher*RegisteredStatusNotifierItems*) echo 'as 2 \"org.kde.App-1/StatusNotifierItem\" \"org.kde.App-2/StatusNotifierItem\"';;",
        "  *org.kde.StatusNotifierWatcher*IsStatusNotifierHostRegistered*) echo 'b true';;",
        "  *org.kde.StatusNotifierWatcher*ProtocolVersion*) echo 'i 0';;",
        "  *) exit 1;;",
        "esac"
    ].join("\n") + "\n", {mode:0o700});
    const result = spawnSync(bash, [script], {
        env: {...process.env, PATH:tmp + path.delimiter + process.env.PATH},
        encoding:"utf8", timeout:8000
    });
    assert.equal(result.status, 0, result.stderr);
    assert.match(result.stdout, /as 2/);
    assert.match(result.stdout, /b true/);
    assert.match(result.stdout, /panel KDE queda intacto/);
    assert.match(result.stdout, /Sin cambios en KDE/);
    const noWatcher = spawnSync(bash, [script], {
        env: {...process.env, PATH:tmp + path.delimiter + process.env.PATH},
        encoding:"utf8", timeout:8000
    });
    assert.equal(noWatcher.status, 0);
    console.log("OK: introspección SNI solo lectura (busctl simulado), sintaxis Bash válida.");
} finally {
    fs.rmSync(tmp, {recursive:true, force:true});
}
