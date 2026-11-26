#!/usr/bin/env node
"use strict";
// Compara la fórmula anterior con su extracción pura, sin iniciar KDE ni Qt.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const dir = path.resolve(__dirname, "../package/contents/ui");
const mathSource = fs.readFileSync(path.join(dir, "SoledadBreathingMath.js"), "utf8");
const qml = fs.readFileSync(path.join(dir, "SmartBarContent.qml"), "utf8");
const context = { Math };
vm.createContext(context);
vm.runInContext(mathSource.replace(/^\.pragma library\s*/m, ""), context);
const oldFactor = (intensity, phase) => {
  const wave = 0.5 - 0.5 * Math.cos(2 * Math.PI * phase);
  const amplitude = Math.max(0, Math.min(1, intensity)) * 0.65;
  return 1 - amplitude * (1 - wave);
};
const oldPhase = (phase, speed, dt) =>
  (phase + Math.max(0.1, Math.min(3, speed)) * dt) % 1;
let checks = 0;
for (const i of [-2, -0.1, 0, 0.2, 0.6, 1, 1.5, 4])
  for (const p of [-0.5, 0, 0.05, 0.2, 0.5, 0.9, 1, 2]) {
    assert.equal(context.breathingFactor(i, p), oldFactor(i, p));
    checks++;
  }
for (const p of [0, 0.1, 0.45, 0.9, 0.99])
  for (const speed of [-1, 0, 0.1, 0.6, 1.5, 3, 5])
    for (const dt of [0, 0.01, 0.05, 0.2]) {
      assert.equal(context.nextPhase(p, speed, dt), oldPhase(p, speed, dt));
      checks++;
    }
assert.match(qml, /import "SoledadBreathingMath\.js" as SoledadBreathingMath/);
assert.match(qml, /return SoledadBreathingMath\.breathingFactor\(intensity, phase\)/);
assert.equal((qml.match(/SoledadBreathingMath\.nextPhase\(/g) || []).length, 3);
assert.match(qml, /running: root\.anyGradientBreathingActive/);
assert.match(qml, /interval: 50/);
assert.match(qml, /if \(root\.sharedBreathingActive\)/);
assert.match(qml, /if \(root\.soledadGradientBreathingActive && !root\.soledadGradientSyncBreathing\)/);
assert.match(qml, /if \(root\.malvinaGradientBreathingActive && !root\.malvinaGradientSyncBreathing\)/);
console.log("OK: " + checks + " comparaciones idénticas; temporizador y condiciones intactos.");
