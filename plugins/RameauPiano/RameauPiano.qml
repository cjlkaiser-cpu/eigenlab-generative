/**
 * RameauPiano.qml - Generador de progresiones para piano
 *
 * Genera progresiones armonicas distribuidas en grand staff:
 * - Mano izquierda (LH): Bajo + Tenor
 * - Mano derecha (RH): Alto + Soprano
 *
 * v0.2: Patrones de mano izquierda (Alberti, arpegio, stride, etc.)
 *
 * Basado en el motor de Markov de RameauGenerator.
 */

import MuseScore 3.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

MuseScore {
    id: plugin
    title: "Rameau Piano"
    description: "Genera progresiones armonicas para piano (grand staff)"
    version: "0.2.0"
    pluginType: "dialog"

    width: 380
    height: 600

    // ========== CONSTANTES PIANO ==========

    // Rangos por mano
    property var leftHandRange:  ({ min: 36, max: 60 })   // C2 - C4
    property var rightHandRange: ({ min: 55, max: 84 })   // G3 - C6

    // ========== PATRONES MANO IZQUIERDA ==========

    property var lhPatterns: ["Bloque", "Bajo-Acorde", "Arpegio ↑", "Arpegio ↓", "Alberti", "Stride"]
    property int selectedLHPattern: 0  // 0=bloque, 1=bajo-acorde, 2=arp↑, 3=arp↓, 4=alberti, 5=stride

    property var lhDurations: ["Blanca", "Negra", "Corchea"]
    property int selectedLHDuration: 2  // 0=blanca, 1=negra, 2=corchea

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

    property string selectedKey: "C"
    property string selectedMode: "major"
    property int numChords: 8
    property real gravityValue: 0.5
    property bool startWithTonic: true
    property bool endWithCadence: true

    property string currentPosition: "I"
    property real currentTension: 0
    property var generatedProgression: []

    property var keys: ["C", "G", "D", "A", "E", "F", "Bb", "Eb", "Ab", "Cm", "Gm", "Dm", "Am", "Em"]

    property var noteNames: ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    property var noteNamesFlat: ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]

    // Voicing actual [bass, tenor, alto, soprano]
    property var currentVoices: [48, 52, 60, 64]

    // ========== FUNCIONES DE ANALISIS ==========

    function degreeToChordName(degree, keyName) {
        var actualKey = keyName.replace("m", "");
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

    // ========== VOICE LEADING PIANO ==========

    function getNotesInRange(pitchClass, rangeMin, rangeMax) {
        var notes = [];
        for (var octave = 0; octave < 9; octave++) {
            var note = pitchClass + octave * 12;
            if (note >= rangeMin && note <= rangeMax) {
                notes.push(note);
            }
        }
        return notes;
    }

    function findClosestNote(target, options) {
        if (options.length === 0) return target;
        var closest = options[0];
        var minDist = Math.abs(target - closest);
        for (var i = 1; i < options.length; i++) {
            var dist = Math.abs(target - options[i]);
            if (dist < minDist) {
                minDist = dist;
                closest = options[i];
            }
        }
        return closest;
    }

    function getPianoVoicing(chordName, keyPitch) {
        var chords = getChords();
        var chord = chords[chordName];
        if (!chord) return currentVoices;

        var root = (chord.root + keyPitch) % 12;
        var third = (chord.third + keyPitch) % 12;
        var fifth = (chord.fifth + keyPitch) % 12;

        // Mano izquierda: bass (fundamental) + tenor (quinta o tercera)
        var bassOptions = getNotesInRange(root, 36, 55);
        var bass = bassOptions.length > 0 ? findClosestNote(currentVoices[0], bassOptions) : 48;

        var tenorOptions = getNotesInRange(fifth, bass + 3, 60).concat(getNotesInRange(third, bass + 3, 60));
        var tenor = tenorOptions.length > 0 ? findClosestNote(currentVoices[1], tenorOptions) : bass + 7;

        // Mano derecha: alto (tercera o quinta) + soprano (fundamental o tercera)
        var altoOptions = getNotesInRange(third, 58, 72).concat(getNotesInRange(fifth, 58, 72));
        var alto = altoOptions.length > 0 ? findClosestNote(currentVoices[2], altoOptions) : 64;

        var sopranoOptions = getNotesInRange(root, alto + 2, 79).concat(getNotesInRange(third, alto + 2, 79));
        var soprano = sopranoOptions.length > 0 ? findClosestNote(currentVoices[3], sopranoOptions) : alto + 5;

        // Asegurar orden y separacion minima
        if (tenor <= bass) tenor = bass + 4;
        if (alto <= tenor + 2) alto = tenor + 5;
        if (soprano <= alto) soprano = alto + 4;

        currentVoices = [bass, tenor, alto, soprano];
        return currentVoices;
    }

    // ========== UI ==========

    Rectangle {
        anchors.fill: parent
        color: "#0f0f1a"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "🎹"
                    font.pixelSize: 24
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "Rameau Piano"
                        font.pixelSize: 20
                        font.bold: true
                        color: "#f0f0f5"
                    }
                    Text {
                        text: "Progresiones para piano (grand staff)"
                        font.pixelSize: 11
                        color: "#6a6a8a"
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#2a2a4a" }

            // Tonalidad y Modo
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Tonalidad"; font.pixelSize: 11; color: "#9090b0" }
                    ComboBox {
                        id: keyCombo
                        Layout.fillWidth: true
                        model: keys
                        currentIndex: 0
                        onCurrentTextChanged: {
                            var key = currentText;
                            if (key.indexOf("m") >= 0 && key.length > 1 && key !== "Am" && key !== "Em" && key !== "Dm" && key !== "Gm" && key !== "Cm") {
                                selectedKey = key;
                                selectedMode = "major";
                            } else if (key.indexOf("m") >= 0) {
                                selectedKey = key.replace("m", "");
                                selectedMode = "minor";
                                modeCombo.currentIndex = 1;
                            } else {
                                selectedKey = key;
                                selectedMode = "major";
                                modeCombo.currentIndex = 0;
                            }
                        }
                        background: Rectangle { color: "#1a1a2e"; radius: 4 }
                        contentItem: Text { text: keyCombo.currentText; color: "#f0f0f5"; leftPadding: 8; verticalAlignment: Text.AlignVCenter }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Modo"; font.pixelSize: 11; color: "#9090b0" }
                    ComboBox {
                        id: modeCombo
                        Layout.fillWidth: true
                        model: ["Mayor", "Menor"]
                        currentIndex: 0
                        onCurrentIndexChanged: selectedMode = (currentIndex === 0) ? "major" : "minor"
                        background: Rectangle { color: "#1a1a2e"; radius: 4 }
                        contentItem: Text { text: modeCombo.currentText; color: "#f0f0f5"; leftPadding: 8; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }

            // Acordes
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Acordes a generar"; font.pixelSize: 11; color: "#9090b0" }
                    Item { Layout.fillWidth: true }
                    Text { text: numChords; font.pixelSize: 11; font.bold: true; color: "#7070ff" }
                }
                Slider {
                    id: chordsSlider
                    Layout.fillWidth: true
                    from: 4; to: 32; stepSize: 1; value: 8
                    onValueChanged: numChords = value
                }
            }

            // Gravedad
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Gravedad tonal"; font.pixelSize: 11; color: "#9090b0" }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: gravityValue < 0.3 ? "Libre" : (gravityValue > 0.7 ? "Estricto" : "Balanceado")
                        font.pixelSize: 11
                        color: gravityValue < 0.3 ? "#ff7070" : (gravityValue > 0.7 ? "#70ff70" : "#ffff70")
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
                    contentItem: Text { text: parent.text; color: "#f0f0f5"; font.pixelSize: 11; leftPadding: 24 }
                }
                CheckBox {
                    id: cadenceCheck
                    text: "Terminar V-I"
                    checked: true
                    onCheckedChanged: endWithCadence = checked
                    contentItem: Text { text: parent.text; color: "#f0f0f5"; font.pixelSize: 11; leftPadding: 24 }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#2a2a4a" }

            // Patron mano izquierda (v0.2)
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Patron LH"; font.pixelSize: 11; color: "#9090b0" }
                    ComboBox {
                        id: lhPatternCombo
                        Layout.fillWidth: true
                        model: lhPatterns
                        currentIndex: 0
                        onCurrentIndexChanged: selectedLHPattern = currentIndex
                        background: Rectangle { color: "#1a1a2e"; radius: 4 }
                        contentItem: Text { text: lhPatternCombo.currentText; color: "#f0f0f5"; leftPadding: 8; verticalAlignment: Text.AlignVCenter }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Duracion LH"; font.pixelSize: 11; color: "#9090b0" }
                    ComboBox {
                        id: lhDurationCombo
                        Layout.fillWidth: true
                        model: lhDurations
                        currentIndex: 2
                        enabled: selectedLHPattern > 0  // Solo para patrones (no bloque)
                        onCurrentIndexChanged: selectedLHDuration = currentIndex
                        background: Rectangle { color: enabled ? "#1a1a2e" : "#0f0f1a"; radius: 4 }
                        contentItem: Text { text: lhDurationCombo.currentText; color: enabled ? "#f0f0f5" : "#4a4a6a"; leftPadding: 8; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }

            // Info piano
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "#1a1a2e"
                radius: 4

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 20

                    Column {
                        Text { text: "LH (Clave Fa)"; font.pixelSize: 9; color: "#6a6a8a"; horizontalAlignment: Text.AlignHCenter }
                        Text {
                            text: selectedLHPattern === 0 ? "Bass + Tenor" : lhPatterns[selectedLHPattern]
                            font.pixelSize: 10
                            color: selectedLHPattern === 0 ? "#9090b0" : "#7070ff"
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    Rectangle { width: 1; height: 30; color: "#2a2a4a" }

                    Column {
                        Text { text: "RH (Clave Sol)"; font.pixelSize: 9; color: "#6a6a8a"; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "Alto + Soprano"; font.pixelSize: 10; color: "#9090b0"; horizontalAlignment: Text.AlignHCenter }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Preview
            Rectangle {
                Layout.fillWidth: true
                height: 60
                color: "#1a1a2e"
                radius: 4
                Text {
                    id: previewText
                    anchors.centerIn: parent
                    text: "Click Previsualizar"
                    font.pixelSize: 12
                    font.family: "monospace"
                    color: "#6a6a8a"
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
                        previewText.color = "#f0f0f5";
                    }
                    background: Rectangle { color: "#1a1a2e"; radius: 4 }
                    contentItem: Text { text: parent.text; color: "#f0f0f5"; horizontalAlignment: Text.AlignHCenter }
                }

                Button {
                    text: "Generar"
                    Layout.fillWidth: true
                    onClicked: writeToScore()
                    background: Rectangle { color: "#5050ff"; radius: 4 }
                    contentItem: Text { text: parent.text; color: "#ffffff"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                }
            }

            Button {
                text: "Cerrar"
                Layout.fillWidth: true
                onClicked: Qt.quit()
                background: Rectangle { color: "transparent"; border.color: "#2a2a4a"; radius: 4 }
                contentItem: Text { text: parent.text; color: "#6a6a8a"; horizontalAlignment: Text.AlignHCenter }
            }
        }
    }

    // ========== ESCRIBIR EN PARTITURA ==========

    /**
     * Obtiene valores de duracion para setDuration
     */
    function getLHDurationValues() {
        // selectedLHDuration: 0=blanca, 1=negra, 2=corchea
        if (selectedLHDuration === 0) {
            return { num: 1, den: 2 };   // Blanca
        } else if (selectedLHDuration === 1) {
            return { num: 1, den: 4 };   // Negra
        } else {
            return { num: 1, den: 8 };   // Corchea
        }
    }

    /**
     * Escribe LH en bloque (redonda)
     */
    function writeLHBlock(cursor, bass, tenor) {
        cursor.setDuration(1, 1);  // Redonda
        cursor.addNote(bass, false);
        cursor.addNote(tenor, true);
    }

    /**
     * Escribe LH bajo-acorde: bajo solo, luego tenor
     */
    function writeLHBajoAcorde(cursor, bass, tenor, dur) {
        cursor.setDuration(dur.num, dur.den);
        cursor.addNote(bass, false);  // Bajo solo
        cursor.addNote(tenor, false); // Tenor solo
    }

    /**
     * Escribe LH arpegio ascendente
     */
    function writeLHArpeggioUp(cursor, bass, tenor, dur) {
        cursor.setDuration(dur.num, dur.den);
        cursor.addNote(bass, false);
        cursor.addNote(tenor, false);
    }

    /**
     * Escribe LH arpegio descendente
     */
    function writeLHArpeggioDown(cursor, bass, tenor, dur) {
        cursor.setDuration(dur.num, dur.den);
        cursor.addNote(tenor, false);
        cursor.addNote(bass, false);
    }

    /**
     * Escribe LH Alberti bass: bajo-tenor-octava-tenor (o bajo-5ta-8va-5ta)
     */
    function writeLHAlberti(cursor, bass, tenor, dur) {
        // Patron Alberti clasico: 1-5-8-5 o 1-3-5-3
        var fifth = bass + 7;  // Quinta sobre el bajo
        if (fifth > tenor) fifth = tenor;  // Usar tenor si es mas bajo

        cursor.setDuration(dur.num, dur.den);
        cursor.addNote(bass, false);    // 1
        cursor.addNote(fifth, false);   // 5
        cursor.addNote(tenor, false);   // 8 (o 3)
        cursor.addNote(fifth, false);   // 5
    }

    /**
     * Escribe LH Stride: bajo-acorde-octava-acorde
     */
    function writeLHStride(cursor, bass, tenor, dur) {
        var octave = bass + 12;
        if (octave > 60) octave = bass;  // Mantener en rango

        cursor.setDuration(dur.num, dur.den);
        cursor.addNote(bass, false);     // Bajo
        cursor.addNote(tenor, false);    // Acorde (simplificado a tenor)
        cursor.addNote(octave, false);   // Octava
        cursor.addNote(tenor, false);    // Acorde
    }

    function writeToScore() {
        if (!curScore) {
            previewText.text = "Error: No hay partitura abierta";
            previewText.color = "#ff7070";
            return;
        }

        var numStaves = curScore.nstaves;

        if (numStaves < 2) {
            previewText.text = "Error: Se necesita grand staff (2 pentagramas)";
            previewText.color = "#ff7070";
            return;
        }

        var prog = generateProgression();
        var keyPitch = keyPitches[selectedKey] || 0;

        // Reset voicing
        currentVoices = [48, 52, 60, 64];

        curScore.startCmd();

        // Grand staff: pentagrama 1 (RH) = track 0, pentagrama 2 (LH) = track 4

        // Mano derecha (Alto + Soprano) - Pentagrama 1
        var cursorRH = curScore.newCursor();
        cursorRH.track = 0;
        cursorRH.rewind(0);
        cursorRH.setDuration(1, 1);  // RH siempre redondas

        // Mano izquierda (Bass + Tenor) - Pentagrama 2
        var cursorLH = curScore.newCursor();
        cursorLH.track = 4;
        cursorLH.rewind(0);

        var lhDur = getLHDurationValues();

        // Reset para cada pase
        currentVoices = [48, 52, 60, 64];

        for (var i = 0; i < prog.length; i++) {
            var voicing = getPianoVoicing(prog[i], keyPitch);
            var bass = voicing[0];
            var tenor = voicing[1];

            // RH: siempre bloque (Alto + Soprano)
            cursorRH.setDuration(1, 1);
            cursorRH.addNote(voicing[2], false);  // Alto
            cursorRH.addNote(voicing[3], true);   // Soprano (add to chord)

            // LH: segun patron seleccionado
            if (selectedLHPattern === 0) {
                // Bloque
                writeLHBlock(cursorLH, bass, tenor);
            } else if (selectedLHPattern === 1) {
                // Bajo-Acorde
                writeLHBajoAcorde(cursorLH, bass, tenor, lhDur);
            } else if (selectedLHPattern === 2) {
                // Arpegio ascendente
                writeLHArpeggioUp(cursorLH, bass, tenor, lhDur);
            } else if (selectedLHPattern === 3) {
                // Arpegio descendente
                writeLHArpeggioDown(cursorLH, bass, tenor, lhDur);
            } else if (selectedLHPattern === 4) {
                // Alberti
                writeLHAlberti(cursorLH, bass, tenor, lhDur);
            } else if (selectedLHPattern === 5) {
                // Stride
                writeLHStride(cursorLH, bass, tenor, lhDur);
            }
        }

        curScore.endCmd();

        // Mostrar resultado
        var chordNames = [];
        for (var j = 0; j < prog.length; j++) {
            chordNames.push(degreeToChordName(prog[j], selectedKey));
        }
        var patternName = lhPatterns[selectedLHPattern];
        previewText.text = "LH: " + patternName + " | RH: Bloque\n" + chordNames.join(" → ");
        previewText.color = "#70ff70";
    }
}
