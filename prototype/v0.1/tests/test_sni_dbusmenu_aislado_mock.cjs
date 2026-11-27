#!/usr/bin/env node
"use strict";
// Bus simulado: GetLayout se consulta fuera de Qt, sin tocar KDE real.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const {spawnSync} = require("node:child_process");
const script = path.resolve(__dirname, "../scripts/inspeccionar_menu_sni_aislado.cjs");
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "smartbar-sni-menu-isolated-"));
try {
    const fake = [
        "#!/usr/bin/env bash",
        "printf '%s\\n' \"$*\" >> \"$SMARTBAR_MOCK_CALLS\"",
        "if [[ \"$*\" == *'get-property'*'RegisteredStatusNotifierItems'* ]]; then",
        "  [[ -n \"$SMARTBAR_MOCK_NO_WATCHER\" ]] && exit 1",
        "  printf 'as 1 \":1.54/StatusNotifierItem\"\\n'",
        "elif [[ \"$*\" == *'get-property'*' Menu' ]]; then",
        "  if [[ -n \"$SMARTBAR_MOCK_NO_MENU\" ]]; then",
        "    printf 'o \"/\"\\n'",
        "  elif [[ -n \"$SMARTBAR_MOCK_BAD_PATH\" ]]; then",
        "    printf 'o \"/MenuBar/../escape\"\\n'",
        "  else",
        "    printf 'o \"/MenuBar\"\\n'",
        "  fi",
        "elif [[ \"$*\" == *'call :1.54 /MenuBar com.canonical.dbusmenu GetLayout iias 0 1 5 label enabled visible type children-display'* ]]; then",
        "  [[ -n \"$SMARTBAR_MOCK_FAILED\" ]] && exit 1",
        "  if [[ -n \"$SMARTBAR_MOCK_BAD\" ]]; then",
        "    printf '%s\\n' '{\"type\":\"u(ia{sv}av)\",\"data\":[]}'",
        "  else",
        "    printf '%s\\n' '{\"type\":\"u(ia{sv}av)\",\"data\":[1,[0,{},[]]]}'",
        "  fi",
        "else",
        "  exit 9",
        "fi"
    ].join("\n") + "\n";
    fs.writeFileSync(path.join(tmp, "busctl"), fake, {mode:0o755});
    const calls = path.join(tmp, "calls.log");
    const env = {...process.env, PATH:tmp+path.delimiter+process.env.PATH,
                 SMARTBAR_MOCK_CALLS:calls};
    const run = extra => spawnSync(process.execPath, [script], {
        env:{...env,...extra}, encoding:"utf8", timeout:12000
    });
    const ok = run({});
    assert.equal(ok.status, 0, ok.stderr);
    assert.match(ok.stdout, /Menús anunciados: 1/);
    assert.match(ok.stdout, /Respuestas compatibles: 1/);
    assert.match(ok.stdout, /Respuestas no compatibles o fallidas: 0/);

    const bad = run({SMARTBAR_MOCK_BAD:"1"});
    assert.equal(bad.status, 0, bad.stderr);
    assert.match(bad.stdout, /Respuestas compatibles: 0/);
    assert.match(bad.stdout, /Respuestas no compatibles o fallidas: 1/);

    const failed = run({SMARTBAR_MOCK_FAILED:"1"});
    assert.equal(failed.status, 0, failed.stderr);
    assert.match(failed.stdout, /GetLayout no respondió/);

    const empty = run({SMARTBAR_MOCK_NO_MENU:"1"});
    assert.equal(empty.status, 0, empty.stderr);
    assert.match(empty.stdout, /Menús anunciados: 0/);

    const badPath = run({SMARTBAR_MOCK_BAD_PATH:"1"});
    assert.equal(badPath.status, 0, badPath.stderr);
    assert.match(badPath.stdout, /Menús anunciados: 0/);

    const missing = run({SMARTBAR_MOCK_NO_WATCHER:"1"});
    assert.equal(missing.status, 4);
    assert.match(missing.stderr, /No se encontró un watcher SNI/);

    const recorded = fs.readFileSync(calls, "utf8").trim().split("\n");
    assert.ok(recorded.some(line => line.includes("GetLayout")));
    assert.ok(recorded.every(line =>
        line.includes(" get-property ") || line.includes(" call ")));
    assert.ok(recorded.every(line =>
        !/\b(?:Event|Activate|ContextMenu|set-property|RegisterStatusNotifier)\b/.test(line)));
    assert.ok(recorded.filter(line => line.includes(" call ")).every(line =>
        line.includes("GetLayout iias 0 1 5 label enabled visible type children-display")));
    console.log("OK: 6 escenarios DBusMenu aislado, únicamente lectura, sin acciones KDE.");
} finally {
    fs.rmSync(tmp, {recursive:true,force:true});
}
