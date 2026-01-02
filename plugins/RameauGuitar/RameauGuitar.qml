/**
 * RameauGuitar.qml - Generador de progresiones para guitarra clasica
 *
 * Genera progresiones armonicas con voicings idiomaticos de guitarra.
 * Un solo pentagrama, maximo 4 notas por acorde.
 * v0.2: Validacion de voicings tocables (span de trastes)
 * v0.3: Opciones de salida (bloque, arpegios)
 *
 * Basado en el motor de Markov de RameauGenerator.
 */

import MuseScore 3.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

MuseScore {
    id: plugin
    title: "Rameau Guitar"
    description: "Genera progresiones armonicas para guitarra clasica"
    version: "0.3.0"
    pluginType: "dialog"

    width: 380
    height: 600

    // ========== CONSTANTES GUITARRA ==========

    // Rango de la guitarra clasica (E2 = 40 a B5 = 83, pero usamos rango practico)
    property int guitarMin: 40   // E2 (cuerda 6 al aire)
    property int guitarMax: 76   // E5 (traste 12, cuerda 1)

    // Cuerdas: [cuerda 6 (grave) ... cuerda 1 (aguda)]
    // Cada cuerda: { open: MIDI al aire, maxFret: traste maximo practico }
    property var guitarStrings: ([
        { open: 40, maxFret: 12 },  // Cuerda 6: E2
        { open: 45, maxFret: 12 },  // Cuerda 5: A2
        { open: 50, maxFret: 12 },  // Cuerda 4: D3
        { open: 55, maxFret: 12 },  // Cuerda 3: G3
        { open: 59, maxFret: 12 },  // Cuerda 2: B3
        { open: 64, maxFret: 12 }   // Cuerda 1: E4
    ])

    // Cuerdas al aire (E2, A2, D3, G3, B3, E4)
    property var openStrings: [40, 45, 50, 55, 59, 64]

    // Maximo span de trastes para acordes comodos
    property int maxFretSpan: 4  // 4 trastes (ej: trastes 1-4 o 5-8)

    // ========== OPCIONES DE SALIDA ==========

    property var outputModes: ["Bloque", "Arpegio ↑", "Arpegio ↓", "p-i-m-a-m-i"]
    property int selectedOutputMode: 0  // 0=bloque, 1=asc, 2=desc, 3=patron

    property var baseDurations: ["Negra", "Corchea", "Semicorchea"]
    property int selectedDuration: 1  // 0=negra, 1=corchea, 2=semicorchea

    // ========== DATOS DE ACORDES ==========

    property var keyPitches: ({
        'C': 0, 'C#': 1, 'Db': 1, 'D': 2, 'D#': 3, 'Eb': 3,
        'E': 4, 'F': 5, 'F#': 6, 'Gb': 6, 'G': 7, 'G#': 8,
        'Ab': 8, 'A': 9, 'A#': 10, 'Bb': 10, 'B': 11
    })

    property var chordsMajor: ({
        'I':    { func: 'T', tension: 0.0, root: 0, third: 4, fifth: 7 },
        'ii':   { func: 'S', tension: 0.5, root: 2, third: 5, fifth: 9 },
        'iii':  { func: 'T', tension: 0.3, root: 4, third: 7, fifth: 11 },
        'IV':   { func: 'S', tension: 0.4, root: 5, third: 9, fifth: 0 },
        'V':    { func: 'D', tension: 0.8, root: 7, third: 11, fifth: 2 },
        'vi':   { func: 'T', tension: 0.2, root: 9, third: 0, fifth: 4 },
        'viio': { func: 'D', tension: 0.85, root: 11, third: 2, fifth: 5 }
    })

    property var chordsMinor: ({
        'i':    { func: 'T', tension: 0.0, root: 0, third: 3, fifth: 7 },
        'iio':  { func: 'S', tension: 0.55, root: 2, third: 5, fifth: 8 },
        'III':  { func: 'T', tension: 0.3, root: 3, third: 7, fifth: 10 },
        'iv':   { func: 'S', tension: 0.45, root: 5, third: 8, fifth: 0 },
        'V':    { func: 'D', tension: 0.8, root: 7, third: 11, fifth: 2 },
        'VI':   { func: 'T', tension: 0.25, root: 8, third: 0, fifth: 3 },
        'viio': { func: 'D', tension: 0.85, root: 11, third: 2, fifth: 5 }
    })

    property var transitionsMajor: ({
        'I':    { 'I': 0.05, 'ii': 0.15, 'iii': 0.05, 'IV': 0.25, 'V': 0.30, 'vi': 0.15, 'viio': 0.05 },
        'ii':   { 'I': 0.05, 'ii': 0.05, 'iii': 0.02, 'IV': 0.08, 'V': 0.60, 'vi': 0.05, 'viio': 0.15 },
        'iii':  { 'I': 0.10, 'ii': 0.05, 'iii': 0.02, 'IV': 0.30, 'V': 0.10, 'vi': 0.40, 'viio': 0.03 },
        'IV':   { 'I': 0.15, 'ii': 0.10, 'iii': 0.02, 'IV': 0.05, 'V': 0.50, 'vi': 0.05, 'viio': 0.13 },
        'V':    { 'I': 0.70, 'ii': 0.02, 'iii': 0.02, 'IV': 0.05, 'V': 0.05, 'vi': 0.14, 'viio': 0.02 },
        'vi':   { 'I': 0.10, 'ii': 0.25, 'iii': 0.05, 'IV': 0.30, 'V': 0.20, 'vi': 0.05, 'viio': 0.05 },
        'viio': { 'I': 0.80, 'ii': 0.02, 'iii': 0.05, 'IV': 0.02, 'V': 0.03, 'vi': 0.05, 'viio': 0.03 }
    })

    property var transitionsMinor: ({
        'i':    { 'i': 0.05, 'iio': 0.12, 'III': 0.08, 'iv': 0.25, 'V': 0.30, 'VI': 0.15, 'viio': 0.05 },
        'iio':  { 'i': 0.05, 'iio': 0.03, 'III': 0.02, 'iv': 0.10, 'V': 0.60, 'VI': 0.05, 'viio': 0.15 },
        'III':  { 'i': 0.12, 'iio': 0.05, 'III': 0.03, 'iv': 0.25, 'V': 0.10, 'VI': 0.40, 'viio': 0.05 },
        'iv':   { 'i': 0.10, 'iio': 0.08, 'III': 0.02, 'iv': 0.05, 'V': 0.55, 'VI': 0.05, 'viio': 0.15 },
        'V':    { 'i': 0.70, 'iio': 0.02, 'III': 0.02, 'iv': 0.03, 'V': 0.05, 'VI': 0.15, 'viio': 0.03 },
        'VI':   { 'i': 0.10, 'iio': 0.20, 'III': 0.10, 'iv': 0.30, 'V': 0.20, 'VI': 0.05, 'viio': 0.05 },
        'viio': { 'i': 0.80, 'iio': 0.02, 'III': 0.03, 'iv': 0.02, 'V': 0.05, 'VI': 0.05, 'viio': 0.03 }
    })

    // ========== ESTADO ==========

    property string selectedKey: "E"  // E y A son buenas para guitarra
    property string selectedMode: "major"
    property int numChords: 8
    property real gravityValue: 0.5
    property bool startWithTonic: true
    property bool endWithCadence: true

    property string currentPosition: "I"
    property real currentTension: 0
    property var generatedProgression: []

    // Tonalidades buenas para guitarra (con cuerdas al aire)
    property var keys: ["E", "A", "D", "G", "C", "Am", "Em", "Dm"]

    property var noteNames: ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    property var noteNamesFlat: ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]

    // Voicing actual para guitarra [bajo, voz2, voz3, voz4]
    property var currentVoicing: [40, 47, 52, 56]

    // ========== FUNCIONES DE ANALISIS ==========

    function degreeToChordName(degree, keyName) {
        var actualKey = keyName.replace("m", "");  // Am -> A
        var chords = getChords();
        var chord = chords[degree];
        if (!chord) return degree;

        var keyPitch = keyPitches[actualKey] || 0;
        var rootPitch = (chord.root + keyPitch) % 12;

        var useFlats = ["F", "Bb", "Eb", "Ab", "Db", "Gb"].indexOf(actualKey) >= 0;
        var noteName = useFlats ? noteNamesFlat[rootPitch] : noteNames[rootPitch];

        var quality = "";
        if (degree.indexOf("o") >= 0) {
            quality = "dim";
        } else if (degree === degree.toLowerCase() && degree !== "viio" && degree !== "iio") {
            quality = "m";
        }

        return noteName + quality;
    }

    // ========== FUNCIONES DE MARKOV ==========

    function getChords() {
        return selectedMode === "minor" ? chordsMinor : chordsMajor;
    }

    function getTransitions() {
        return selectedMode === "minor" ? transitionsMinor : transitionsMajor;
    }

    function getTonic() {
        return selectedMode === "minor" ? "i" : "I";
    }

    function selectNextChord() {
        var transitions = getTransitions();
        var probs = transitions[currentPosition];

        if (!probs) {
            currentPosition = getTonic();
            probs = transitions[currentPosition];
        }

        var rand = Math.random();
        var cumulative = 0;

        var chordList = Object.keys(probs);
        for (var i = 0; i < chordList.length; i++) {
            var chord = chordList[i];
            cumulative += probs[chord];
            if (rand < cumulative) {
                return chord;
            }
        }
        return getTonic();
    }

    function generateProgression() {
        var progression = [];
        currentPosition = getTonic();
        currentTension = 0;

        for (var i = 0; i < numChords; i++) {
            if (endWithCadence && i === numChords - 2) {
                currentPosition = "V";
                progression.push("V");
                continue;
            }
            if (endWithCadence && i === numChords - 1) {
                currentPosition = getTonic();
                progression.push(getTonic());
                continue;
            }

            var nextChord = selectNextChord();
            progression.push(nextChord);
            currentPosition = nextChord;
        }

        generatedProgression = progression;
        return progression;
    }

    // ========== VOICING GUITARRA ==========

    function getGuitarVoicing(chordName, keyPitch) {
        var chords = getChords();
        var chord = chords[chordName];
        if (!chord) return currentVoicing;

        var root = (chord.root + keyPitch) % 12;
        var third = (chord.third + keyPitch) % 12;
        var fifth = (chord.fifth + keyPitch) % 12;

        // Encontrar bajo (fundamental en cuerdas graves)
        var bass = findBassNote(root);

        // Construir voicing de 4 notas dentro del rango de guitarra
        var voicing = [bass];
        var usedPitchClasses = [root];

        // Añadir tercera
        var thirdNote = findNextNote(third, bass + 3, bass + 12);
        if (thirdNote > 0) {
            voicing.push(thirdNote);
            usedPitchClasses.push(third);
        }

        // Añadir quinta
        var fifthNote = findNextNote(fifth, voicing[voicing.length - 1], voicing[voicing.length - 1] + 7);
        if (fifthNote > 0 && voicing.length < 4) {
            voicing.push(fifthNote);
        }

        // Duplicar fundamental arriba si hay espacio
        if (voicing.length < 4) {
            var highRoot = findNextNote(root, voicing[voicing.length - 1] + 1, guitarMax);
            if (highRoot > 0) {
                voicing.push(highRoot);
            }
        }

        // Asegurar que tenemos al menos 3 notas
        while (voicing.length < 3) {
            voicing.push(voicing[voicing.length - 1] + 5);
        }

        // Ordenar y limitar a 4 notas
        voicing.sort(function(a, b) { return a - b; });
        if (voicing.length > 4) {
            voicing = voicing.slice(0, 4);
        }

        currentVoicing = voicing;
        return voicing;
    }

    function findBassNote(pitchClass) {
        // Buscar en cuerdas graves (6, 5, 4)
        for (var midi = 40; midi <= 55; midi++) {
            if (midi % 12 === pitchClass) {
                return midi;
            }
        }
        return 40 + pitchClass;  // Fallback
    }

    function findNextNote(pitchClass, minMidi, maxMidi) {
        for (var midi = minMidi; midi <= maxMidi && midi <= guitarMax; midi++) {
            if (midi % 12 === pitchClass) {
                return midi;
            }
        }
        return -1;  // No encontrado
    }

    // ========== VALIDACION DE DIGITACION (v0.2) ==========

    /**
     * Asigna cada nota MIDI a una cuerda de guitarra
     * Retorna: array de { midi, string, fret } o null si imposible
     */
    function assignStrings(voicing) {
        var sorted = voicing.slice().sort(function(a, b) { return a - b; });
        var assignment = [];

        // Intentar asignar cada nota a una cuerda, de grave a aguda
        var usedStrings = [];

        for (var i = 0; i < sorted.length; i++) {
            var midi = sorted[i];
            var assigned = false;

            // Buscar cuerda disponible que pueda tocar esta nota
            for (var s = 0; s < guitarStrings.length; s++) {
                if (usedStrings.indexOf(s) >= 0) continue;  // Cuerda ya usada

                var openNote = guitarStrings[s].open;
                var maxFret = guitarStrings[s].maxFret;

                // ¿Puede esta cuerda tocar esta nota?
                if (midi >= openNote && midi <= openNote + maxFret) {
                    var fret = midi - openNote;
                    assignment.push({ midi: midi, string: s, fret: fret });
                    usedStrings.push(s);
                    assigned = true;
                    break;
                }
            }

            if (!assigned) {
                return null;  // No se puede tocar esta nota
            }
        }

        return assignment;
    }

    /**
     * Verifica si un voicing es tocable (span <= maxFretSpan)
     * Retorna: { valid: bool, span: int, minFret: int, maxFret: int, assignment: array }
     */
    function validateVoicing(voicing) {
        var assignment = assignStrings(voicing);
        if (!assignment) {
            return { valid: false, reason: "Nota fuera de rango" };
        }

        // Calcular span (ignorando cuerdas al aire, fret 0)
        var frettedNotes = assignment.filter(function(a) { return a.fret > 0; });

        if (frettedNotes.length === 0) {
            // Todas al aire - siempre valido
            return { valid: true, span: 0, minFret: 0, maxFret: 0, assignment: assignment, allOpen: true };
        }

        var frets = frettedNotes.map(function(a) { return a.fret; });
        var minFret = Math.min.apply(null, frets);
        var maxFret = Math.max.apply(null, frets);
        var span = maxFret - minFret;

        return {
            valid: span <= maxFretSpan,
            span: span,
            minFret: minFret,
            maxFret: maxFret,
            assignment: assignment,
            reason: span > maxFretSpan ? "Span " + span + " trastes (max " + maxFretSpan + ")" : null
        };
    }

    /**
     * Genera un voicing tocable para guitarra con validacion
     */
    function getValidGuitarVoicing(chordName, keyPitch, attempts) {
        attempts = attempts || 0;
        if (attempts > 10) {
            // Fallback: usar voicing simple aunque no sea ideal
            return getSimpleVoicing(chordName, keyPitch);
        }

        var voicing = getGuitarVoicing(chordName, keyPitch);
        var validation = validateVoicing(voicing);

        if (validation.valid) {
            return { voicing: voicing, validation: validation };
        }

        // Intentar ajustar: subir notas graves o bajar agudas
        var adjusted = adjustVoicingForPlayability(voicing, chordName, keyPitch);
        if (adjusted) {
            validation = validateVoicing(adjusted);
            if (validation.valid) {
                return { voicing: adjusted, validation: validation };
            }
        }

        // Ultimo recurso: voicing simple
        return { voicing: getSimpleVoicing(chordName, keyPitch), validation: { valid: true, simplified: true } };
    }

    /**
     * Intenta ajustar voicing para que sea tocable
     */
    function adjustVoicingForPlayability(voicing, chordName, keyPitch) {
        var chords = getChords();
        var chord = chords[chordName];
        if (!chord) return null;

        var root = (chord.root + keyPitch) % 12;
        var third = (chord.third + keyPitch) % 12;
        var fifth = (chord.fifth + keyPitch) % 12;
        var pitchClasses = [root, third, fifth];

        // Estrategia: buscar posicion comun en el mastil
        // Probar posiciones: abierta (0-4), II (2-5), V (5-9), VII (7-11)
        var positions = [0, 2, 5, 7];

        for (var p = 0; p < positions.length; p++) {
            var basePos = positions[p];
            var newVoicing = buildVoicingAtPosition(pitchClasses, basePos, root);
            if (newVoicing && newVoicing.length >= 3) {
                var val = validateVoicing(newVoicing);
                if (val.valid) {
                    return newVoicing;
                }
            }
        }

        return null;
    }

    /**
     * Construye voicing en una posicion especifica del mastil
     */
    function buildVoicingAtPosition(pitchClasses, basePosition, rootPitch) {
        var voicing = [];
        var usedStrings = [];

        // Primero: encontrar bajo (fundamental en cuerdas graves)
        for (var s = 0; s < 3; s++) {  // Solo cuerdas 6, 5, 4
            var openNote = guitarStrings[s].open;
            for (var fret = basePosition; fret <= basePosition + maxFretSpan && fret <= 12; fret++) {
                var midi = openNote + fret;
                if (midi % 12 === rootPitch) {
                    voicing.push(midi);
                    usedStrings.push(s);
                    break;
                }
            }
            if (voicing.length > 0) break;
        }

        if (voicing.length === 0) return null;

        // Luego: añadir resto de notas en cuerdas disponibles
        for (var pc = 0; pc < pitchClasses.length && voicing.length < 4; pc++) {
            var pitchClass = pitchClasses[pc];
            if (pitchClass === rootPitch && voicing.length > 0) continue;  // Ya tenemos el bajo

            for (var str = 0; str < guitarStrings.length && voicing.length < 4; str++) {
                if (usedStrings.indexOf(str) >= 0) continue;

                var open = guitarStrings[str].open;
                for (var f = Math.max(0, basePosition - 1); f <= basePosition + maxFretSpan && f <= 12; f++) {
                    var note = open + f;
                    if (note % 12 === pitchClass && note > voicing[voicing.length - 1]) {
                        voicing.push(note);
                        usedStrings.push(str);
                        break;
                    }
                }
            }
        }

        // Duplicar fundamental si hay espacio
        if (voicing.length < 4) {
            for (var ds = usedStrings[usedStrings.length - 1] + 1; ds < guitarStrings.length; ds++) {
                var dopen = guitarStrings[ds].open;
                for (var df = Math.max(0, basePosition - 1); df <= basePosition + maxFretSpan && df <= 12; df++) {
                    var dnote = dopen + df;
                    if (dnote % 12 === rootPitch && dnote > voicing[voicing.length - 1]) {
                        voicing.push(dnote);
                        break;
                    }
                }
                if (voicing.length >= 4) break;
            }
        }

        return voicing.length >= 3 ? voicing : null;
    }

    /**
     * Voicing simplificado de emergencia (power chord o triada basica)
     */
    function getSimpleVoicing(chordName, keyPitch) {
        var chords = getChords();
        var chord = chords[chordName];
        if (!chord) return [40, 47, 52];

        var root = (chord.root + keyPitch) % 12;
        var fifth = (chord.fifth + keyPitch) % 12;

        // Buscar fundamental en cuerda 6 o 5
        var bass = -1;
        for (var m = 40; m <= 50; m++) {
            if (m % 12 === root) {
                bass = m;
                break;
            }
        }
        if (bass < 0) bass = 40 + root;

        // Power chord: root + fifth + octave
        var fifthNote = bass + 7;  // Quinta justa
        var octave = bass + 12;

        return [bass, fifthNote, octave];
    }

    /**
     * Verifica si una nota es cuerda al aire
     */
    function isOpenString(midi) {
        return openStrings.indexOf(midi) >= 0;
    }

    // ========== UI ==========

    Rectangle {
        anchors.fill: parent
        color: "#1a1a2e"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "🎸"
                    font.pixelSize: 24
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "Rameau Guitar"
                        font.pixelSize: 20
                        font.bold: true
                        color: "#e8d5b7"
                    }
                    Text {
                        text: "Progresiones para guitarra clasica"
                        font.pixelSize: 11
                        color: "#8b7355"
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#3d3d5c" }

            // Tonalidad y Modo
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Tonalidad"; font.pixelSize: 11; color: "#b8a88a" }
                    ComboBox {
                        id: keyCombo
                        Layout.fillWidth: true
                        model: keys
                        currentIndex: 0
                        onCurrentTextChanged: {
                            var key = currentText;
                            if (key.indexOf("m") >= 0) {
                                selectedKey = key.replace("m", "");
                                selectedMode = "minor";
                                modeCombo.currentIndex = 1;
                            } else {
                                selectedKey = key;
                                selectedMode = "major";
                                modeCombo.currentIndex = 0;
                            }
                        }
                        background: Rectangle { color: "#2d2d44"; radius: 4 }
                        contentItem: Text { text: keyCombo.currentText; color: "#e8d5b7"; leftPadding: 8; verticalAlignment: Text.AlignVCenter }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Modo"; font.pixelSize: 11; color: "#b8a88a" }
                    ComboBox {
                        id: modeCombo
                        Layout.fillWidth: true
                        model: ["Mayor", "Menor"]
                        currentIndex: 0
                        onCurrentIndexChanged: selectedMode = (currentIndex === 0) ? "major" : "minor"
                        background: Rectangle { color: "#2d2d44"; radius: 4 }
                        contentItem: Text { text: modeCombo.currentText; color: "#e8d5b7"; leftPadding: 8; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }

            // Acordes
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Acordes a generar"; font.pixelSize: 11; color: "#b8a88a" }
                    Item { Layout.fillWidth: true }
                    Text { text: numChords; font.pixelSize: 11; font.bold: true; color: "#d4a574" }
                }
                Slider {
                    id: chordsSlider
                    Layout.fillWidth: true
                    from: 4; to: 16; stepSize: 1; value: 8
                    onValueChanged: numChords = value
                }
            }

            // Gravedad
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Gravedad tonal"; font.pixelSize: 11; color: "#b8a88a" }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: gravityValue < 0.3 ? "Libre" : (gravityValue > 0.7 ? "Estricto" : "Balanceado")
                        font.pixelSize: 11
                        color: gravityValue < 0.3 ? "#e07a5f" : (gravityValue > 0.7 ? "#81b29a" : "#f2cc8f")
                    }
                }
                Slider {
                    id: gravitySlider
                    Layout.fillWidth: true
                    from: 0; to: 1; value: 0.5
                    onValueChanged: gravityValue = value
                }
            }

            // Opciones
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                CheckBox {
                    id: tonicCheck
                    text: "Iniciar con tonica"
                    checked: true
                    onCheckedChanged: startWithTonic = checked
                    contentItem: Text { text: parent.text; color: "#e8d5b7"; font.pixelSize: 11; leftPadding: 24 }
                }
                CheckBox {
                    id: cadenceCheck
                    text: "Terminar V-I"
                    checked: true
                    onCheckedChanged: endWithCadence = checked
                    contentItem: Text { text: parent.text; color: "#e8d5b7"; font.pixelSize: 11; leftPadding: 24 }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#3d3d5c" }

            // Opciones de salida (v0.3)
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Tipo de salida"; font.pixelSize: 11; color: "#b8a88a" }
                    ComboBox {
                        id: outputCombo
                        Layout.fillWidth: true
                        model: outputModes
                        currentIndex: 0
                        onCurrentIndexChanged: selectedOutputMode = currentIndex
                        background: Rectangle { color: "#2d2d44"; radius: 4 }
                        contentItem: Text { text: outputCombo.currentText; color: "#e8d5b7"; leftPadding: 8; verticalAlignment: Text.AlignVCenter }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Duracion base"; font.pixelSize: 11; color: "#b8a88a" }
                    ComboBox {
                        id: durationCombo
                        Layout.fillWidth: true
                        model: baseDurations
                        currentIndex: 1
                        enabled: selectedOutputMode > 0  // Solo para arpegios
                        onCurrentIndexChanged: selectedDuration = currentIndex
                        background: Rectangle { color: enabled ? "#2d2d44" : "#1d1d2e"; radius: 4 }
                        contentItem: Text { text: durationCombo.currentText; color: enabled ? "#e8d5b7" : "#5b5b6b"; leftPadding: 8; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }

            // Info guitarra
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "#2d2d44"
                radius: 4

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 16

                    Text {
                        text: "Rango: E2-E5"
                        font.pixelSize: 10
                        color: "#8b7355"
                    }
                    Text {
                        text: "Span ≤" + maxFretSpan + " trastes"
                        font.pixelSize: 10
                        color: "#81b29a"
                    }
                    Text {
                        text: "Voicings validados"
                        font.pixelSize: 10
                        color: "#81b29a"
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Preview
            Rectangle {
                Layout.fillWidth: true
                height: 60
                color: "#2d2d44"
                radius: 4
                Text {
                    id: previewText
                    anchors.centerIn: parent
                    text: "Click Previsualizar"
                    font.pixelSize: 12
                    font.family: "monospace"
                    color: "#8b7355"
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
                        var actualKey = selectedKey;
                        for (var i = 0; i < prog.length; i++) {
                            chordNames.push(degreeToChordName(prog[i], actualKey));
                        }
                        previewText.text = prog.join(" → ") + "\n" + chordNames.join(" → ");
                        previewText.color = "#e8d5b7";
                    }
                    background: Rectangle { color: "#2d2d44"; radius: 4 }
                    contentItem: Text { text: parent.text; color: "#e8d5b7"; horizontalAlignment: Text.AlignHCenter }
                }

                Button {
                    text: "Generar"
                    Layout.fillWidth: true
                    onClicked: writeToScore()
                    background: Rectangle { color: "#d4a574"; radius: 4 }
                    contentItem: Text { text: parent.text; color: "#1a1a2e"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                }
            }

            Button {
                text: "Cerrar"
                Layout.fillWidth: true
                onClicked: Qt.quit()
                background: Rectangle { color: "transparent"; border.color: "#3d3d5c"; radius: 4 }
                contentItem: Text { text: parent.text; color: "#8b7355"; horizontalAlignment: Text.AlignHCenter }
            }
        }
    }

    // ========== ESCRIBIR EN PARTITURA ==========

    function writeToScore() {
        if (!curScore) {
            previewText.text = "Error: No hay partitura abierta";
            previewText.color = "#e07a5f";
            return;
        }

        var prog = generateProgression();
        var keyPitch = keyPitches[selectedKey] || 0;

        // Reset voicing
        currentVoicing = [40, 47, 52, 56];

        curScore.startCmd();

        var cursor = curScore.newCursor();
        cursor.track = 0;
        cursor.rewind(0);

        // Determinar duraciones segun modo
        var baseDur = getDurationValues();

        for (var i = 0; i < prog.length; i++) {
            // Usar nuevo sistema de voicing con validacion
            var result = getValidGuitarVoicing(prog[i], keyPitch);
            var voicing = result.voicing || getGuitarVoicing(prog[i], keyPitch);

            // Escribir segun modo de salida
            if (selectedOutputMode === 0) {
                // Bloque: acorde completo
                writeBlockChord(cursor, voicing);
            } else if (selectedOutputMode === 1) {
                // Arpegio ascendente
                writeArpeggio(cursor, voicing, false, baseDur);
            } else if (selectedOutputMode === 2) {
                // Arpegio descendente
                writeArpeggio(cursor, voicing, true, baseDur);
            } else if (selectedOutputMode === 3) {
                // Patron p-i-m-a-m-i
                writePattern(cursor, voicing, baseDur);
            }
        }

        curScore.endCmd();

        // Mostrar resultado
        var chordNames = [];
        for (var j = 0; j < prog.length; j++) {
            chordNames.push(degreeToChordName(prog[j], selectedKey));
        }
        var modeStr = outputModes[selectedOutputMode];
        previewText.text = modeStr + ": " + chordNames.join(" → ");
        previewText.color = "#81b29a";
    }

    /**
     * Obtiene valores de duracion para setDuration
     */
    function getDurationValues() {
        // selectedDuration: 0=negra, 1=corchea, 2=semicorchea
        if (selectedDuration === 0) {
            return { num: 1, den: 4 };   // Negra
        } else if (selectedDuration === 1) {
            return { num: 1, den: 8 };   // Corchea
        } else {
            return { num: 1, den: 16 };  // Semicorchea
        }
    }

    /**
     * Escribe acorde en bloque (redonda)
     */
    function writeBlockChord(cursor, voicing) {
        cursor.setDuration(1, 1);  // Redonda
        cursor.addNote(voicing[0], false);
        for (var v = 1; v < voicing.length; v++) {
            cursor.addNote(voicing[v], true);
        }
    }

    /**
     * Escribe arpegio (ascendente o descendente)
     */
    function writeArpeggio(cursor, voicing, descending, dur) {
        var notes = voicing.slice();
        if (descending) {
            notes.reverse();
        }

        cursor.setDuration(dur.num, dur.den);
        for (var i = 0; i < notes.length; i++) {
            cursor.addNote(notes[i], false);
        }
    }

    /**
     * Escribe patron p-i-m-a-m-i (6 notas por acorde)
     * p = pulgar (bajo), i = indice, m = medio, a = anular
     */
    function writePattern(cursor, voicing, dur) {
        // Asegurar que tenemos al menos 4 notas
        while (voicing.length < 4) {
            voicing.push(voicing[voicing.length - 1]);
        }

        // Patron: p-i-m-a-m-i = bajo, voz1, voz2, voz3, voz2, voz1
        var pattern = [
            voicing[0],  // p (bajo)
            voicing[1],  // i
            voicing[2],  // m
            voicing[3],  // a
            voicing[2],  // m
            voicing[1]   // i
        ];

        cursor.setDuration(dur.num, dur.den);
        for (var i = 0; i < pattern.length; i++) {
            cursor.addNote(pattern[i], false);
        }
    }
}
