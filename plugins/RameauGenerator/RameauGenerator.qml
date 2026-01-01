/**
 * RameauGenerator.qml - Plugin generativo de progresiones armonicas para MuseScore
 *
 * Genera progresiones SATB usando cadenas de Markov con gravedad tonal.
 * Basado en el motor de Rameau Machine.
 *
 * Requiere: MuseScore 4.4+
 */

import MuseScore 3.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import "Chords.js" as Chords
import "MarkovEngine.js" as Markov
import "VoiceLeading.js" as Voice

MuseScore {
    id: plugin
    title: "Rameau Generator"
    description: "Genera progresiones armonicas SATB con cadenas de Markov"
    version: "0.1.0"
    pluginType: "dialog"
    categoryCode: "composing-arranging-tools"

    width: 380
    height: 480

    // Estado interno
    property var markovEngine: null
    property var voiceLeader: null

    // Configuracion
    property string selectedKey: "C"
    property string selectedMode: "major"
    property int numChords: 8
    property real gravityValue: 0.5
    property string selectedStyle: "clasico"
    property bool startWithTonic: true
    property bool endWithCadence: true

    // Listas de opciones
    property var keys: ["C", "G", "D", "A", "E", "B", "F", "Bb", "Eb", "Ab"]
    property var modes: ["major", "minor"]
    property var styles: ["barroco", "clasico", "romantico", "jazz"]

    onRun: {
        // Inicializar motores
        markovEngine = new Markov.MarkovEngine();
        voiceLeader = new Voice.VoiceLeader();

        console.log("Rameau Generator iniciado");
    }

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Titulo
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

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#313244"
            }

            // Tonalidad y Modo
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "Tonalidad"
                        font.pixelSize: 11
                        color: "#a6adc8"
                    }

                    ComboBox {
                        id: keyCombo
                        Layout.fillWidth: true
                        model: keys
                        currentIndex: 0
                        onCurrentTextChanged: selectedKey = currentText

                        background: Rectangle {
                            color: "#313244"
                            radius: 4
                        }
                        contentItem: Text {
                            text: keyCombo.currentText
                            color: "#cdd6f4"
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 8
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "Modo"
                        font.pixelSize: 11
                        color: "#a6adc8"
                    }

                    ComboBox {
                        id: modeCombo
                        Layout.fillWidth: true
                        model: ["Mayor", "Menor"]
                        currentIndex: 0
                        onCurrentIndexChanged: selectedMode = (currentIndex === 0) ? "major" : "minor"

                        background: Rectangle {
                            color: "#313244"
                            radius: 4
                        }
                        contentItem: Text {
                            text: modeCombo.currentText
                            color: "#cdd6f4"
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 8
                        }
                    }
                }
            }

            // Numero de acordes
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Acordes a generar"
                        font.pixelSize: 11
                        color: "#a6adc8"
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: numChords
                        font.pixelSize: 11
                        font.bold: true
                        color: "#89b4fa"
                    }
                }

                Slider {
                    id: chordsSlider
                    Layout.fillWidth: true
                    from: 4
                    to: 32
                    stepSize: 1
                    value: 8
                    onValueChanged: numChords = value

                    background: Rectangle {
                        x: chordsSlider.leftPadding
                        y: chordsSlider.topPadding + chordsSlider.availableHeight / 2 - height / 2
                        width: chordsSlider.availableWidth
                        height: 4
                        radius: 2
                        color: "#313244"

                        Rectangle {
                            width: chordsSlider.visualPosition * parent.width
                            height: parent.height
                            color: "#89b4fa"
                            radius: 2
                        }
                    }

                    handle: Rectangle {
                        x: chordsSlider.leftPadding + chordsSlider.visualPosition * (chordsSlider.availableWidth - width)
                        y: chordsSlider.topPadding + chordsSlider.availableHeight / 2 - height / 2
                        width: 16
                        height: 16
                        radius: 8
                        color: chordsSlider.pressed ? "#b4befe" : "#89b4fa"
                    }
                }
            }

            // Gravedad tonal
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Gravedad tonal"
                        font.pixelSize: 11
                        color: "#a6adc8"
                    }

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
                    from: 0
                    to: 1
                    value: 0.5
                    onValueChanged: gravityValue = value

                    background: Rectangle {
                        x: gravitySlider.leftPadding
                        y: gravitySlider.topPadding + gravitySlider.availableHeight / 2 - height / 2
                        width: gravitySlider.availableWidth
                        height: 4
                        radius: 2
                        color: "#313244"

                        Rectangle {
                            width: gravitySlider.visualPosition * parent.width
                            height: parent.height
                            color: "#a6e3a1"
                            radius: 2
                        }
                    }

                    handle: Rectangle {
                        x: gravitySlider.leftPadding + gravitySlider.visualPosition * (gravitySlider.availableWidth - width)
                        y: gravitySlider.topPadding + gravitySlider.availableHeight / 2 - height / 2
                        width: 16
                        height: 16
                        radius: 8
                        color: gravitySlider.pressed ? "#94e2d5" : "#a6e3a1"
                    }
                }
            }

            // Estilo
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Estilo de voice leading"
                    font.pixelSize: 11
                    color: "#a6adc8"
                }

                ComboBox {
                    id: styleCombo
                    Layout.fillWidth: true
                    model: ["Barroco", "Clasico", "Romantico", "Jazz"]
                    currentIndex: 1
                    onCurrentIndexChanged: selectedStyle = styles[currentIndex]

                    background: Rectangle {
                        color: "#313244"
                        radius: 4
                    }
                    contentItem: Text {
                        text: styleCombo.currentText
                        color: "#cdd6f4"
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 8
                    }
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

                    contentItem: Text {
                        text: tonicCheck.text
                        color: "#cdd6f4"
                        font.pixelSize: 11
                        leftPadding: tonicCheck.indicator.width + 6
                        verticalAlignment: Text.AlignVCenter
                    }

                    indicator: Rectangle {
                        width: 16
                        height: 16
                        radius: 3
                        color: tonicCheck.checked ? "#89b4fa" : "#313244"
                        border.color: "#45475a"

                        Text {
                            anchors.centerIn: parent
                            text: tonicCheck.checked ? "✓" : ""
                            color: "#1e1e2e"
                            font.pixelSize: 12
                        }
                    }
                }

                CheckBox {
                    id: cadenceCheck
                    text: "Terminar con cadencia"
                    checked: true
                    onCheckedChanged: endWithCadence = checked

                    contentItem: Text {
                        text: cadenceCheck.text
                        color: "#cdd6f4"
                        font.pixelSize: 11
                        leftPadding: cadenceCheck.indicator.width + 6
                        verticalAlignment: Text.AlignVCenter
                    }

                    indicator: Rectangle {
                        width: 16
                        height: 16
                        radius: 3
                        color: cadenceCheck.checked ? "#89b4fa" : "#313244"
                        border.color: "#45475a"

                        Text {
                            anchors.centerIn: parent
                            text: cadenceCheck.checked ? "✓" : ""
                            color: "#1e1e2e"
                            font.pixelSize: 12
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Preview de progresion
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "#313244"
                radius: 4

                Text {
                    id: previewText
                    anchors.centerIn: parent
                    text: "Progresion aparecera aqui"
                    font.pixelSize: 11
                    font.family: "monospace"
                    color: "#6c7086"
                }
            }

            // Botones
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Button {
                    text: "Previsualizar"
                    Layout.fillWidth: true

                    onClicked: previewProgression()

                    background: Rectangle {
                        color: parent.pressed ? "#45475a" : "#313244"
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#cdd6f4"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    text: "Generar"
                    Layout.fillWidth: true

                    onClicked: generateToScore()

                    background: Rectangle {
                        color: parent.pressed ? "#74c7ec" : "#89b4fa"
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#1e1e2e"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Button {
                text: "Cerrar"
                Layout.fillWidth: true

                onClicked: Qt.quit()

                background: Rectangle {
                    color: parent.pressed ? "#45475a" : "transparent"
                    border.color: "#45475a"
                    radius: 4
                }

                contentItem: Text {
                    text: parent.text
                    color: "#6c7086"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    /**
     * Previsualiza la progresion sin escribir en la partitura
     */
    function previewProgression() {
        // Configurar motores
        markovEngine.setMode(selectedMode);
        markovEngine.setKey(selectedKey);
        markovEngine.setGravity(gravityValue);
        markovEngine.reset();

        // Generar progresion
        var progression = markovEngine.generateProgression(numChords, startWithTonic, endWithCadence);

        // Mostrar en preview
        previewText.text = progression.join(" - ");
        previewText.color = "#cdd6f4";
    }

    /**
     * Genera la progresion y la escribe en la partitura de MuseScore
     */
    function generateToScore() {
        if (!curScore) {
            console.log("Error: No hay partitura abierta");
            return;
        }

        // Configurar motores
        markovEngine.setMode(selectedMode);
        markovEngine.setKey(selectedKey);
        markovEngine.setGravity(gravityValue);
        markovEngine.reset();

        voiceLeader.setStyle(selectedStyle);
        voiceLeader.reset(selectedMode, Chords.KEY_PITCHES[selectedKey]);

        // Generar progresion
        var progression = markovEngine.generateProgression(numChords, startWithTonic, endWithCadence);

        console.log("Progresion generada: " + progression.join(" - "));

        // Escribir en partitura
        curScore.startCmd();

        var cursor = curScore.newCursor();
        cursor.rewind(1);  // Ir a inicio de seleccion

        // Si no hay seleccion, ir al inicio
        if (!cursor.segment) {
            cursor.rewind(0);
        }

        // Configurar duracion (redonda = 1 compas en 4/4)
        cursor.setDuration(1, 1);

        var keyPitch = Chords.KEY_PITCHES[selectedKey] || 0;

        for (var i = 0; i < progression.length; i++) {
            var chord = progression[i];

            // Obtener voicing
            var result = voiceLeader.transition(chord, selectedMode, keyPitch, 0);

            if (result) {
                var voices = result.to;

                // Escribir las 4 voces como acorde
                // Nota: En MuseScore, addNote con segundo param true añade al acorde
                cursor.addNote(voices[0], false);  // Bass (nueva nota)

                // Para un sistema SATB real, necesitariamos escribir en tracks separados
                // Por ahora, escribimos como acorde vertical
                cursor.addNote(voices[1], true);   // Tenor
                cursor.addNote(voices[2], true);   // Alto
                cursor.addNote(voices[3], true);   // Soprano
            }
        }

        curScore.endCmd();

        // Actualizar preview
        previewText.text = "Generado: " + progression.join(" - ");
        previewText.color = "#a6e3a1";

        console.log("Progresion escrita en partitura");
    }
}
