// Proveedores añadidos por el usuario. Independiente de QML y de la navegación.
// Hasta diez proveedores VISIBLES por categoría, incluyendo opciones personalizadas.
.pragma library
.import "MalvinaUrlPolicy.js" as UrlPolicy
function canonical(section) {
    return section === "web" ? ["google","duck","yahoo"] : ["chatgpt","gemini","claude"]
}
function extras(section, serialized) {
    let list
    try { list = JSON.parse(String(serialized || "[]")) } catch(e) { return [] }
    if (!Array.isArray(list)) return []
    const result = [], used = {}
    // Expresión invariable por categoría: compilar una vez por lista.
    const validId = new RegExp("^"+section+"-(?:[1-9]|10)$")
    for (let i=0;i<list.length && result.length<10;i++) {
        const item = list[i]
        if (!item || typeof item !== "object") continue
        const id = String(item.id || "")
        if (!validId.test(id) || used[id]) continue
        const name = String(item.name || "").trim()
        const url = String(item.url || "").trim()
        if (!name || name.length > 48 || url.length > 2048 ||
            !UrlPolicy.validHttpsUrl(url) || (section === "web" && url.indexOf("{query}") < 0)) continue
        used[id] = true
        result.push({id:id,name:name,url:url,enabled:item.enabled === true})
    }
    return result
}
function ids(section, serialized) {
    return canonical(section).concat(extras(section,serialized).map(x=>x.id))
}
function order(section, serializedExtras, preferred, hidden) {
    const excluded = String(hidden || "").split(",")
    const available = ids(section,serializedExtras).filter(x=>excluded.indexOf(x)<0)
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
function add(section, serialized, name, url, hidden) {
    const current = extras(section,serialized)
    if (current.length + canonical(section).filter(x => String(hidden || "").split(",").indexOf(x) < 0).length >= 10)
        return {ok:false,reason:"Máximo de 10 opciones visibles"}
    const label=String(name || "").trim(), address=String(url || "").trim()
    if (!label || label.length>48 || address.length>2048 ||
        !UrlPolicy.validHttpsUrl(address) || (section === "web" && address.indexOf("{query}") < 0))
        return {ok:false,reason:"Nombre o URL HTTPS no válidos"}
    let id
    for(let n=1;n<=10;n++) if(!current.some(x=>x.id===section+"-"+n)){id=section+"-"+n;break}
    current.push({id:id,name:label,url:address,enabled:true})
    return {ok:true,value:JSON.stringify(current),id:id}
}
function update(section,serialized,id,name,url,enabled) {
    const current=extras(section,serialized)
    const found=current.findIndex(x=>x.id===id)
    if(found<0) return {ok:false,reason:"Opción inexistente"}
    const label=String(name||"").trim(), address=String(url||"").trim()
    if(!label || label.length>48 || address.length>2048 ||
       !UrlPolicy.validHttpsUrl(address) || (section === "web" && address.indexOf("{query}") < 0))
        return {ok:false,reason:"Nombre o URL HTTPS no válidos"}
    current[found]={id:id,name:label,url:address,enabled:!!enabled}
    return {ok:true,value:JSON.stringify(current)}
}
function remove(section,serialized,id) {
    return JSON.stringify(extras(section,serialized).filter(x=>x.id!==id))
}
