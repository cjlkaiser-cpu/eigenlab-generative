/**
 * RameauGuitar.qml - Generador de progresiones para guitarra clasica
 *
 * Genera progresiones armonicas con voicings idiomaticos de guitarra.
 * Un solo pentagrama, maximo 4 notas por acorde.
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
    version: "0.1.0"
    pluginType: "dialog"

    width: 380
    height: 520

    // ========== CONSTANTES GUITARRA ==========

    // Rango de la guitarra clasica (E2 = 40 a B5 = 83, pero usamos rango practico)
    property int guitarMin: 40   // E2 (cuerda 6 al aire)
    property int guitarMax: 72   // C5 (traste 8, cuerda 1)

    // Cuerdas al aire (E2, A2, D3, G3, B3, E4)
    property var openStrings: [40, 45, 50, 55, 59, 64]

    // Maximo span de trastes para acordes comodos (4 trastes)
    property int maxFretSpan: 5  // 5 semitonos = ~4 trastes

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
                        text: "Rango: E2-C5"
                        font.pixelSize: 10
                        color: "#8b7355"
                    }
                    Text {
                        text: "Max 4 notas"
                        font.pixelSize: 10
                        color: "#8b7355"
                    }
                    Text {
                        text: "1 pentagrama"
                        font.pixelSize: 10
                        color: "#8b7355"
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
        cursor.setDuration(1, 1);  // Redonda

        for (var i = 0; i < prog.length; i++) {
            var voicing = getGuitarVoicing(prog[i], keyPitch);

            // Escribir acorde (primera nota sin addToChord, resto con addToChord)
            cursor.addNote(voicing[0], false);

            for (var v = 1; v < voicing.length; v++) {
                cursor.addNote(voicing[v], true);
            }
        }

        curScore.endCmd();

        // Mostrar resultado
        var chordNames = [];
        for (var j = 0; j < prog.length; j++) {
            chordNames.push(degreeToChordName(prog[j], selectedKey));
        }
        previewText.text = chordNames.join(" → ");
        previewText.color = "#81b29a";
    }
}
