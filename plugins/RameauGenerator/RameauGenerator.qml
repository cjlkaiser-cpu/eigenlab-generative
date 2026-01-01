/**
 * RameauGenerator.qml - Plugin generativo de progresiones armonicas para MuseScore
 * Version con codigo integrado (sin imports externos)
 */

import MuseScore 3.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

MuseScore {
    id: plugin
    title: "Rameau Generator"
    description: "Genera progresiones armonicas SATB con cadenas de Markov"
    version: "0.2.0"
    pluginType: "dialog"

    width: 380
    height: 500

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

    property var keys: ["C", "G", "D", "A", "E", "B", "F", "Bb", "Eb", "Ab"]

    // Nombres de notas para cifrado americano
    property var noteNames: ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    property var noteNamesFlat: ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]

    // ========== FUNCIONES DE ANÁLISIS ==========

    // Convierte grado a cifrado americano (ej: "V" en G mayor = "D")
    function degreeToChordName(degree, keyName) {
        var chords = getChords();
        var chord = chords[degree];
        if (!chord) return degree;

        var keyPitch = keyPitches[keyName] || 0;
        var rootPitch = (chord.root + keyPitch) % 12;

        // Usar bemoles para tonalidades con bemoles
        var useFlats = ["F", "Bb", "Eb", "Ab", "Db", "Gb"].indexOf(keyName) >= 0;
        var noteName = useFlats ? noteNamesFlat[rootPitch] : noteNames[rootPitch];

        // Añadir calidad del acorde
        var quality = "";
        if (degree.indexOf("o") >= 0) {
            quality = "dim";  // Disminuido
        } else if (degree === degree.toLowerCase() && degree !== "viio" && degree !== "iio") {
            quality = "m";  // Menor
        }
        // Mayor no lleva sufijo

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
        var chords = getChords();
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
            // Forzar V antes del final si queremos cadencia
            if (endWithCadence && i === numChords - 2) {
                currentPosition = "V";
                progression.push("V");
                continue;
            }
            // Forzar I al final si queremos cadencia
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

    // ========== VOICE LEADING ==========

    property var voiceRanges: ({
        bass:    { min: 40, max: 60 },
        tenor:   { min: 48, max: 65 },
        alto:    { min: 55, max: 72 },
        soprano: { min: 60, max: 79 }
    })

    property var currentVoices: [48, 52, 55, 60]  // C3, E3, G3, C4

    function getNotesInRange(pitchClass, range) {
        var notes = [];
        for (var octave = 0; octave < 8; octave++) {
            var note = pitchClass + octave * 12;
            if (note >= range.min && note <= range.max) {
                notes.push(note);
            }
        }
        return notes;
    }

    function findClosestNote(target, options) {
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

    function getVoicing(chordName, keyPitch) {
        var chords = getChords();
        var chord = chords[chordName];
        if (!chord) return currentVoices;

        var root = (chord.root + keyPitch) % 12;
        var third = (chord.third + keyPitch) % 12;
        var fifth = (chord.fifth + keyPitch) % 12;

        // Bass: root
        var bassOptions = getNotesInRange(root, voiceRanges.bass);
        var bass = bassOptions.length > 0 ? findClosestNote(currentVoices[0], bassOptions) : currentVoices[0];

        // Tenor: third or fifth
        var tenorOptions = getNotesInRange(third, voiceRanges.tenor).concat(getNotesInRange(fifth, voiceRanges.tenor));
        var tenor = tenorOptions.length > 0 ? findClosestNote(currentVoices[1], tenorOptions) : currentVoices[1];

        // Alto: fifth or third
        var altoOptions = getNotesInRange(fifth, voiceRanges.alto).concat(getNotesInRange(third, voiceRanges.alto));
        var alto = altoOptions.length > 0 ? findClosestNote(currentVoices[2], altoOptions) : currentVoices[2];

        // Soprano: root (octave) or third
        var sopranoOptions = getNotesInRange(root, voiceRanges.soprano).concat(getNotesInRange(third, voiceRanges.soprano));
        var soprano = sopranoOptions.length > 0 ? findClosestNote(currentVoices[3], sopranoOptions) : currentVoices[3];

        // Asegurar orden correcto
        if (tenor <= bass) tenor = bass + 3;
        if (alto <= tenor) alto = tenor + 3;
        if (soprano <= alto) soprano = alto + 3;

        currentVoices = [bass, tenor, alto, soprano];
        return currentVoices;
    }

    // ========== UI ==========

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                text: "Rameau Generator"
                font.pixelSize: 20
                font.bold: true
                color: "#cdd6f4"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Genera progresiones armonicas SATB"
                font.pixelSize: 12
                color: "#6c7086"
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#313244" }

            // Tonalidad y Modo
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Tonalidad"; font.pixelSize: 11; color: "#a6adc8" }
                    ComboBox {
                        id: keyCombo
                        Layout.fillWidth: true
                        model: keys
                        currentIndex: 0
                        onCurrentTextChanged: selectedKey = currentText
                        background: Rectangle { color: "#313244"; radius: 4 }
                        contentItem: Text { text: keyCombo.currentText; color: "#cdd6f4"; leftPadding: 8; verticalAlignment: Text.AlignVCenter }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Modo"; font.pixelSize: 11; color: "#a6adc8" }
                    ComboBox {
                        id: modeCombo
                        Layout.fillWidth: true
                        model: ["Mayor", "Menor"]
                        currentIndex: 0
                        onCurrentIndexChanged: selectedMode = (currentIndex === 0) ? "major" : "minor"
                        background: Rectangle { color: "#313244"; radius: 4 }
                        contentItem: Text { text: modeCombo.currentText; color: "#cdd6f4"; leftPadding: 8; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }

            // Acordes
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Acordes a generar"; font.pixelSize: 11; color: "#a6adc8" }
                    Item { Layout.fillWidth: true }
                    Text { text: numChords; font.pixelSize: 11; font.bold: true; color: "#89b4fa" }
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
                    Text { text: "Gravedad tonal"; font.pixelSize: 11; color: "#a6adc8" }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: gravityValue < 0.3 ? "Caotico" : (gravityValue > 0.7 ? "Estricto" : "Balanceado")
                        font.pixelSize: 11
                        color: gravityValue < 0.3 ? "#f38ba8" : (gravityValue > 0.7 ? "#a6e3a1" : "#f9e2af")
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
                    contentItem: Text { text: parent.text; color: "#cdd6f4"; font.pixelSize: 11; leftPadding: 24 }
                }
                CheckBox {
                    id: cadenceCheck
                    text: "Terminar V-I"
                    checked: true
                    onCheckedChanged: endWithCadence = checked
                    contentItem: Text { text: parent.text; color: "#cdd6f4"; font.pixelSize: 11; leftPadding: 24 }
                }
            }

            Item { Layout.fillHeight: true }

            // Preview
            Rectangle {
                Layout.fillWidth: true
                height: 50
                color: "#313244"
                radius: 4
                Text {
                    id: previewText
                    anchors.centerIn: parent
                    text: "Click Previsualizar"
                    font.pixelSize: 12
                    font.family: "monospace"
                    color: "#6c7086"
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
                        previewText.text = prog.join(" → ");
                        previewText.color = "#cdd6f4";
                    }
                    background: Rectangle { color: "#313244"; radius: 4 }
                    contentItem: Text { text: parent.text; color: "#cdd6f4"; horizontalAlignment: Text.AlignHCenter }
                }

                Button {
                    text: "Generar"
                    Layout.fillWidth: true
                    onClicked: writeToScore()
                    background: Rectangle { color: "#89b4fa"; radius: 4 }
                    contentItem: Text { text: parent.text; color: "#1e1e2e"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                }
            }

            Button {
                text: "Cerrar"
                Layout.fillWidth: true
                onClicked: Qt.quit()
                background: Rectangle { color: "transparent"; border.color: "#45475a"; radius: 4 }
                contentItem: Text { text: parent.text; color: "#6c7086"; horizontalAlignment: Text.AlignHCenter }
            }
        }
    }

    // ========== ESCRIBIR EN PARTITURA ==========

    function writeToScore() {
        if (!curScore) {
            previewText.text = "Error: No hay partitura";
            previewText.color = "#f38ba8";
            return;
        }

        // Detectar numero de pentagramas
        var numStaves = curScore.nstaves;

        var prog = generateProgression();
        var keyPitch = keyPitches[selectedKey] || 0;

        // Reset voicing
        currentVoices = [48, 52, 55, 60];

        curScore.startCmd();

        if (numStaves >= 4) {
            // MODO SATB: 4 pentagramas separados
            // Tracks: Soprano=0, Alto=4, Tenor=8, Bajo=12
            var tracks = [0, 4, 8, 12];  // S, A, T, B
            var voiceOrder = [3, 2, 1, 0];  // soprano, alto, tenor, bass

            for (var v = 0; v < 4; v++) {
                var cursor = curScore.newCursor();
                cursor.track = tracks[v];
                cursor.rewind(0);
                cursor.setDuration(1, 1);  // Redonda

                // Reset voicing para cada progresion
                currentVoices = [48, 52, 55, 60];

                for (var i = 0; i < prog.length; i++) {
                    var voices = getVoicing(prog[i], keyPitch);
                    var note = voices[voiceOrder[v]];
                    cursor.addNote(note, false);
                }
            }

            // TODO: Añadir análisis armónico cuando se resuelva API MuseScore 4
            // Por ahora mostrar en preview
            var chordNames = [];
            for (var i = 0; i < prog.length; i++) {
                chordNames.push(degreeToChordName(prog[i], selectedKey));
            }

            previewText.text = prog.join("-") + "\n" + chordNames.join("-");
        } else {
            // MODO ACORDES: 1 pentagrama (comportamiento original)
            var cursor = curScore.newCursor();
            cursor.rewind(0);
            cursor.setDuration(1, 1);

            for (var i = 0; i < prog.length; i++) {
                var voices = getVoicing(prog[i], keyPitch);
                cursor.addNote(voices[0], false);  // Bass
                cursor.addNote(voices[1], true);   // Tenor
                cursor.addNote(voices[2], true);   // Alto
                cursor.addNote(voices[3], true);   // Soprano
            }

            previewText.text = "Acordes: " + prog.join(" → ");
        }

        curScore.endCmd();
        previewText.color = "#a6e3a1";
    }
}
