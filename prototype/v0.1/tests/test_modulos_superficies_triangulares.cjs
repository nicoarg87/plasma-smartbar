#!/usr/bin/env node
"use strict";
// Comprobación estructural de superficies triangulares sin iniciar KDE.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const dir = path.resolve(__dirname, "../package/contents/ui");
const main = fs.readFileSync(path.join(dir, "SmartBarContent.qml"), "utf8");
const so = fs.readFileSync(path.join(dir, "SoledadTipBackground.qml"), "utf8");
const mal = fs.readFileSync(path.join(dir, "MalvinaTipSurface.qml"), "utf8");
for (const name of ["SoledadTipBackground", "MalvinaTipSurface"]) {
  assert.match(main, new RegExp(name + "\\s*\\{\\s*host:\\s*root\\s*anchors\\.fill:\\s*parent\\s*\\}"));
  assert.equal((main.match(new RegExp(name + "\\s*\\{", "g")) || []).length, 1);
}
for (const [label, view, tokens] of [
 ["Soledad", so, [
   'visible: host.soledadShape === "leftTip"',
   "function onSoledadColorChanged()",
   "function onDisplaySoledadColorChanged()",
   "function onGradientBreathingFactorChanged()",
   "host.soledadGradientColorCount === 3",
   "host.soledadOpacity * host.gradientBreathingFactor",
   'ctx.strokeStyle = "#4e8499"',
   "ctx.fill()",
   "ctx.stroke()"
 ]],
 ["Malvina", mal, [
   'visible: host.malvinaShape === "leftTip"',
   "function onMalvinaColorChanged()",
   "function onDisplayOutlineMalvinaColorChanged()",
   "function onMalvinaGradientBreathingFactorChanged()",
   "function onOutlineConfigChanged()",
   "host.malvinaGradientColorCount === 3",
   "host.outlineConfig.malvina",
   "ctx.globalAlpha = outline.opacity",
   "ctx.fill()",
   "ctx.stroke()"
 ]]
]) {
  assert.ok(view.includes("required property var host"), label + ": falta host");
  assert.ok(view.includes("target: host"), label + ": falta Connections");
  assert.ok(view.includes("canvas.requestPaint()"), label + ": falta repintado");
  assert.doesNotMatch(view, /\broot\.|\bQtCore\.Settings\b/, label + ": dependencia indebida");
  for (const token of tokens) assert.ok(view.includes(token), label + ": falta " + token);
}
assert.doesNotMatch(main, /id:\s*(soTipBackground|malvinaTipSurface)\b/);
console.log("OK: superficies triangulares modulares con apariencia y repintado originales.");
