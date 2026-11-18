// Proveedores añadidos por el usuario. Independiente de QML y de la navegación.
// Tres proveedores originales + hasta siete adicionales por categoría.
.pragma library
function canonical(section) {
    return section === "web" ? ["google","duck","yahoo"] : ["chatgpt","gemini","claude"]
}
function extras(section, serialized) {
    let list
    try { list = JSON.parse(String(serialized || "[]")) } catch(e) { return [] }
    if (!Array.isArray(list)) return []
    const result = [], used = {}
    for (let i=0;i<list.length && result.length<7;i++) {
        const item = list[i]
        if (!item || typeof item !== "object") continue
        const id = String(item.id || "")
        if (!new RegExp("^"+section+"-[4-9]$|^"+section+"-10$").test(id) || used[id]) continue
        const name = String(item.name || "").trim()
        const url = String(item.url || "").trim()
        if (!name || name.length > 48 || !url || url.length > 2048) continue
        used[id] = true
        result.push({id:id,name:name,url:url,enabled:item.enabled === true})
    }
    return result
}
function ids(section, serialized) {
    return canonical(section).concat(extras(section,serialized).map(x=>x.id))
}
function order(section, serializedExtras, preferred) {
    const available = ids(section,serializedExtras)
    const requested = String(preferred || "").split(",")
    const ordered=[]
    for (let i=0;i<requested.length;i++) {
        const id=requested[i]
        if (available.indexOf(id)>=0 && ordered.indexOf(id)<0) ordered.push(id)
    }
    for (let i=0;i<available.length;i++)
        if (ordered.indexOf(available[i])<0) ordered.push(available[i])
    return ordered
}
function add(section, serialized, name, url) {
    const current = extras(section,serialized)
    if (current.length >= 7) return {ok:false,reason:"Máximo de 10 opciones"}
    const label=String(name || "").trim(), address=String(url || "").trim()
    if (!label || label.length>48 || !address || address.length>2048)
        return {ok:false,reason:"Nombre o URL no válidos"}
    let id
    for(let n=4;n<=10;n++) if(!current.some(x=>x.id===section+"-"+n)){id=section+"-"+n;break}
    current.push({id:id,name:label,url:address,enabled:true})
    return {ok:true,value:JSON.stringify(current),id:id}
}
function update(section,serialized,id,name,url,enabled) {
    const current=extras(section,serialized)
    const found=current.findIndex(x=>x.id===id)
    if(found<0) return {ok:false,reason:"Opción inexistente"}
    const label=String(name||"").trim(), address=String(url||"").trim()
    if(!label || label.length>48 || !address || address.length>2048)
        return {ok:false,reason:"Nombre o URL no válidos"}
    current[found]={id:id,name:label,url:address,enabled:!!enabled}
    return {ok:true,value:JSON.stringify(current)}
}
function remove(section,serialized,id) {
    return JSON.stringify(extras(section,serialized).filter(x=>x.id!==id))
}
