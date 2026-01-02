/**
 * RameauJazz.qml - Generador de progresiones jazz para piano
 *
 * Genera progresiones con acordes de 7a, 9a y voicings de jazz.
 * Basado en cadenas ii-V-I y sustituciones armonicas.
 *
 * v0.1: Acordes de 7a, shell voicings, ii-V-I
 * v0.2: Walking bass opcional
 * v0.3: Blue Note style (double chromatic, enclosures, corcheas swing)
 * v0.4: Tresillos swing + Comping RH (Charleston, Anticipation, etc.)
 * v0.5: Dominantes secundarios (V7/ii, V7/V), acordes de paso dim7
 * v0.6: Presets de estilo (Bebop, Bossa Nova, Modal, Ballad)
 *
 * Basado en el motor de Markov de RameauGenerator.
 */

import MuseScore 3.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

MuseScore {
    id: plugin
    title: "Rameau Jazz"
    description: "Genera progresiones jazz con acordes de 7a y voicings"
    version: "0.6.0"
    pluginType: "dialog"

    width: 400
    height: 700

    // ========== CONSTANTES PIANO ==========

    property var leftHandRange:  ({ min: 36, max: 60 })   // C2 - C4
    property var rightHandRange: ({ min: 48, max: 84 })   // C3 - C6

    // ========== TIPOS DE ACORDES JAZZ ==========

    // Intervalos desde la fundamental (en semitonos)
    property var chordTypes: ({
        'maj7':   { intervals: [0, 4, 7, 11], symbol: 'maj7', color: '#70ff70' },
        'maj9':   { intervals: [0, 4, 7, 11, 14], symbol: 'maj9', color: '#70ff70' },
        '6':      { intervals: [0, 4, 7, 9], symbol: '6', color: '#70ff70' },
        'm7':     { intervals: [0, 3, 7, 10], symbol: 'm7', color: '#7070ff' },
        'm9':     { intervals: [0, 3, 7, 10, 14], symbol: 'm9', color: '#7070ff' },
        'm6':     { intervals: [0, 3, 7, 9], symbol: 'm6', color: '#7070ff' },
        '7':      { intervals: [0, 4, 7, 10], symbol: '7', color: '#ffff70' },
        '9':      { intervals: [0, 4, 7, 10, 14], symbol: '9', color: '#ffff70' },
        '13':     { intervals: [0, 4, 7, 10, 14, 21], symbol: '13', color: '#ffff70' },
        '7alt':   { intervals: [0, 4, 8, 10, 13], symbol: '7alt', color: '#ff7070' },
        '7b9':    { intervals: [0, 4, 7, 10, 13], symbol: '7b9', color: '#ff7070' },
        '7#9':    { intervals: [0, 4, 7, 10, 15], symbol: '7#9', color: '#ff7070' },
        'm7b5':   { intervals: [0, 3, 6, 10], symbol: 'm7b5', color: '#ff70ff' },
        'dim7':   { intervals: [0, 3, 6, 9], symbol: 'dim7', color: '#ff70ff' }
    })

    // ========== GRADOS JAZZ (basados en ii-V-I) ==========

    // Cada grado tiene: tipo de acorde por defecto, tension, funcion
    property var jazzDegrees: ({
        // Acordes diatonicos
        'Imaj7':   { type: 'maj7', root: 0, func: 'T', tension: 0.0 },
        'Imaj9':   { type: 'maj9', root: 0, func: 'T', tension: 0.0 },
        'I6':      { type: '6', root: 0, func: 'T', tension: 0.0 },
        'IIm7':    { type: 'm7', root: 2, func: 'SD', tension: 0.3 },
        'IIm9':    { type: 'm9', root: 2, func: 'SD', tension: 0.3 },
        'IIIm7':   { type: 'm7', root: 4, func: 'T', tension: 0.2 },
        'IVmaj7':  { type: 'maj7', root: 5, func: 'SD', tension: 0.4 },
        'IVmaj9':  { type: 'maj9', root: 5, func: 'SD', tension: 0.4 },
        'V7':      { type: '7', root: 7, func: 'D', tension: 0.8 },
        'V9':      { type: '9', root: 7, func: 'D', tension: 0.8 },
        'V13':     { type: '13', root: 7, func: 'D', tension: 0.8 },
        'V7alt':   { type: '7alt', root: 7, func: 'D', tension: 0.9 },
        'VIm7':    { type: 'm7', root: 9, func: 'T', tension: 0.2 },
        'VIIm7b5': { type: 'm7b5', root: 11, func: 'D', tension: 0.7 },

        // Sustitutos tritono
        'bII7':    { type: '7', root: 1, func: 'D', tension: 0.85 },
        'bVII7':   { type: '7', root: 10, func: 'SD', tension: 0.5 },
        '#IVm7b5': { type: 'm7b5', root: 6, func: 'SD', tension: 0.6 },

        // v0.5: DOMINANTES SECUNDARIOS
        'V7/ii':   { type: '7', root: 9, func: 'secD', tension: 0.7 },   // A7 en C → Dm
        'V7/V':    { type: '7', root: 2, func: 'secD', tension: 0.7 },   // D7 en C → G
        'V7/IV':   { type: '7', root: 0, func: 'secD', tension: 0.6 },   // C7 en C → F
        'V7/vi':   { type: '7', root: 4, func: 'secD', tension: 0.7 },   // E7 en C → Am

        // v0.5: ii-V SECUNDARIOS (related ii)
        'iiø/ii':  { type: 'm7b5', root: 4, func: 'secSD', tension: 0.5 },  // Em7b5 → A7 → Dm
        'iiø/V':   { type: 'm7b5', root: 9, func: 'secSD', tension: 0.5 },  // Am7b5 → D7 → G

        // v0.5: ACORDES DIMINUIDOS DE PASO
        '#Idim7':  { type: 'dim7', root: 1, func: 'pass', tension: 0.6 },   // C#dim7: I → ii
        '#IVdim7': { type: 'dim7', root: 6, func: 'pass', tension: 0.6 },   // F#dim7: IV → V
        'bIIIdim7':{ type: 'dim7', root: 3, func: 'pass', tension: 0.6 }    // Ebdim7: iii → ii
    })

    // ========== MATRIZ DE TRANSICION JAZZ ==========

    // Centrada en ii-V-I con sustituciones y dominantes secundarios
    property var jazzTransitions: ({
        // Acordes diatonicos
        'Imaj7':   { 'Imaj7': 0.03, 'IIm7': 0.15, 'IIIm7': 0.05, 'IVmaj7': 0.15, 'V7': 0.08, 'VIm7': 0.15,
                     'V7/ii': 0.12, '#Idim7': 0.10, 'V7/vi': 0.08, 'iiø/ii': 0.05, 'V7/IV': 0.04 },
        'IIm7':    { 'Imaj7': 0.03, 'V7': 0.55, 'bII7': 0.15, 'V7/V': 0.10, '#IVdim7': 0.07, 'VIIm7b5': 0.05, 'IVmaj7': 0.05 },
        'IIIm7':   { 'IIm7': 0.10, 'IVmaj7': 0.15, 'VIm7': 0.45, 'bIIIdim7': 0.15, 'V7/vi': 0.10, 'VIIm7b5': 0.05 },
        'IVmaj7':  { 'Imaj7': 0.10, 'IIm7': 0.15, 'IIIm7': 0.08, 'V7': 0.30, '#IVdim7': 0.15, 'VIm7': 0.07, '#IVm7b5': 0.05, 'V7/V': 0.10 },
        'V7':      { 'Imaj7': 0.55, 'VIm7': 0.20, 'IIm7': 0.05, 'IVmaj7': 0.05, 'bVII7': 0.05, 'V7/ii': 0.05, 'IIIm7': 0.05 },
        'VIm7':    { 'Imaj7': 0.08, 'IIm7': 0.30, 'IVmaj7': 0.15, 'V7': 0.15, 'V7/ii': 0.15, 'iiø/ii': 0.10, 'VIIm7b5': 0.07 },
        'VIIm7b5': { 'IIIm7': 0.50, 'V7': 0.15, 'Imaj7': 0.10, 'IIm7': 0.10, 'IVmaj7': 0.10, 'VIm7': 0.05 },

        // Sustitutos tritono
        'bII7':    { 'Imaj7': 0.80, 'VIm7': 0.10, 'IIm7': 0.05, 'IVmaj7': 0.05 },
        'bVII7':   { 'Imaj7': 0.25, 'IVmaj7': 0.40, 'VIm7': 0.25, 'IIm7': 0.10 },
        '#IVm7b5': { 'IVmaj7': 0.40, 'V7': 0.40, 'Imaj7': 0.10, '#IVdim7': 0.10 },

        // v0.5: DOMINANTES SECUNDARIOS - resuelven a su target
        'V7/ii':   { 'IIm7': 0.75, 'bII7': 0.10, 'V7': 0.10, 'Imaj7': 0.05 },   // A7 → Dm
        'V7/V':    { 'V7': 0.75, 'IIm7': 0.10, 'bII7': 0.10, 'Imaj7': 0.05 },   // D7 → G7
        'V7/IV':   { 'IVmaj7': 0.75, 'IIm7': 0.10, 'Imaj7': 0.10, 'V7': 0.05 }, // C7 → F
        'V7/vi':   { 'VIm7': 0.75, 'IIm7': 0.10, 'IVmaj7': 0.10, 'V7': 0.05 },  // E7 → Am

        // v0.5: ii RELACIONADOS - preceden al dominante secundario
        'iiø/ii':  { 'V7/ii': 0.80, 'IIm7': 0.10, 'V7': 0.05, 'Imaj7': 0.05 },  // Em7b5 → A7
        'iiø/V':   { 'V7/V': 0.80, 'V7': 0.10, 'IIm7': 0.05, 'Imaj7': 0.05 },   // Am7b5 → D7

        // v0.5: DIMINUIDOS DE PASO - conectan cromaticamente
        '#Idim7':  { 'IIm7': 0.85, 'V7/ii': 0.10, 'Imaj7': 0.05 },   // C#dim → Dm
        '#IVdim7': { 'V7': 0.85, 'IIm7': 0.10, 'Imaj7': 0.05 },      // F#dim → G7
        'bIIIdim7':{ 'IIm7': 0.85, 'IIIm7': 0.10, 'V7': 0.05 }       // Ebdim → Dm
    })

    // ========== ESTILOS DE VOICING ==========

    property var voicingStyles: ["Shell (1-3-7)", "Drop 2", "Rootless A", "Rootless B", "Block"]
    property int selectedVoicing: 0

    property var chordComplexity: ["7as", "9as", "Mixto"]
    property int selectedComplexity: 0  // 0=7as, 1=9as, 2=mixto

    // ========== WALKING BASS (v0.2) ==========

    property var bassStyles: ["Bloque (redonda)", "Walking (negras)"]
    property int selectedBassStyle: 0  // 0=bloque, 1=walking

    // Patrones walking bass - Blue Note style
    property var walkingPatterns: ["Blue Note (pro)", "Oleaje", "Escalar", "Cromatico"]
    property int selectedWalkingPattern: 0

    // Probabilidades de variacion (estilo Blue Note)
    property real probSwingTriplet: 0.25     // 25% añade tresillo swing
    property real probDoubleChromatic: 0.20  // 20% double chromatic approach
    property real probEnclosure: 0.15        // 15% enclosure (arriba-abajo-target)

    // Tipos de duracion para walking bass
    // "quarter" = negra (1/4)
    // "swing_long" = parte larga del tresillo (2/3 de negra)
    // "swing_short" = parte corta del tresillo (1/3 de negra)

    // ========== COMPING RH (v0.4) ==========

    property var compingStyles: ["Bloque (redonda)", "Charleston", "Reverse Charleston", "Anticipation", "Syncopated"]
    property int selectedCompingStyle: 0

    // Probabilidades de variacion en comping
    property real probCompingVariation: 0.30  // 30% varia el patron

    // ========== v0.6 PRESETS DE ESTILO ==========

    property var stylePresets: ["Standard", "Bebop", "Bossa Nova", "Modal", "Ballad"]
    property int selectedStylePreset: 0

    // Configuracion por preset (se aplica al generar)
    // Standard: configuracion por defecto
    // Bebop: rapido, alterados, muchas sustituciones
    // Bossa Nova: straight feel, maj9/m9, menos tension
    // Modal: menos cambios, acordes diatonicos
    // Ballad: lento, extensiones, voice leading suave

    function applyStylePreset() {
        if (selectedStylePreset === 0) {
            // STANDARD - configuracion por defecto
            probSwingTriplet = 0.25;
            probDoubleChromatic = 0.20;
            probEnclosure = 0.15;
            selectedComplexity = 0;  // 7as

        } else if (selectedStylePreset === 1) {
            // BEBOP - rapido, alterados, sustituciones
            probSwingTriplet = 0.40;       // Mas swing
            probDoubleChromatic = 0.35;    // Mas cromatismo
            probEnclosure = 0.25;          // Mas enclosures
            selectedComplexity = 2;        // Mixto (7as y 9as)
            // Preferir acordes alterados
            useAlteredDominants = true;

        } else if (selectedStylePreset === 2) {
            // BOSSA NOVA - straight, suave, maj9/m9
            probSwingTriplet = 0.0;        // Sin swing (straight feel)
            probDoubleChromatic = 0.10;    // Poco cromatismo
            probEnclosure = 0.05;          // Pocos enclosures
            selectedComplexity = 1;        // 9as (maj9, m9)
            // Comping mas sparse
            probCompingVariation = 0.50;

        } else if (selectedStylePreset === 3) {
            // MODAL - menos cambios, diatonico
            probSwingTriplet = 0.20;
            probDoubleChromatic = 0.05;    // Minimo cromatismo
            probEnclosure = 0.05;
            selectedComplexity = 0;        // 7as basicas
            // Menos sustituciones (se aplica en matriz)

        } else if (selectedStylePreset === 4) {
            // BALLAD - lento, extensiones, suave
            probSwingTriplet = 0.15;       // Poco swing
            probDoubleChromatic = 0.15;
            probEnclosure = 0.10;
            selectedComplexity = 1;        // 9as
            // Comping mas legato
            probCompingVariation = 0.20;
        }
    }

    property bool useAlteredDominants: false  // Para Bebop

    // ========== ESTADO ==========

    property string selectedKey: "C"
    property int numChords: 8
    property real gravityValue: 0.5
    property bool endWithCadence: true

    property string currentPosition: "Imaj7"
    property var generatedProgression: []
    property var currentVoices: [48, 52, 55, 59]

    property var keys: ["C", "F", "Bb", "Eb", "Ab", "Db", "G", "D", "A", "E"]

    property var keyPitches: ({
        'C': 0, 'C#': 1, 'Db': 1, 'D': 2, 'D#': 3, 'Eb': 3,
        'E': 4, 'F': 5, 'F#': 6, 'Gb': 6, 'G': 7, 'G#': 8,
        'Ab': 8, 'A': 9, 'A#': 10, 'Bb': 10, 'B': 11
    })

    property var noteNames: ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]

    // ========== FUNCIONES AUXILIARES ==========

    function degreeToChordName(degree, keyName) {
        var degreeInfo = jazzDegrees[degree];
        if (!degreeInfo) return degree;

        var keyPitch = keyPitches[keyName] || 0;
        var rootPitch = (degreeInfo.root + keyPitch) % 12;
        var rootName = noteNames[rootPitch];
        var chordType = chordTypes[degreeInfo.type];

        return rootName + chordType.symbol;
    }

    // ========== MOTOR DE MARKOV ==========

    function selectNextChord() {
        var probs = jazzTransitions[currentPosition];

        if (!probs) {
            currentPosition = "Imaj7";
            probs = jazzTransitions[currentPosition];
        }

        // Aplicar complejidad (convertir 7as a 9as si corresponde)
        var rand = Math.random();
        var cumulative = 0;

        var chordList = Object.keys(probs);
        for (var i = 0; i < chordList.length; i++) {
            var chord = chordList[i];
            cumulative += probs[chord];
            if (rand < cumulative) {
                return maybeUpgradeChord(chord);
            }
        }
        return "Imaj7";
    }

    function maybeUpgradeChord(chord) {
        if (selectedComplexity === 0 && !useAlteredDominants) return chord;  // Solo 7as

        var upgrades = {
            'Imaj7': 'Imaj9',
            'IIm7': 'IIm9',
            'IVmaj7': 'IVmaj9',
            'V7': selectedComplexity === 2 && Math.random() > 0.5 ? 'V13' : 'V9'
        };

        // BEBOP: usar acordes alterados en dominantes
        if (useAlteredDominants) {
            var dominantChords = ['V7', 'V7/ii', 'V7/V', 'V7/IV', 'V7/vi', 'bII7'];
            if (dominantChords.indexOf(chord) >= 0 && Math.random() > 0.5) {
                // 50% de usar V7alt en lugar del dominante
                if (chord === 'V7') return 'V7alt';
                // Para secundarios, mantener el 7 pero el voicing sera mas tenso
            }
        }

        if (selectedComplexity === 1 && upgrades[chord]) {
            return upgrades[chord];
        }

        if (selectedComplexity === 2 && upgrades[chord] && Math.random() > 0.5) {
            return upgrades[chord];
        }

        return chord;
    }

    function generateProgression() {
        var progression = [];
        currentPosition = "Imaj7";

        for (var i = 0; i < numChords; i++) {
            // Cadencia final ii-V-I
            if (endWithCadence && i === numChords - 3) {
                progression.push("IIm7");
                currentPosition = "IIm7";
                continue;
            }
            if (endWithCadence && i === numChords - 2) {
                var dominant = selectedComplexity > 0 ? "V9" : "V7";
                progression.push(dominant);
                currentPosition = dominant;
                continue;
            }
            if (endWithCadence && i === numChords - 1) {
                var tonic = selectedComplexity > 0 ? "Imaj9" : "Imaj7";
                progression.push(tonic);
                currentPosition = tonic;
                continue;
            }

            var nextChord = selectNextChord();
            progression.push(nextChord);
            currentPosition = nextChord;
        }

        generatedProgression = progression;
        return progression;
    }

    // ========== VOICINGS JAZZ ==========

    function getJazzVoicing(degree, keyPitch) {
        var degreeInfo = jazzDegrees[degree];
        if (!degreeInfo) degreeInfo = jazzDegrees["Imaj7"];

        var chordType = chordTypes[degreeInfo.type];
        var root = (degreeInfo.root + keyPitch) % 12;

        if (selectedVoicing === 0) {
            return getShellVoicing(root, chordType);
        } else if (selectedVoicing === 1) {
            return getDrop2Voicing(root, chordType);
        } else if (selectedVoicing === 2) {
            return getRootlessAVoicing(root, chordType);
        } else if (selectedVoicing === 3) {
            return getRootlessBVoicing(root, chordType);
        } else {
            return getBlockVoicing(root, chordType);
        }
    }

    /**
     * Shell voicing: 1-3-7 (o 1-7-3)
     * LH: root, RH: 3-7
     */
    function getShellVoicing(root, chordType) {
        var intervals = chordType.intervals;
        var bass = 36 + root;  // Octava baja
        if (bass < 36) bass += 12;

        var third = 60 + ((root + intervals[1]) % 12);
        var seventh = intervals.length > 3 ? 60 + ((root + intervals[3]) % 12) : third + 5;

        // Asegurar que seventh esta arriba de third
        if (seventh <= third) seventh += 12;

        return {
            lh: [bass],
            rh: [third, seventh]
        };
    }

    /**
     * Drop 2: segunda voz desde arriba baja una octava
     * Voicing cerrado: 1-3-5-7, Drop 2: 5-1-3-7 (5 baja)
     */
    function getDrop2Voicing(root, chordType) {
        var intervals = chordType.intervals;
        var bass = 36 + root;

        // Construir voicing cerrado primero
        var notes = [];
        for (var i = 0; i < Math.min(4, intervals.length); i++) {
            notes.push(60 + ((root + intervals[i]) % 12));
        }
        // Ordenar
        notes.sort(function(a, b) { return a - b; });

        // Drop 2: segunda desde arriba baja octava
        if (notes.length >= 4) {
            var drop = notes[2];  // Segunda desde arriba
            notes[2] = drop - 12;
            notes.sort(function(a, b) { return a - b; });
        }

        return {
            lh: [bass, notes[0]],
            rh: [notes[1], notes[2], notes[3]].filter(function(n) { return n !== undefined; })
        };
    }

    /**
     * Rootless A: 3-5-7-9 (sin fundamental)
     * Para usar con bajista
     */
    function getRootlessAVoicing(root, chordType) {
        var intervals = chordType.intervals;
        var bass = 36 + root;

        // 3-5-7-9
        var third = 55 + ((root + intervals[1]) % 12);
        var fifth = 55 + ((root + intervals[2]) % 12);
        var seventh = intervals.length > 3 ? 55 + ((root + intervals[3]) % 12) : fifth + 3;
        var ninth = intervals.length > 4 ? 55 + ((root + intervals[4]) % 12) : seventh + 3;

        // Ordenar y ajustar
        var rhNotes = [third, fifth, seventh, ninth];
        rhNotes.sort(function(a, b) { return a - b; });

        return {
            lh: [bass],
            rh: rhNotes.slice(0, 4)
        };
    }

    /**
     * Rootless B: 7-9-3-5
     * Inversion del rootless A
     */
    function getRootlessBVoicing(root, chordType) {
        var intervals = chordType.intervals;
        var bass = 36 + root;

        // 7-9-3-5
        var seventh = intervals.length > 3 ? 48 + ((root + intervals[3]) % 12) : 48 + root + 10;
        var ninth = intervals.length > 4 ? 48 + ((root + intervals[4]) % 12) : seventh + 3;
        var third = 55 + ((root + intervals[1]) % 12);
        var fifth = 55 + ((root + intervals[2]) % 12);

        if (ninth <= seventh) ninth += 12;
        if (third <= ninth) third += 12;
        if (fifth <= third) fifth += 12;

        return {
            lh: [bass],
            rh: [seventh, ninth, third, fifth].slice(0, 4)
        };
    }

    /**
     * Block voicing: todas las notas juntas
     */
    function getBlockVoicing(root, chordType) {
        var intervals = chordType.intervals;
        var bass = 36 + root;

        var notes = [];
        for (var i = 1; i < Math.min(5, intervals.length); i++) {
            var note = 55 + ((root + intervals[i]) % 12);
            notes.push(note);
        }
        notes.sort(function(a, b) { return a - b; });

        // Ajustar para que no haya notas muy juntas
        for (var j = 1; j < notes.length; j++) {
            if (notes[j] <= notes[j-1]) {
                notes[j] += 12;
            }
        }

        return {
            lh: [bass, notes[0]],
            rh: notes.slice(1, 4)
        };
    }

    // ========== WALKING BASS (v0.3 - Blue Note) ==========

    /**
     * Genera walking bass estilo Blue Note
     * Devuelve array de {pitch, duration} donde duration es fraccion de compas
     *
     * Tecnicas implementadas:
     *   - Double chromatic approach (dos semitonos antes del target)
     *   - Enclosure (nota arriba + nota abajo → target)
     *   - Chromatic walkup (4 semitonos hacia target)
     *   - Corcheas swing (entre beats 3-4)
     *   - Variacion aleatoria constante
     *
     * Reglas de jazz:
     *   Beat 1: Root (ancla armonica) - SIEMPRE
     *   Beat 2: Nota de paso (2ª, 3ª, o cromatica)
     *   Beat 3: Target harmonico (5ª, 3ª, o 7ª)
     *   Beat 4: Approach cromatico (semitono hacia siguiente root)
     */
    function getWalkingBass(currentDegree, nextDegree, keyPitch, chordIndex) {
        var currentInfo = jazzDegrees[currentDegree] || jazzDegrees["Imaj7"];
        var nextInfo = jazzDegrees[nextDegree] || jazzDegrees["Imaj7"];

        var root = (currentInfo.root + keyPitch) % 12;
        var targetRoot = (nextInfo.root + keyPitch) % 12;

        var chordType = chordTypes[currentInfo.type];
        var intervals = chordType.intervals;

        // Notas del acorde actual (octava baja C2-C3)
        var bassRoot = 36 + root;
        var second = bassRoot + 2;
        var third = bassRoot + intervals[1];
        var fourth = bassRoot + 5;
        var fifth = bassRoot + intervals[2];
        var sixth = bassRoot + 9;
        var seventh = bassRoot + (intervals[3] || 10);

        // Target: root del siguiente acorde
        var targetBass = 36 + targetRoot;

        // Ajustar target a octava cercana (voice leading suave)
        while (targetBass < bassRoot - 7) targetBass += 12;
        while (targetBass > bassRoot + 7) targetBass -= 12;

        // Approach notes
        var approachBelow = targetBass - 1;  // Semitono abajo
        var approachAbove = targetBass + 1;  // Semitono arriba
        var doubleBelow = targetBass - 2;    // Dos semitonos abajo

        // Direccion general del movimiento
        var movingUp = targetBass > bassRoot;
        var ascending = (chordIndex % 2 === 0);  // Alterna oleaje

        // Randoms para variacion
        var r1 = Math.random();
        var r2 = Math.random();
        var r3 = Math.random();

        var notes = [];  // Array de {pitch, dur}

        // ========== PATRON BLUE NOTE (pro) ==========
        if (selectedWalkingPattern === 0) {

            // Beat 1: SIEMPRE root (ancla)
            notes.push({ pitch: bassRoot, dur: "quarter" });

            // Beat 2: Variacion (escalar, arpegio, o cromatico)
            var beat2;
            if (r1 < 0.4) {
                beat2 = ascending ? second : (seventh - 12);  // Escalar
            } else if (r1 < 0.7) {
                beat2 = ascending ? third : (fifth - 12);     // Arpegio
            } else {
                beat2 = ascending ? (bassRoot + 1) : (bassRoot - 1);  // Cromatico
            }
            notes.push({ pitch: beat2, dur: "quarter" });

            // Beat 3: Target harmonico con variacion
            var beat3;
            if (r2 < 0.5) {
                beat3 = ascending ? fifth : (third - 12);
            } else if (r2 < 0.8) {
                beat3 = ascending ? third : (seventh - 12);
            } else {
                beat3 = ascending ? seventh : (sixth - 12);
            }

            // ¿Tresillo swing en beat 3-4? (25% probabilidad)
            if (r3 < probSwingTriplet) {
                // TRESILLO SWING: nota larga (2/3) + nota corta (1/3)
                // Esto crea el autentico swing feel de jazz
                notes.push({ pitch: beat3, dur: "swing_long" });

                // Ghost note o passing tone (parte corta del tresillo)
                var ghost = (beat3 + (movingUp ? 1 : -1));
                notes.push({ pitch: ghost, dur: "swing_short" });

                // Beat 4: approach (negra normal)
                var approach = movingUp ? approachBelow : approachAbove;
                notes.push({ pitch: approach, dur: "quarter" });

            } else {
                // Normal: negras
                notes.push({ pitch: beat3, dur: "quarter" });

                // Beat 4: Elegir tipo de approach
                if (r2 < probDoubleChromatic) {
                    // Double chromatic con swing triplet
                    notes[2].dur = "swing_long";
                    notes.push({ pitch: doubleBelow, dur: "swing_short" });
                    notes.push({ pitch: approachBelow, dur: "quarter" });
                } else if (r2 < probDoubleChromatic + probEnclosure) {
                    // Enclosure con swing triplet
                    notes[2].dur = "swing_long";
                    notes.push({ pitch: approachAbove, dur: "swing_short" });
                    notes.push({ pitch: approachBelow, dur: "quarter" });
                } else {
                    // Simple chromatic approach
                    var approach = movingUp ? approachBelow : approachAbove;
                    notes.push({ pitch: approach, dur: "quarter" });
                }
            }

        // ========== OLEAJE (mas simple) ==========
        } else if (selectedWalkingPattern === 1) {

            notes.push({ pitch: bassRoot, dur: "quarter" });

            if (ascending) {
                var beat2 = (r1 < 0.5) ? second : third;
                notes.push({ pitch: beat2, dur: "quarter" });
                notes.push({ pitch: fifth, dur: "quarter" });
            } else {
                var beat2 = (r1 < 0.5) ? (seventh - 12) : (sixth - 12);
                notes.push({ pitch: beat2, dur: "quarter" });
                notes.push({ pitch: fifth - 12, dur: "quarter" });
            }

            var approach = movingUp ? approachBelow : approachAbove;
            notes.push({ pitch: approach, dur: "quarter" });

        // ========== ESCALAR ==========
        } else if (selectedWalkingPattern === 2) {

            notes.push({ pitch: bassRoot, dur: "quarter" });

            if (ascending) {
                notes.push({ pitch: second, dur: "quarter" });
                notes.push({ pitch: third, dur: "quarter" });
            } else {
                notes.push({ pitch: seventh - 12, dur: "quarter" });
                notes.push({ pitch: sixth - 12, dur: "quarter" });
            }

            var approach = movingUp ? approachBelow : approachAbove;
            notes.push({ pitch: approach, dur: "quarter" });

        // ========== CROMATICO (chromatic walkup/down) ==========
        } else {
            var diff = targetBass - bassRoot;
            var dir = diff > 0 ? 1 : -1;

            // Chromatic 4: root + 3 semitonos hacia target
            notes.push({ pitch: bassRoot, dur: "quarter" });
            notes.push({ pitch: bassRoot + dir, dur: "quarter" });
            notes.push({ pitch: bassRoot + dir * 2, dur: "quarter" });
            notes.push({ pitch: targetBass - dir, dur: "quarter" });  // Approach
        }

        // Asegurar rango valido (C2-G3 = 36-55)
        for (var i = 0; i < notes.length; i++) {
            while (notes[i].pitch < 36) notes[i].pitch += 12;
            while (notes[i].pitch > 55) notes[i].pitch -= 12;
        }

        return notes;
    }

    // ========== COMPING RH (v0.4) ==========

    /**
     * Genera patron ritmico de comping para RH
     * Devuelve array de {beat, dur} donde beat es posicion en el compas
     *
     * Patrones tipicos de jazz:
     *   Charleston:         beat 1 + & of 2
     *   Reverse Charleston: & of 1 + beat 3
     *   Anticipation:       & of 4 (anticipa siguiente acorde)
     *   Syncopated:         varios patrones sincopados
     */
    function getCompingRhythm(chordIndex) {
        var r = Math.random();
        var rhythm = [];

        if (selectedCompingStyle === 0) {
            // BLOQUE: redonda en beat 1
            rhythm.push({ beat: 1, dur: "whole" });

        } else if (selectedCompingStyle === 1) {
            // CHARLESTON: beat 1 + & of 2
            // El patron mas comun en jazz comping
            rhythm.push({ beat: 1, dur: "quarter" });      // Beat 1
            rhythm.push({ beat: 2.5, dur: "quarter" });    // & of 2

            // Variacion: a veces solo beat 1
            if (r < probCompingVariation) {
                rhythm = [{ beat: 1, dur: "half" }];
            }

        } else if (selectedCompingStyle === 2) {
            // REVERSE CHARLESTON: & of 1 + beat 3
            rhythm.push({ beat: 1.5, dur: "quarter" });    // & of 1
            rhythm.push({ beat: 3, dur: "quarter" });      // Beat 3

            // Variacion: a veces añade beat 4
            if (r < probCompingVariation) {
                rhythm.push({ beat: 4, dur: "quarter" });
            }

        } else if (selectedCompingStyle === 3) {
            // ANTICIPATION: & of 4 (anticipa siguiente acorde)
            // Solo toca en la segunda mitad del compas
            rhythm.push({ beat: 2, dur: "quarter" });      // Beat 2
            rhythm.push({ beat: 4.5, dur: "quarter" });    // & of 4 (anticipacion)

            // Variacion: Charleston + anticipacion
            if (r < probCompingVariation) {
                rhythm = [
                    { beat: 1, dur: "quarter" },
                    { beat: 2.5, dur: "quarter" },
                    { beat: 4.5, dur: "quarter" }
                ];
            }

        } else {
            // SYNCOPATED: patrones variados
            var patterns = [
                // Patron 1: off-beats
                [{ beat: 1.5, dur: "quarter" }, { beat: 2.5, dur: "quarter" }, { beat: 4, dur: "quarter" }],
                // Patron 2: Charleston extendido
                [{ beat: 1, dur: "eighth" }, { beat: 2.5, dur: "quarter" }, { beat: 4.5, dur: "quarter" }],
                // Patron 3: Sparse
                [{ beat: 2, dur: "half" }],
                // Patron 4: Busy
                [{ beat: 1, dur: "quarter" }, { beat: 2, dur: "quarter" }, { beat: 3.5, dur: "quarter" }]
            ];
            rhythm = patterns[Math.floor(r * patterns.length)];
        }

        return rhythm;
    }

    // ========== UI ==========

    Rectangle {
        anchors.fill: parent
        color: "#0a0a12"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "\uD83C\uDFB7"  // Saxofon emoji
                    font.pixelSize: 24
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "Rameau Jazz"
                        font.pixelSize: 20
                        font.bold: true
                        color: "#f0c040"
                    }
                    Text {
                        text: "Progresiones ii-V-I con voicings jazz"
                        font.pixelSize: 11
                        color: "#806020"
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#302010" }

            // Tonalidad y Estilo
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Tonalidad"; font.pixelSize: 11; color: "#a08040" }
                    ComboBox {
                        id: keyCombo
                        Layout.fillWidth: true
                        model: keys
                        currentIndex: 0
                        onCurrentTextChanged: selectedKey = currentText
                        background: Rectangle { color: "#1a1408"; radius: 4 }
                        contentItem: Text { text: keyCombo.currentText; color: "#f0c040"; leftPadding: 8; verticalAlignment: Text.AlignVCenter }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Estilo (v0.6)"; font.pixelSize: 11; color: "#40a080" }
                    ComboBox {
                        id: styleCombo
                        Layout.fillWidth: true
                        model: stylePresets
                        currentIndex: 0
                        onCurrentIndexChanged: selectedStylePreset = currentIndex
                        background: Rectangle { color: "#081a14"; radius: 4 }
                        contentItem: Text { text: styleCombo.currentText; color: "#40f0a0"; leftPadding: 8; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }

            // Acordes y complejidad
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    RowLayout {
                        Text { text: "Acordes"; font.pixelSize: 11; color: "#a08040" }
                        Item { Layout.fillWidth: true }
                        Text { text: numChords; font.pixelSize: 11; font.bold: true; color: "#f0c040" }
                    }
                    Slider {
                        Layout.fillWidth: true
                        from: 4; to: 16; stepSize: 1; value: 8
                        onValueChanged: numChords = value
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Complejidad"; font.pixelSize: 11; color: "#a08040" }
                    ComboBox {
                        id: complexityCombo
                        Layout.fillWidth: true
                        model: chordComplexity
                        currentIndex: 0
                        onCurrentIndexChanged: selectedComplexity = currentIndex
                        background: Rectangle { color: "#1a1408"; radius: 4 }
                        contentItem: Text { text: complexityCombo.currentText; color: "#f0c040"; leftPadding: 8; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }

            // Voicing
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                Text { text: "Estilo de Voicing"; font.pixelSize: 11; color: "#a08040" }
                ComboBox {
                    id: voicingCombo
                    Layout.fillWidth: true
                    model: voicingStyles
                    currentIndex: 0
                    onCurrentIndexChanged: selectedVoicing = currentIndex
                    background: Rectangle { color: "#1a1408"; radius: 4 }
                    contentItem: Text { text: voicingCombo.currentText; color: "#f0c040"; leftPadding: 8; verticalAlignment: Text.AlignVCenter }
                }
            }

            // Walking Bass (v0.2)
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Bajo"; font.pixelSize: 11; color: "#a08040" }
                    ComboBox {
                        id: bassCombo
                        Layout.fillWidth: true
                        model: bassStyles
                        currentIndex: 0
                        onCurrentIndexChanged: selectedBassStyle = currentIndex
                        background: Rectangle { color: "#1a1408"; radius: 4 }
                        contentItem: Text { text: bassCombo.currentText; color: "#f0c040"; leftPadding: 8; verticalAlignment: Text.AlignVCenter }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Patron Walking"; font.pixelSize: 11; color: "#a08040" }
                    ComboBox {
                        id: walkingCombo
                        Layout.fillWidth: true
                        model: walkingPatterns
                        currentIndex: 0
                        enabled: selectedBassStyle === 1
                        onCurrentIndexChanged: selectedWalkingPattern = currentIndex
                        background: Rectangle { color: enabled ? "#1a1408" : "#0a0a08"; radius: 4 }
                        contentItem: Text { text: walkingCombo.currentText; color: enabled ? "#f0c040" : "#604020"; leftPadding: 8; verticalAlignment: Text.AlignVCenter }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Comping RH"; font.pixelSize: 11; color: "#a08040" }
                    ComboBox {
                        id: compingCombo
                        Layout.fillWidth: true
                        model: compingStyles
                        currentIndex: 0
                        onCurrentIndexChanged: selectedCompingStyle = currentIndex
                        background: Rectangle { color: "#1a1408"; radius: 4 }
                        contentItem: Text { text: compingCombo.currentText; color: "#f0c040"; leftPadding: 8; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }

            // Cadencia
            CheckBox {
                id: cadenceCheck
                text: "Terminar con ii-V-I"
                checked: true
                onCheckedChanged: endWithCadence = checked
                contentItem: Text { text: parent.text; color: "#f0c040"; font.pixelSize: 11; leftPadding: 24 }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#302010" }

            // Info voicing
            Rectangle {
                Layout.fillWidth: true
                height: 50
                color: "#1a1408"
                radius: 4

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: voicingStyles[selectedVoicing]
                        font.pixelSize: 12
                        font.bold: true
                        color: "#f0c040"
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: selectedVoicing === 0 ? "LH: root | RH: 3rd-7th" :
                              selectedVoicing === 1 ? "LH: root-drop | RH: 3-5-7" :
                              selectedVoicing === 2 ? "LH: root | RH: 3-5-7-9" :
                              selectedVoicing === 3 ? "LH: root | RH: 7-9-3-5" :
                              "LH: root-3rd | RH: 5-7-9"
                        font.pixelSize: 10
                        color: "#806020"
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Preview
            Rectangle {
                Layout.fillWidth: true
                height: 70
                color: "#1a1408"
                radius: 4
                Text {
                    id: previewText
                    anchors.centerIn: parent
                    text: "Click Previsualizar"
                    font.pixelSize: 11
                    font.family: "monospace"
                    color: "#806020"
                    wrapMode: Text.WordWrap
                    width: parent.width - 20
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // Botones
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Button {
                    text: "Previsualizar"
                    Layout.fillWidth: true
                    onClicked: {
                        var prog = generateProgression();
                        var chordNames = [];
                        for (var i = 0; i < prog.length; i++) {
                            chordNames.push(degreeToChordName(prog[i], selectedKey));
                        }
                        previewText.text = prog.join(" → ") + "\n" + chordNames.join(" → ");
                        previewText.color = "#f0c040";
                    }
                    background: Rectangle { color: "#1a1408"; radius: 4 }
                    contentItem: Text { text: parent.text; color: "#f0c040"; horizontalAlignment: Text.AlignHCenter }
                }

                Button {
                    text: "Generar"
                    Layout.fillWidth: true
                    onClicked: writeToScore()
                    background: Rectangle { color: "#f0c040"; radius: 4 }
                    contentItem: Text { text: parent.text; color: "#0a0a12"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                }
            }

            Button {
                text: "Cerrar"
                Layout.fillWidth: true
                onClicked: Qt.quit()
                background: Rectangle { color: "transparent"; border.color: "#302010"; radius: 4 }
                contentItem: Text { text: parent.text; color: "#806020"; horizontalAlignment: Text.AlignHCenter }
            }
        }
    }

    // ========== ESCRIBIR EN PARTITURA ==========

    function writeToScore() {
        // Aplicar preset de estilo antes de generar
        applyStylePreset();

        if (!curScore) {
            previewText.text = "Error: No hay partitura abierta";
            previewText.color = "#ff4040";
            return;
        }

        if (curScore.nstaves < 2) {
            previewText.text = "Error: Se necesita grand staff (2 pentagramas)";
            previewText.color = "#ff4040";
            return;
        }

        var prog = generateProgression();
        var keyPitch = keyPitches[selectedKey] || 0;

        curScore.startCmd();

        var cursorRH = curScore.newCursor();
        cursorRH.track = 0;
        cursorRH.rewind(0);

        var cursorLH = curScore.newCursor();
        cursorLH.track = 4;
        cursorLH.rewind(0);

        for (var i = 0; i < prog.length; i++) {
            var voicing = getJazzVoicing(prog[i], keyPitch);
            var nextDegree = (i < prog.length - 1) ? prog[i + 1] : prog[0];

            // LH: Bloque o Walking
            if (selectedBassStyle === 0) {
                // Bloque (redonda)
                cursorLH.setDuration(1, 1);
                cursorLH.addNote(voicing.lh[0], false);
                for (var l = 1; l < voicing.lh.length; l++) {
                    cursorLH.addNote(voicing.lh[l], true);
                }
            } else {
                // Walking bass con duraciones variables y tresillos swing
                var walkingNotes = getWalkingBass(prog[i], nextDegree, keyPitch, i);

                var w = 0;
                while (w < walkingNotes.length) {
                    var note = walkingNotes[w];

                    if (note.dur === "quarter") {
                        // Negra normal
                        cursorLH.setDuration(1, 4);
                        cursorLH.addNote(note.pitch, false);
                        w++;

                    } else if (note.dur === "swing_long") {
                        // TRESILLO SWING: negra + corchea de tresillo = 2/3 + 1/3 del beat
                        // Crear tresillo: 3 corcheas en espacio de 2 (= 1 negra)
                        cursorLH.addTuplet(fraction(3, 2), fraction(1, 4));

                        // Nota larga = negra de tresillo (2/3 del beat)
                        cursorLH.setDuration(1, 4);
                        cursorLH.addNote(note.pitch, false);

                        // Siguiente nota debe ser swing_short
                        w++;
                        if (w < walkingNotes.length && walkingNotes[w].dur === "swing_short") {
                            // Nota corta = corchea de tresillo (1/3 del beat)
                            cursorLH.setDuration(1, 8);
                            cursorLH.addNote(walkingNotes[w].pitch, false);
                            w++;
                        }

                    } else {
                        // Fallback: negra
                        cursorLH.setDuration(1, 4);
                        cursorLH.addNote(note.pitch, false);
                        w++;
                    }
                }
            }

            // RH: comping patterns
            var compRhythm = getCompingRhythm(i);

            for (var c = 0; c < compRhythm.length; c++) {
                var comp = compRhythm[c];

                // Silencio antes del beat si no es beat 1
                if (c === 0 && comp.beat > 1) {
                    // Calcular duracion del silencio inicial
                    var restBeats = comp.beat - 1;
                    if (restBeats >= 2) {
                        cursorRH.setDuration(1, 2);  // Blanca
                        cursorRH.addRest();
                        restBeats -= 2;
                    }
                    if (restBeats >= 1) {
                        cursorRH.setDuration(1, 4);  // Negra
                        cursorRH.addRest();
                        restBeats -= 1;
                    }
                    if (restBeats >= 0.5) {
                        cursorRH.setDuration(1, 8);  // Corchea
                        cursorRH.addRest();
                    }
                }

                // Duracion del acorde
                if (comp.dur === "whole") {
                    cursorRH.setDuration(1, 1);
                } else if (comp.dur === "half") {
                    cursorRH.setDuration(1, 2);
                } else if (comp.dur === "quarter") {
                    cursorRH.setDuration(1, 4);
                } else if (comp.dur === "eighth") {
                    cursorRH.setDuration(1, 8);
                } else {
                    cursorRH.setDuration(1, 4);  // Default: negra
                }

                // Escribir acorde RH
                cursorRH.addNote(voicing.rh[0], false);
                for (var r = 1; r < voicing.rh.length; r++) {
                    cursorRH.addNote(voicing.rh[r], true);
                }

                // Silencio entre acordes (si no es el ultimo)
                if (c < compRhythm.length - 1) {
                    var nextBeat = compRhythm[c + 1].beat;
                    var currentEnd = comp.beat + (comp.dur === "whole" ? 4 : comp.dur === "half" ? 2 : comp.dur === "quarter" ? 1 : 0.5);
                    var gapBeats = nextBeat - currentEnd;

                    if (gapBeats >= 1) {
                        cursorRH.setDuration(1, 4);
                        cursorRH.addRest();
                    } else if (gapBeats >= 0.5) {
                        cursorRH.setDuration(1, 8);
                        cursorRH.addRest();
                    }
                }
            }
        }

        curScore.endCmd();

        var chordNames = [];
        for (var j = 0; j < prog.length; j++) {
            chordNames.push(degreeToChordName(prog[j], selectedKey));
        }
        var bassInfo = selectedBassStyle === 1 ? " + Walking" : "";
        previewText.text = voicingStyles[selectedVoicing] + bassInfo + "\n" + chordNames.join(" → ");
        previewText.color = "#70ff70";
    }
}
