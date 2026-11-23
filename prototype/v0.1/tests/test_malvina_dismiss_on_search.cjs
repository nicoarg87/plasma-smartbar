// Contrato: tras Enter de búsqueda Web/IA, contraer y ocultar Malvina.
// Sin red, sin arrancar navegadores y sin modificar preferencias KDE.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const shared = fs.readFileSync(path.join(base,"package/contents/ui/SmartBarContent.qml"),"utf8");
const search = fs.readFileSync(path.join(base,"package/contents/ui/MalvinaSearch.qml"),"utf8");
const probe = fs.readFileSync(path.join(base,"preview_malvina_input_mask.qml"),"utf8");

function braces(source,start) {
    let depth=0;
    for(let i=start;i<source.length;i++) {
        if(source[i]==="{") ++depth;
        else if(source[i]==="}" && --depth===0) return source.slice(start+1,i);
    }
    throw new Error("Bloque QML incompleto");
}
function functionBody(source,name) {
    const pos=source.indexOf("function "+name+"(");
    assert(pos>=0,"Falta función "+name);
    return braces(source,source.indexOf("{",pos));
}
function timerBody(source,id) {
    const pos=source.indexOf("id: "+id);
    assert(pos>=0,"Falta timer "+id);
    const on=source.indexOf("onTriggered: {",pos);
    return braces(source,source.indexOf("{",on));
}

const dismissBody = functionBody(shared,"dismissMalvinaAfterSearch");
assert(dismissBody.includes("malvinaSearch.closeSearch()"));
assert(dismissBody.includes("malvinaDismissedAfterSearch = true"));
assert(dismissBody.includes("malvinaRevealTimer.stop()"));
assert(dismissBody.includes("malvinaHideTimer.stop()"));
assert(dismissBody.includes("malvinaDismissRearmed = !malvinaHotspotHover.hovered"));
assert(shared.includes("!malvinaDismissedAfterSearch &&"),
       "La visibilidad debe respetar el cierre puntual");
assert(shared.includes("root.malvinaDismissedAfterSearch = false") &&
       shared.includes("root.malvinaDismissRearmed = false"),
       "Recuperación debe rearmarse tras hover o apertura explícita");
assert(shared.includes("root.dismissMalvinaAfterSearch()"));
assert(shared.includes("if (accepted) {"),
       "Solo cerrar si el sistema aceptó iniciar el navegador");
assert(shared.includes('onExpandedChanged: {'),
       "Reabrir explícitamente debe recuperar Malvina");
assert(search.includes("requestOpenUrl(result.url)"));
assert(search.includes('Keyboard.enterAction(navigationSection) === "confirm"'));
assert(probe.includes("autoHideMalvina: false"),
       "El ensayo sigue sin alterar preferencias del usuario");

let closed=0, stopped=0;
const state = {
    malvinaHoverRevealed: true,
    malvinaDismissRearmed: false,
    malvinaDismissedAfterSearch: false
};
const pointer={hovered:true};
const timers={stop(){stopped++;}};
const dismiss = new Function("root","malvinaSearch","malvinaRevealTimer",
    "malvinaHideTimer","malvinaHotspotHover",
    "with(root) {"+dismissBody+"}");
dismiss(state,{closeSearch(){closed++;}},timers,timers,pointer);
assert.equal(closed,1,"Cerrar campo y opciones exactamente una vez");
assert.equal(stopped,2);
assert.equal(state.malvinaDismissedAfterSearch,true);
assert.equal(state.malvinaDismissRearmed,false,
             "El cursor sobre Malvina no debe reabrirla inmediatamente");

const revealBody = timerBody(shared,"malvinaRevealTimer");
const reveal = new Function("root","malvinaHotspotHover",revealBody);
Object.assign(state,{autoRevealBlocked:false,launcherIslandVisible:true,autoHideMalvina:false});
reveal(state,pointer);
assert.equal(state.malvinaDismissedAfterSearch,true,"No reaparecer sin salir y entrar");
state.malvinaDismissRearmed=true;
reveal(state,pointer);
assert.equal(state.malvinaDismissedAfterSearch,false,
             "Un hover nuevo recupera Malvina aunque el ensayo fuerce visible");
assert.equal(state.malvinaDismissRearmed,false);
assert.equal(state.malvinaHoverRevealed,false,
             "No alterar preferencia de autoocultamiento");

pointer.hovered=false;
dismiss(state,{closeSearch(){closed++;}},timers,timers,pointer);
assert.equal(state.malvinaDismissRearmed,true,
             "Si cursor está fuera, la próxima entrada puede recuperarla");
pointer.hovered=true;
reveal(state,pointer);
assert.equal(state.malvinaDismissedAfterSearch,false);
console.log("OK: Enter de Web/IA oculta Malvina y recupera por hover, sin cambiar preferencias.");
