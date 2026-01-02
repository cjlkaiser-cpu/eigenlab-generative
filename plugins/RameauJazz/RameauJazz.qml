/**
 * RameauJazz.qml - Generador de progresiones jazz para piano
 *
 * Genera progresiones con acordes de 7a, 9a y voicings de jazz.
 * Basado en cadenas ii-V-I y sustituciones armonicas.
 *
 * v0.1: Acordes de 7a, shell voicings, ii-V-I
 * v0.2: Walking bass opcional
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
    version: "0.2.0"
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
        'bII7':    { type: '7', root: 1, func: 'D', tension: 0.85 },  // Sustituto tritono
        'bVII7':   { type: '7', root: 10, func: 'SD', tension: 0.5 },
        '#IVm7b5': { type: 'm7b5', root: 6, func: 'SD', tension: 0.6 }
    })

    // ========== MATRIZ DE TRANSICION JAZZ ==========

    // Centrada en ii-V-I con sustituciones
    property var jazzTransitions: ({
        'Imaj7':   { 'Imaj7': 0.05, 'IIm7': 0.25, 'IIIm7': 0.05, 'IVmaj7': 0.20, 'V7': 0.10, 'VIm7': 0.20, 'VIIm7b5': 0.05, 'bII7': 0.05, '#IVm7b5': 0.05 },
        'IIm7':    { 'Imaj7': 0.05, 'IIm7': 0.02, 'IIIm7': 0.03, 'IVmaj7': 0.05, 'V7': 0.65, 'VIm7': 0.05, 'VIIm7b5': 0.05, 'bII7': 0.10 },
        'IIIm7':   { 'Imaj7': 0.05, 'IIm7': 0.05, 'IVmaj7': 0.15, 'V7': 0.10, 'VIm7': 0.55, 'VIIm7b5': 0.10 },
        'IVmaj7':  { 'Imaj7': 0.15, 'IIm7': 0.15, 'IIIm7': 0.10, 'IVmaj7': 0.05, 'V7': 0.35, 'VIm7': 0.05, 'VIIm7b5': 0.10, '#IVm7b5': 0.05 },
        'V7':      { 'Imaj7': 0.60, 'IIm7': 0.05, 'IIIm7': 0.02, 'IVmaj7': 0.03, 'V7': 0.05, 'VIm7': 0.20, 'bVII7': 0.05 },
        'VIm7':    { 'Imaj7': 0.10, 'IIm7': 0.35, 'IIIm7': 0.05, 'IVmaj7': 0.20, 'V7': 0.20, 'VIm7': 0.05, 'VIIm7b5': 0.05 },
        'VIIm7b5': { 'Imaj7': 0.10, 'IIm7': 0.10, 'IIIm7': 0.60, 'IVmaj7': 0.05, 'V7': 0.10, 'VIm7': 0.05 },
        'bII7':    { 'Imaj7': 0.85, 'IIm7': 0.05, 'VIm7': 0.10 },  // Resuelve a I
        'bVII7':   { 'Imaj7': 0.30, 'IVmaj7': 0.40, 'VIm7': 0.30 },
        '#IVm7b5': { 'IVmaj7': 0.50, 'V7': 0.40, 'Imaj7': 0.10 }
    })

    // ========== ESTILOS DE VOICING ==========

    property var voicingStyles: ["Shell (1-3-7)", "Drop 2", "Rootless A", "Rootless B", "Block"]
    property int selectedVoicing: 0

    property var chordComplexity: ["7as", "9as", "Mixto"]
    property int selectedComplexity: 0  // 0=7as, 1=9as, 2=mixto

    // ========== WALKING BASS (v0.2) ==========

    property var bassStyles: ["Bloque (redonda)", "Walking (negras)"]
    property int selectedBassStyle: 0  // 0=bloque, 1=walking

    property var walkingPatterns: ["Oleaje (realista)", "Escalar", "Arpegio", "Cromatico"]
    property int selectedWalkingPattern: 0

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
        if (selectedComplexity === 0) return chord;  // Solo 7as

        var upgrades = {
            'Imaj7': 'Imaj9',
            'IIm7': 'IIm9',
            'IVmaj7': 'IVmaj9',
            'V7': selectedComplexity === 2 && Math.random() > 0.5 ? 'V13' : 'V9'
        };

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

    // ========== WALKING BASS (v0.2) ==========

    /**
     * Genera 4 notas de walking bass para un compas
     * Reglas de jazz:
     *   Beat 1: Root (fundamental) - ancla armonica
     *   Beat 2: Nota de paso (escalar o arpegio)
     *   Beat 3: Target note (5ª o 3ª) - importante armonicamente
     *   Beat 4: Approach (semitono hacia siguiente root)
     *
     * Movimiento suave: evitar saltos > 5ª (excepto octava)
     */
    function getWalkingBass(currentDegree, nextDegree, keyPitch, chordIndex) {
        var currentInfo = jazzDegrees[currentDegree] || jazzDegrees["Imaj7"];
        var nextInfo = jazzDegrees[nextDegree] || jazzDegrees["Imaj7"];

        var root = (currentInfo.root + keyPitch) % 12;
        var targetRoot = (nextInfo.root + keyPitch) % 12;

        var chordType = chordTypes[currentInfo.type];
        var intervals = chordType.intervals;

        // Notas del acorde actual (en octava baja)
        var bassRoot = 36 + root;
        var second = bassRoot + 2;    // 2ª mayor (escalar)
        var third = bassRoot + intervals[1];  // 3ª (mayor o menor segun acorde)
        var fourth = bassRoot + 5;    // 4ª justa
        var fifth = bassRoot + intervals[2];  // 5ª
        var sixth = bassRoot + 9;     // 6ª
        var seventh = bassRoot + (intervals[3] || 10);  // 7ª

        // Target: root del siguiente acorde
        var targetBass = 36 + targetRoot;

        // Ajustar target a octava cercana (movimiento suave)
        while (targetBass < bassRoot - 6) targetBass += 12;
        while (targetBass > bassRoot + 6) targetBass -= 12;

        // Approach: semitono arriba o abajo del target
        // Elegir segun direccion del movimiento
        var movingUp = targetBass >= bassRoot;
        var approach = movingUp ? (targetBass - 1) : (targetBass + 1);

        // Variacion aleatoria para evitar mecanicidad
        var rand = Math.random();

        var pattern;

        if (selectedWalkingPattern === 0) {
            // OLEAJE (realista) - alterna direccion + variacion
            var ascending = (chordIndex % 2 === 0);

            if (ascending) {
                // Ascendente con variacion en beat 2
                var beat2 = (rand < 0.5) ? second : third;  // Escalar o arpegio
                var beat3 = fifth;  // Target harmonico
                pattern = [bassRoot, beat2, beat3, approach];
            } else {
                // Descendente
                var lowSeventh = seventh - 12;
                var lowSixth = sixth - 12;
                var beat2 = (rand < 0.5) ? lowSeventh : lowSixth;
                var lowFifth = fifth - 12;
                pattern = [bassRoot, beat2, lowFifth, approach];
            }

            // Ocasionalmente (20%) añadir cromatismo en beat 2
            if (rand > 0.8) {
                pattern[1] = ascending ? (bassRoot + 1) : (bassRoot - 1);
            }

        } else if (selectedWalkingPattern === 1) {
            // ESCALAR - movimiento por grados de la escala
            var ascending = (chordIndex % 2 === 0);

            if (ascending) {
                // 1 → 2 → 3 → approach (o 1 → 2 → 4 → approach)
                var beat3 = (rand < 0.6) ? third : fourth;
                pattern = [bassRoot, second, beat3, approach];
            } else {
                // 1 → 7↓ → 6↓ → approach
                var lowSeventh = seventh - 12;
                var lowSixth = sixth - 12;
                pattern = [bassRoot, lowSeventh, lowSixth, approach];
            }

        } else if (selectedWalkingPattern === 2) {
            // ARPEGIO - notas del acorde
            var ascending = (chordIndex % 2 === 0);

            if (ascending) {
                // 1 → 3 → 5 → approach
                pattern = [bassRoot, third, fifth, approach];
            } else {
                // 1 → 5↓ → 3↓ → approach
                var lowFifth = fifth - 12;
                var lowThird = third - 12;
                pattern = [bassRoot, lowFifth, lowThird, approach];
            }

            // Variacion: a veces usar 7ª en lugar de 5ª
            if (rand > 0.7) {
                pattern[2] = ascending ? seventh : (seventh - 12);
            }

        } else {
            // CROMATICO - semitonos hacia el target
            var diff = targetBass - bassRoot;
            var steps = Math.abs(diff);
            var dir = diff > 0 ? 1 : -1;

            if (steps <= 4) {
                // Cromatico directo
                pattern = [
                    bassRoot,
                    bassRoot + dir,
                    bassRoot + dir * 2,
                    approach
                ];
            } else {
                // Mixto: escalar + cromatico al final
                pattern = [
                    bassRoot,
                    bassRoot + dir * 2,  // Tono
                    approach - dir,      // Dos semitonos antes
                    approach
                ];
            }
        }

        // Asegurar rango valido (C2-G3 = 36-55)
        for (var i = 0; i < pattern.length; i++) {
            while (pattern[i] < 36) pattern[i] += 12;
            while (pattern[i] > 55) pattern[i] -= 12;
        }

        return pattern;
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

            // Tonalidad
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
                // Walking bass (4 negras)
                var walkingNotes = getWalkingBass(prog[i], nextDegree, keyPitch, i);
                cursorLH.setDuration(1, 4);  // Negra
                for (var w = 0; w < walkingNotes.length; w++) {
                    cursorLH.addNote(walkingNotes[w], false);
                }
            }

            // RH: siempre redonda
            cursorRH.setDuration(1, 1);
            cursorRH.addNote(voicing.rh[0], false);
            for (var r = 1; r < voicing.rh.length; r++) {
                cursorRH.addNote(voicing.rh[r], true);
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
