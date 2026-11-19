// Extracción local de hasta tres colores dominantes de un fotograma.
// Sin red, sin efectos colaterales y sin utilizar la paleta del contorno.
// Entrada: píxeles RGBA de Canvas.getImageData(), 64x64 recomendado.
// Se agrupan los píxeles visibles por tono y luminosidad y se ofrece una
// muestra RGB promedio real por grupo, ordenada por frecuencia aproximada.
function extractDominantColors(rgba, targetCount) {
    var count = Math.max(1, Math.min(3, targetCount || 3));
    var bins = [];
    var visible = 0;
    for (var i = 0; i < rgba.length; i += 4) {
        if (rgba[i + 3] < 128) continue;
        var r = rgba[i] / 255, g = rgba[i + 1] / 255,
            b = rgba[i + 2] / 255;
        var high = Math.max(r, g, b), low = Math.min(r, g, b);
        var chroma = high - low;
        // Ignorar sombras prácticamente negras y reflejos sin información
        // cromática; los tonos oscuros saturados del mar sí se conservan.
        if (high < 0.065 || chroma < 0.028 ||
            chroma / Math.max(high, 0.001) < 0.10) continue;
        var hue = high === r ? (g - b) / chroma
                : high === g ? 2 + (b - r) / chroma
                : 4 + (r - g) / chroma;
        hue = ((hue / 6) % 1 + 1) % 1;
        var hueBin = Math.min(23, Math.floor(hue * 24));
        var lightBin = high < 0.26 ? 0 : (high < 0.58 ? 1 : 2);
        var id = hueBin * 3 + lightBin;
        if (!bins[id]) bins[id] = {n: 0, r: 0, g: 0, b: 0};
        bins[id].n++;
        bins[id].r += rgba[i];
        bins[id].g += rgba[i + 1];
        bins[id].b += rgba[i + 2];
        visible++;
    }
    function hexPart(x) {
        var s = Math.max(0, Math.min(255, Math.round(x))).toString(16);
        return s.length === 1 ? "0" + s : s;
    }
    var groups = [];
    for (var j = 0; j < bins.length; j++) {
        var bin = bins[j];
        if (!bin || !bin.n) continue;
        groups.push({
            n: bin.n, r: bin.r / bin.n, g: bin.g / bin.n,
            b: bin.b / bin.n
        });
    }
    groups.sort(function(a, b) { return b.n - a.n; });
    var chosen = [];
    // Evitar tres variantes casi idénticas, pero permitir tonos claros y
    // oscuros de un mismo azul si son realmente distintos en el GIF.
    for (var thresholdIndex = 0; thresholdIndex < 3 &&
         chosen.length < count; thresholdIndex++) {
        var threshold = [58, 33, 0][thresholdIndex];
        for (var k = 0; k < groups.length && chosen.length < count; k++) {
            var candidate = groups[k];
            if (chosen.indexOf(candidate) !== -1) continue;
            var sufficientlyDifferent = true;
            for (var z = 0; z < chosen.length; z++) {
                var current = chosen[z];
                var distance = Math.sqrt(
                    Math.pow(candidate.r - current.r, 2) +
                    Math.pow(candidate.g - current.g, 2) +
                    Math.pow(candidate.b - current.b, 2));
                if (distance < threshold) { sufficientlyDifferent = false; break; }
            }
            if (sufficientlyDifferent) chosen.push(candidate);
        }
    }
    var output = [];
    for (var k = 0; k < chosen.length; k++) {
        var item = chosen[k];
        output.push({
            hex: "#" + hexPart(item.r) + hexPart(item.g) + hexPart(item.b),
            pixels: item.n,
            percent: visible ? Math.round(item.n * 100 / visible) : 0
        });
    }
    return output;
}
