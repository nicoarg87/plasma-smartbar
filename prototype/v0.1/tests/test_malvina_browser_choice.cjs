// Contrato del selector Web/IA en ensayo nativo Malvina.
// No inicia navegador, no modifica KDE ni requiere Qt.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const root = path.resolve(__dirname, "..");
const read = p => fs.readFileSync(path.join(root,p), "utf8");
const cpp = read("native_probes/soledad_input_mask_main.cpp");
const probe = read("preview_malvina_input_mask.qml");
const shared = read("package/contents/ui/SmartBarContent.qml");
const search = read("package/contents/ui/MalvinaSearch.qml");
const page = read("package/contents/ui/MalvinaProvidersPage.qml");
const settings = read("package/contents/ui/SoledadSettings.qml");

for (const fragment of [
    "#include <QDesktopServices>", "#include <QProcess>",
    "#include <QStandardPaths>", "QStandardPaths::findExecutable",
    "Q_INVOKABLE QVariantList availableBrowsers() const",
    "Q_INVOKABLE bool launchWebUrl(", "QUrl::StrictMode",
    'url.scheme() != QLatin1String("https")',
    "QProcess::startDetached(", "QDesktopServices::openUrl(url)"
]) assert(cpp.includes(fragment), "Puente Qt nativo: " + fragment);
assert(!cpp.includes("system(") && !cpp.includes("/bin/sh") &&
       !cpp.includes("QProcess::execute("),
       "Sin shell, sin ejecutar comandos arbitrarios");
for(const name of ["Falkon","Brave","Firefox","Chromium","Google Chrome"])
    assert(cpp.includes('"'+name+'"'), "Detectar "+name+" si está instalado");

for (const executable of [
    "brave", "brave-browser", "brave-browser-stable", "brave-bin", "com.brave.Browser"
]) assert(cpp.includes('{"brave", "Brave", "'+executable+'"}'),
          "Reconocer alias ejecutable de Brave: "+executable);
for (const marker of [
    'QStandardPaths::findExecutable("flatpak")',
    "QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation)",
    ".local/share/flatpak/exports/share/applications/com.brave.Browser.desktop",
    "/var/lib/flatpak/exports/share/applications/com.brave.Browser.desktop",
    "QFileInfo(file).isFile()",
    'if (!discovered.contains(QLatin1String("brave"))',
    'if (browserId == QLatin1String("brave"))',
    'QStringList{"run", "com.brave.Browser"',
    "static QString flatpakBraveExecutable()"
]) assert(cpp.includes(marker), "Brave Flatpak debe detectarse y abrirse de modo controlado: "+marker);
assert(!cpp.includes("QProcess::execute(") &&
       !cpp.includes("desktopFile.exec(") &&
       !cpp.includes("QProcess::startDetached('sh'"),
       "No ejecutar órdenes desconocidas a partir de archivos de escritorio");

assert(probe.includes('category: "plasma-smartbar-v01-malvina-layer-probe-browser"'));
assert(probe.includes('malvinaBrowserSettings.value("selectedBrowserV1", "system")'));
assert(probe.includes('malvinaBrowserSettings.setValue("selectedBrowserV1", browserId)'));
assert(probe.includes('malvinaBrowserSettings.sync()'));
assert(probe.includes("malvinaBrowserBackend: soledadInputMask"));
assert(probe.includes("malvinaBrowserChoices: soledadInputMask.availableBrowsers()"));
assert(probe.includes("malvinaBrowserId: probe.testBrowserId"));

assert(page.includes('textRole: "name"') && page.includes('valueRole: "id"'));
assert(page.includes('enabled: panel.settingsTarget.malvinaBrowserChoices.length > 1'));
assert(page.includes("panel.settingsTarget.malvinaBrowserId ="));
assert(page.includes("panel.settingsTarget.malvinaBrowserChoices[index].id"));
assert(page.includes("Predeterminado del sistema (KDE)"));
assert(!page.includes("model: [\"Predeterminado del sistema (KDE)\"]"),
       "El ComboBox ya no debe ser ficticio en el ensayo nativo");
assert(settings.includes('"malvinaBrowserId"') &&
       settings.includes('signal saveMalvinaBrowserRequested(string browserId)') &&
       settings.includes("saveMalvinaBrowserRequested(malvinaBrowserId)"));
assert(shared.includes('signal requestMalvinaBrowserChange(string browserId)') &&
       shared.includes("onSaveMalvinaBrowserRequested: function(browserId)") &&
       shared.includes("root.requestMalvinaBrowserChange(browserId)"));
assert(search.includes("signal requestOpenUrl(string url)") &&
       search.includes("requestOpenUrl(result.url)") &&
       !search.includes("Qt.openUrlExternally(result.url)"));
assert(shared.includes("onRequestOpenUrl: function(url)") &&
       shared.includes("root.malvinaBrowserBackend.launchWebUrl(choice, url)") &&
       shared.includes("Qt.openUrlExternally(url)"),
       "La misma apertura del anfitrión debe servir Web e IA");

function qmlHandler(source, name) {
    const start = source.indexOf("on" + name + ": function(");
    assert(start >= 0, "Falta handler QML "+name);
    const b = source.indexOf("{", start);
    let depth=0;
    for(let i=b; i<source.length; ++i) {
        if(source[i]==="{") ++depth;
        else if(source[i]==="}" && --depth===0) return source.slice(b+1,i);
    }
    throw new Error("Handler incompleto "+name);
}
const choices=[{id:"system",name:"Predeterminado del sistema (KDE)"},
               {id:"falkon",name:"Falkon"},{id:"brave",name:"Brave"}];
const data=new Map();
let synced=0;
const storage={setValue(k,v){data.set(k,v);},sync(){++synced;}};
const probeObject={testBrowserId:"system"};
const mockBridge={availableBrowsers(){return choices;}};
const apply=new Function("probe","soledadInputMask","malvinaBrowserSettings",
                         "browserId","console",
                         qmlHandler(probe,"RequestMalvinaBrowserChange"));
const logger={log(){},warn(){}};
apply(probeObject,mockBridge,storage,"falkon",logger);
assert.equal(probeObject.testBrowserId,"falkon");
assert.equal(data.get("selectedBrowserV1"),"falkon");
assert.equal(synced,1);
apply(probeObject,mockBridge,storage,"malicious-shell-command",logger);
assert.equal(data.get("selectedBrowserV1"),"falkon",
             "Rechazar browser ID no descubierto");
assert.equal(synced,1);
apply(probeObject,mockBridge,storage,"system",logger);
assert.equal(data.get("selectedBrowserV1"),"system");
assert.equal(synced,2,"Se puede restaurar KDE con Aplicar");

const launchCalls=[],defaultCalls=[],dismissCalls=[];
const sender = new Function("root","Qt","url","console",
                            qmlHandler(shared,"RequestOpenUrl"));
const simulatedRoot={
    malvinaBrowserChoices:choices, malvinaBrowserId:"brave",
    malvinaBrowserBackend:{launchWebUrl(id,url){launchCalls.push([id,url]);return true;}},
    dismissMalvinaAfterSearch(){dismissCalls.push("closed");}
};
const qt={openUrlExternally(url){defaultCalls.push(url);return true;}};
sender(simulatedRoot,qt,"https://www.google.com/search?q=cerveza",logger);
sender(simulatedRoot,qt,"https://chatgpt.com/?q=cerveza",logger);
assert.deepEqual(launchCalls.map(x=>x[0]),["brave","brave"],
                 "Web e IA usan el mismo navegador específico");
assert.equal(defaultCalls.length,0);
simulatedRoot.malvinaBrowserId="system";
sender(simulatedRoot,qt,"https://claude.ai/new?q=cerveza",logger);
assert.deepEqual(launchCalls[2],["system","https://claude.ai/new?q=cerveza"]);
simulatedRoot.malvinaBrowserBackend=null;
sender(simulatedRoot,qt,"https://duckduckgo.com/?q=cerveza",logger);
assert.equal(defaultCalls.length,1, "Visor sin puente conserva la apertura KDE");
assert.equal(dismissCalls.length,4, "Cerrar Malvina tras Web e IA, también con KDE");
simulatedRoot.malvinaBrowserBackend={launchWebUrl(){return false;}};
sender(simulatedRoot,qt,"https://duckduckgo.com/?q=fallo",logger);
assert.equal(dismissCalls.length,4, "Si falla abrir el navegador, conservar el buscador");
console.log("OK: navegador Web/IA único, persistente, permitido; cierre al iniciar correctamente.");
