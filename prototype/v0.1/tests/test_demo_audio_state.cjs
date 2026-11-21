// Regresión de estado de audio ficticio tras extraerlo del núcleo QML.
// Sin PipeWire, KDE, procesos o persistencia de configuración.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const ui = path.resolve(__dirname, "../package/contents/ui");
const source = fs.readFileSync(path.join(ui, "DemoAudioState.js"), "utf8");
const bar = fs.readFileSync(path.join(ui, "SmartBarContent.qml"), "utf8");
assert(source.startsWith(".pragma library\n"));
assert(bar.includes('import "DemoAudioState.js" as DemoAudioState'));
const audio = {};
vm.runInNewContext(source.replace(/^\s*\.pragma library\s*/, ""), audio);

let muted = {}, volumes = {};
assert.equal(audio.volume(volumes, "Dolphin"), 70, "Valor visual original 70 %");
assert.equal(audio.volume(volumes, "Brave"), 70);
assert.equal(audio.isMuted(muted, volumes, "Dolphin"), false);
const changed = audio.setVolume(muted, volumes, "Dolphin", 33.6);
assert.equal(changed.volumes.Dolphin, 34);
assert.equal(changed.muted.Dolphin, false);
assert.equal(volumes.Dolphin, undefined, "Estado previo inmutable");
assert.equal(muted.Dolphin, undefined, "Mute previo inmutable");
volumes = changed.volumes;
muted = changed.muted;
assert.equal(audio.volume(volumes, "Brave"), 70, "Sin fuga entre apps");
assert.equal(audio.isMuted(muted, volumes, "Brave"), false);

let next = audio.toggleMute(muted, volumes, "Dolphin");
assert.equal(next.muted.Dolphin, true);
assert.equal(next.volumes, volumes, "Mutear no cambia nivel previo");
assert.equal(next.muted.Brave, undefined);
muted = next.muted;
next = audio.toggleMute(muted, volumes, "Dolphin");
assert.equal(next.muted.Dolphin, false);
assert.equal(next.volumes, volumes, "Desmutear volumen positivo lo conserva");

next = audio.setVolume(muted, volumes, "Dolphin", 0);
assert.equal(next.volumes.Dolphin, 0);
assert.equal(next.muted.Dolphin, true, "0 % implica silencio visual");
assert.equal(audio.isMuted(next.muted, next.volumes, "Dolphin"), true);
const reactivated = audio.toggleMute(next.muted, next.volumes, "Dolphin");
assert.equal(reactivated.muted.Dolphin, false);
assert.equal(reactivated.volumes.Dolphin, 50,
             "Desde 0 % recuperar el nivel ficticio histórico de 50 %");
assert.equal(next.volumes.Dolphin, 0, "No modificar el estado anterior");
assert.equal(audio.setVolume({}, {}, "Brave", 150).volumes.Brave, 100);
assert.equal(audio.setVolume({}, {}, "Brave", -42).volumes.Brave, 0);
assert.equal(audio.setVolume({}, {}, "Brave", "texto").volumes.Brave, 0);
assert.equal(audio.setVolume({}, {}, "Brave", 49.9).volumes.Brave, 50);
assert.equal(audio.isMuted({Brave:true}, {Brave:80}, "Brave"), true);
assert(!/pw-dump|wpctl|pactl|Process\s*\{|requestClose|requestActivate|openUrlExternally/.test(source),
       "El módulo nunca controla audio ni ventanas reales");

for (const name of ["demoAppVolume", "setDemoAppVolume",
                    "demoAppIsMuted", "toggleDemoAppMute"])
    assert(bar.includes("function " + name + "(appName"),
           "Preservar contrato QML de " + name);
assert(bar.includes("if (!demoWindowControlsEnabled || usingRealTasks ||"),
       "Acciones falsas siguen inhabilitadas con TasksModel real");
console.log("OK: estado demo por app modular e inmutable, audio real intacto.");
