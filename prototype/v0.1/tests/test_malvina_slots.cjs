// Pruebas de datos sin ejecutar KDE ni abrir navegadores.
// Node.js: node prototype/v0.1/tests/test_malvina_slots.cjs
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")
const ui = path.resolve(__dirname,"../package/contents/ui")
const policy = fs.readFileSync(path.join(ui,"MalvinaUrlPolicy.js"),"utf8")
    .replace(/^\\.pragma library\\s*$/m,"")
const state = {}
vm.createContext(state)
vm.runInContext(policy,state)
const content = fs.readFileSync(path.join(ui,"MalvinaSlots.js"),"utf8")
    .replace(/^\\.pragma library\\s*$/m,"")
    .replace(/^\\.import "MalvinaUrlPolicy.js" as UrlPolicy\\s*$/m,"")
state.UrlPolicy = {validHttpsUrl:state.validHttpsUrl}
vm.runInContext(content,state)
assert.deepEqual(Array.from(state.order("web","[]","google,duck,yahoo","duck,yahoo")),["google"])
assert.deepEqual(Array.from(state.order("ai","[]","chatgpt,gemini,claude","chatgpt,gemini")),["claude"])
let custom = "[]"
for(let i=1;i<=9;i++){
    let added = state.add("ai",custom,"Mi IA "+i,"https://example.com/"+i,"chatgpt,gemini")
    assert.equal(added.ok,true,"alta "+i)
    custom=added.value
}
assert.equal(state.add("ai",custom,"No cabe","https://example.com/","chatgpt,gemini").ok,false)
let list = Array.from(state.order("ai",custom,"claude,chatgpt,gemini","chatgpt,gemini"))
assert.equal(list.length,10)
assert.equal(list[0],"claude")
assert.equal(state.extras("ai",custom).length,9)
let first = state.extras("ai",custom)[0]
custom=state.remove("ai",custom,first.id)
assert.equal(state.extras("ai",custom).length,8)
let fresh=state.add("ai",custom,"Restaurada","https://example.com/","chatgpt,gemini")
assert.equal(fresh.ok,true)
assert.equal(state.add("web","[]","Inseguro","http://inseguro.com?q={query}","").ok,false)
assert.equal(state.add("web","[]","Sin plantilla","https://example.com/search","").ok,false)
assert.equal(state.add("web","[]","Buscador","https://example.com/search?q={query}","").ok,true)
assert.equal(state.extras("ai",JSON.stringify([{id:"ai-1",name:"mal",url:"javascript:alert(1)",enabled:true}])).length,0)
console.log("MalvinaSlots: lógica aislada OK")
