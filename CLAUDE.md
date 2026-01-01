# EigenLab Generative - Contexto para Claude Code

## Descripcion

Plugins generativos para MuseScore 4. A diferencia de `eigenlab-instruments` (plugins de audio VST3/AU en C++/JUCE), estos plugins generan **notas en la partitura** usando la API de plugins de MuseScore (QML/JavaScript).

## Stack Tecnologico

| Componente | Tecnologia |
|------------|-----------|
| Framework UI | QML (Qt Modeling Language) |
| Logica | JavaScript ES7 |
| Target | MuseScore 4.4+ |
| API | MuseScore Plugin API |

## Estructura del Proyecto

```
eigenlab-generative/
├── plugins/
│   └── RameauGenerator/
│       ├── RameauGenerator.qml      # Plugin principal (entry point)
│       ├── MarkovEngine.js          # Motor de cadenas de Markov
│       ├── VoiceLeading.js          # Reglas SATB
│       ├── Chords.js                # Definiciones de acordes y funciones
│       └── manifest.json            # Metadatos
├── README.md
└── CLAUDE.md
```

## API de MuseScore - Operaciones Clave

### Crear notas

```javascript
var cursor = curScore.newCursor();
cursor.track = 0;  // Voz/pentagrama
cursor.rewind(1);  // Ir a seleccion
cursor.setDuration(1, 4);  // Negra

curScore.startCmd();
cursor.addNote(60);        // C4
cursor.addNote(64, true);  // E4 (añade al acorde existente)
curScore.endCmd();
```

### Iterar partitura

```javascript
for (var seg = curScore.firstSegment(); seg; seg = seg.next) {
    var elem = seg.elementAt(track);
    if (elem && elem.type == Element.CHORD) {
        // Procesar
    }
}
```

### Estructura QML del plugin

```qml
import MuseScore 3.0
import QtQuick 2.9
import QtQuick.Controls 2.2

MuseScore {
    title: "Rameau Generator"
    description: "Genera progresiones armonicas SATB"
    version: "0.1"
    pluginType: "dialog"
    categoryCode: "composing-arranging-tools"
    thumbnailName: "rameau_thumb.png"

    width: 400
    height: 300

    onRun: {
        // Inicializacion
    }

    // UI components...

    function generate() {
        curScore.startCmd();
        // Generar notas...
        curScore.endCmd();
    }
}
```

## Motor de Markov (de Rameau Machine)

### Acordes (grados relativos)

```javascript
const CHORDS = {
    'I':    { function: 'T', tension: 0.0, root: 0, third: 4, fifth: 7 },
    'ii':   { function: 'S', tension: 0.5, root: 2, third: 5, fifth: 9 },
    'iii':  { function: 'T', tension: 0.3, root: 4, third: 7, fifth: 11 },
    'IV':   { function: 'S', tension: 0.4, root: 5, third: 9, fifth: 0 },
    'V':    { function: 'D', tension: 0.8, root: 7, third: 11, fifth: 2 },
    'vi':   { function: 'T', tension: 0.2, root: 9, third: 0, fifth: 4 },
    'viio': { function: 'D', tension: 0.85, root: 11, third: 2, fifth: 5 }
};
```

### Matriz de transicion

```javascript
const TRANSITIONS = {
    'I':    { 'I': 0.05, 'ii': 0.15, 'iii': 0.05, 'IV': 0.25, 'V': 0.30, 'vi': 0.15, 'viio': 0.05 },
    'ii':   { 'I': 0.05, 'ii': 0.05, 'iii': 0.02, 'IV': 0.08, 'V': 0.60, 'vi': 0.05, 'viio': 0.15 },
    'iii':  { 'I': 0.10, 'ii': 0.05, 'iii': 0.02, 'IV': 0.30, 'V': 0.10, 'vi': 0.40, 'viio': 0.03 },
    'IV':   { 'I': 0.15, 'ii': 0.10, 'iii': 0.02, 'IV': 0.05, 'V': 0.50, 'vi': 0.05, 'viio': 0.13 },
    'V':    { 'I': 0.70, 'ii': 0.02, 'iii': 0.02, 'IV': 0.05, 'V': 0.05, 'vi': 0.14, 'viio': 0.02 },
    'vi':   { 'I': 0.10, 'ii': 0.25, 'iii': 0.05, 'IV': 0.30, 'V': 0.20, 'vi': 0.05, 'viio': 0.05 },
    'viio': { 'I': 0.80, 'ii': 0.02, 'iii': 0.05, 'IV': 0.02, 'V': 0.03, 'vi': 0.05, 'viio': 0.03 }
};
```

### Seleccion de siguiente acorde

```javascript
function selectNextChord(current, gravity = 0.5) {
    const probs = getModifiedProbabilities(current, gravity);
    const rand = Math.random();
    let cumulative = 0;

    for (const [chord, prob] of Object.entries(probs)) {
        cumulative += prob;
        if (rand < cumulative) return chord;
    }
    return 'I';  // Fallback
}
```

## Voice Leading SATB

### Rangos vocales (MIDI)

```javascript
const VOICE_RANGES = {
    bass:    { min: 36, max: 60 },   // C2 - C4
    tenor:   { min: 48, max: 67 },   // C3 - G4
    alto:    { min: 55, max: 74 },   // G3 - D5
    soprano: { min: 60, max: 81 }    // C4 - A5
};
```

### Reglas de voice leading

1. **Evitar paralelas**: No quintas ni octavas paralelas
2. **Evitar cruces**: bass < tenor <= alto <= soprano
3. **Resolver sensible**: Grado 7 → Grado 1 (en estilo barroco/clasico)
4. **Minimizar movimiento**: Preferir grados conjuntos

### Algoritmo de voicing optimo

```javascript
function findOptimalVoicing(pitchClasses, bassNote, prevVoicing) {
    const candidates = generateAllVoicings(pitchClasses, bassNote);
    const valid = candidates.filter(v => isValidVoiceLeading(prevVoicing, v));

    return valid.reduce((best, candidate) => {
        const cost = totalVoiceDistance(prevVoicing, candidate);
        return cost < best.cost ? { voicing: candidate, cost } : best;
    }, { voicing: null, cost: Infinity }).voicing;
}
```

## Limitaciones de MuseScore Plugin API

- No puede crear acordes que cruzan compases
- No puede crear ligaduras (ties) programaticamente
- MuseScore 4.4 requiere Qt 6 (cambios vs MS3)
- Documentacion oficial escasa

## Convenciones de Codigo

| Aspecto | Convencion |
|---------|-----------|
| Variables | camelCase |
| Constantes | UPPER_SNAKE_CASE |
| Funciones | camelCase |
| Archivos JS | PascalCase.js |
| Archivos QML | PascalCase.qml |
| Idioma codigo | Ingles |
| Idioma UI | Espanol |

## Referencias

- [MuseScore Plugin API](https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/)
- [Plugins for 4.x](https://musescore.org/en/node/337468)
- [Porting 3.x to 4](https://musescore.org/en/node/337463)
- [musescore-theory-plugins](https://github.com/jwmatthys/musescore-theory-plugins) - Referencia de contrapunto/SATB
- [Rameau Machine](../EigenLab/Physics/Physics%20Sound%20Lab/generativos/rameau-machine/) - Origen del motor

## Comandos Utiles

```bash
# Copiar plugin a MuseScore
cp -r plugins/RameauGenerator ~/Documents/MuseScore4/Plugins/

# Ver logs de MuseScore (debug)
tail -f ~/Library/Logs/MuseScore/MuseScore4.log
```
