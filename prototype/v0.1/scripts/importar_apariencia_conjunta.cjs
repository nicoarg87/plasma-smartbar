"use strict";
// Primera copia privada de appearanceV1 del VISOR al ensayo LayerShell.
// Nunca modifica la fuente Qt histórica ni reemplaza un perfil compartido.
const fs = require("node:fs");
const path = require("node:path");
if (process.argv.length !== 4) {
    console.error("Uso: node importar_apariencia_conjunta.cjs <log-lector-qt> <perfil-privado>");
    process.exit(2);
}
const input = process.argv[2];
const destination = process.argv[3];
if (fs.existsSync(destination)) {
    console.log("SmartBar: perfil conjunto existente conservado, sin sobreescribir.");
    process.exit(0);
}
let log;
try { log = fs.readFileSync(input, "utf8"); } catch {
    console.error("SmartBar: no se pudo leer el visor Qt; sin perfil nuevo.");
    process.exit(3);
}
const marker = "SMARTBAR_PLAYA_FACTORY_CANDIDATE=";
const line = log.split("\n").find(row => row.includes(marker));
if (!line) {
    console.error("SmartBar: el lector Qt no informó apariencia; no se inventan valores.");
    process.exit(4);
}
let appearance;
try {
    const candidate = JSON.parse(line.slice(line.indexOf(marker) + marker.length));
    if (typeof candidate.appearance !== "string" || !candidate.appearance.length)
        throw Error("appearanceV1 ausente");
    appearance = JSON.parse(candidate.appearance);
    if (!appearance || Array.isArray(appearance) || typeof appearance !== "object" ||
        Object.keys(appearance).length < 10 ||
        !Object.keys(appearance).some(key => key.startsWith("demoMalvina")))
        throw Error("Apariencia incompleta");
} catch {
    console.error("SmartBar: apariencia original no legible; conservar archivos sin cambios.");
    process.exit(5);
}
const json = JSON.stringify(appearance);
if (Buffer.byteLength(json) > 200000) {
    console.error("SmartBar: apariencia demasiado grande; sin cambios.");
    process.exit(6);
}
try {
    fs.mkdirSync(path.dirname(destination), {recursive:true,mode:0o700});
    fs.writeFileSync(destination,json,{encoding:"utf8",mode:0o600,flag:"wx"});
} catch (error) {
    if (error && error.code === "EEXIST") process.exit(0);
    console.error("SmartBar: no se pudo crear perfil privado.");
    process.exit(7);
}
console.log("SmartBar: apariencia guardada del visor importada; "+
    Object.keys(appearance).length+" campos originales preservados.");
