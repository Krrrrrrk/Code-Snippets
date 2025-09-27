/* PS_RandomizeFonts.jsx — Photoshop (experimental)
   Random font per character on the active text layer using style ranges.
*/

#target photoshop
app.bringToFront();

if (!app.documents.length || app.activeDocument.activeLayer.kind !== LayerKind.TEXT) {
  alert("Select a text layer first."); throw new Error();
}

// --- SETTINGS ---
var FONT_WHITELIST = [
  // Use PostScript names, e.g. "ArialMT", "TimesNewRomanPSMT", "Futura-Medium"
  "ArialMT", "TimesNewRomanPSMT", "CourierNewPSMT", "Georgia", "Impact"
];
var SKIP_NON_LETTERS = false;
// ---------------

function rand(arr){ return arr[Math.floor(Math.random()*arr.length)]; }

var lyr = app.activeDocument.activeLayer;
var ti  = lyr.textItem;
var txt = ti.contents;

if (!txt || !txt.length) { alert("Empty text."); throw new Error(); }

var baseRanges = ti.textStyleRanges;
if (!baseRanges.length) { alert("No style range found."); throw new Error(); }
var baseStyle = baseRanges[0].textStyle;

var ranges = [];
for (var i = 0; i < txt.length; i++) {
  var ch = txt.charAt(i);
  if (/\r/.test(ch)) { // keep line breaks intact
    var rBreak = new TextStyleRange();
    rBreak.from = i; rBreak.to = i+1;
    rBreak.textStyle = baseStyle.duplicate();
    ranges.push(rBreak);
    continue;
  }
  if (SKIP_NON_LETTERS && !/[A-Za-z0-9]/.test(ch)) {
    var rKeep = new TextStyleRange();
    rKeep.from = i; rKeep.to = i+1;
    rKeep.textStyle = baseStyle.duplicate();
    ranges.push(rKeep);
    continue;
  }
  var r = new TextStyleRange();
  r.from = i; r.to = i+1;
  var ts = baseStyle.duplicate();
  try { ts.font = rand(FONT_WHITELIST); } catch(e) {}
  r.textStyle = ts;
  ranges.push(r);
}

ti.textStyleRanges = ranges;
alert("Done!");
