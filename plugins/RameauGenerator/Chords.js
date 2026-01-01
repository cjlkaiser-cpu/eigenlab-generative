/**
 * Chords.js - Definiciones de acordes y matrices de transicion
 * Portado de Rameau Machine para MuseScore
 */

// Pitch classes para transposicion
var KEY_PITCHES = {
    'C': 0, 'C#': 1, 'Db': 1, 'D': 2, 'D#': 3, 'Eb': 3,
    'E': 4, 'F': 5, 'F#': 6, 'Gb': 6, 'G': 7, 'G#': 8,
    'Ab': 8, 'A': 9, 'A#': 10, 'Bb': 10, 'B': 11
};

var NOTE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];

// Acordes en modo mayor (grados relativos a la tonica)
var CHORDS_MAJOR = {
    'I':    { func: 'T', tension: 0.0, root: 0, third: 4, fifth: 7, quality: 'major' },
    'ii':   { func: 'S', tension: 0.5, root: 2, third: 5, fifth: 9, quality: 'minor' },
    'iii':  { func: 'T', tension: 0.3, root: 4, third: 7, fifth: 11, quality: 'minor' },
    'IV':   { func: 'S', tension: 0.4, root: 5, third: 9, fifth: 0, quality: 'major' },
    'V':    { func: 'D', tension: 0.8, root: 7, third: 11, fifth: 2, quality: 'major' },
    'vi':   { func: 'T', tension: 0.2, root: 9, third: 0, fifth: 4, quality: 'minor' },
    'viio': { func: 'D', tension: 0.85, root: 11, third: 2, fifth: 5, quality: 'dim' }
};

// Acordes en modo menor armonico (V siempre mayor para sensible)
var CHORDS_MINOR = {
    'i':    { func: 'T', tension: 0.0, root: 0, third: 3, fifth: 7, quality: 'minor' },
    'iio':  { func: 'S', tension: 0.55, root: 2, third: 5, fifth: 8, quality: 'dim' },
    'III':  { func: 'T', tension: 0.3, root: 3, third: 7, fifth: 10, quality: 'major' },
    'iv':   { func: 'S', tension: 0.45, root: 5, third: 8, fifth: 0, quality: 'minor' },
    'V':    { func: 'D', tension: 0.8, root: 7, third: 11, fifth: 2, quality: 'major' },
    'VI':   { func: 'T', tension: 0.25, root: 8, third: 0, fifth: 3, quality: 'major' },
    'viio': { func: 'D', tension: 0.85, root: 11, third: 2, fifth: 5, quality: 'dim' }
};

// Colores de funcion armonica (para UI)
var FUNCTION_COLORS = {
    'T': '#22c55e',  // Verde - Tonica
    'S': '#3b82f6',  // Azul - Subdominante
    'D': '#ef4444'   // Rojo - Dominante
};

// Matriz de transicion modo mayor (probabilidades empiricas de Bach/Mozart)
var TRANSITIONS_MAJOR = {
    'I':    { 'I': 0.05, 'ii': 0.15, 'iii': 0.05, 'IV': 0.25, 'V': 0.30, 'vi': 0.15, 'viio': 0.05 },
    'ii':   { 'I': 0.05, 'ii': 0.05, 'iii': 0.02, 'IV': 0.08, 'V': 0.60, 'vi': 0.05, 'viio': 0.15 },
    'iii':  { 'I': 0.10, 'ii': 0.05, 'iii': 0.02, 'IV': 0.30, 'V': 0.10, 'vi': 0.40, 'viio': 0.03 },
    'IV':   { 'I': 0.15, 'ii': 0.10, 'iii': 0.02, 'IV': 0.05, 'V': 0.50, 'vi': 0.05, 'viio': 0.13 },
    'V':    { 'I': 0.70, 'ii': 0.02, 'iii': 0.02, 'IV': 0.05, 'V': 0.05, 'vi': 0.14, 'viio': 0.02 },
    'vi':   { 'I': 0.10, 'ii': 0.25, 'iii': 0.05, 'IV': 0.30, 'V': 0.20, 'vi': 0.05, 'viio': 0.05 },
    'viio': { 'I': 0.80, 'ii': 0.02, 'iii': 0.05, 'IV': 0.02, 'V': 0.03, 'vi': 0.05, 'viio': 0.03 }
};

// Matriz de transicion modo menor
var TRANSITIONS_MINOR = {
    'i':    { 'i': 0.05, 'iio': 0.12, 'III': 0.08, 'iv': 0.25, 'V': 0.30, 'VI': 0.15, 'viio': 0.05 },
    'iio':  { 'i': 0.05, 'iio': 0.03, 'III': 0.02, 'iv': 0.10, 'V': 0.60, 'VI': 0.05, 'viio': 0.15 },
    'III':  { 'i': 0.12, 'iio': 0.05, 'III': 0.03, 'iv': 0.25, 'V': 0.10, 'VI': 0.40, 'viio': 0.05 },
    'iv':   { 'i': 0.10, 'iio': 0.08, 'III': 0.02, 'iv': 0.05, 'V': 0.55, 'VI': 0.05, 'viio': 0.15 },
    'V':    { 'i': 0.70, 'iio': 0.02, 'III': 0.02, 'iv': 0.03, 'V': 0.05, 'VI': 0.15, 'viio': 0.03 },
    'VI':   { 'i': 0.10, 'iio': 0.20, 'III': 0.10, 'iv': 0.30, 'V': 0.20, 'VI': 0.05, 'viio': 0.05 },
    'viio': { 'i': 0.80, 'iio': 0.02, 'III': 0.03, 'iv': 0.02, 'V': 0.05, 'VI': 0.05, 'viio': 0.03 }
};

// Matriz estricta (gravedad alta, mas predecible)
var STRICT_TRANSITIONS_MAJOR = {
    'I':    { 'I': 0.02, 'ii': 0.15, 'iii': 0.03, 'IV': 0.35, 'V': 0.35, 'vi': 0.08, 'viio': 0.02 },
    'ii':   { 'I': 0.02, 'ii': 0.02, 'iii': 0.01, 'IV': 0.05, 'V': 0.75, 'vi': 0.03, 'viio': 0.12 },
    'iii':  { 'I': 0.05, 'ii': 0.05, 'iii': 0.02, 'IV': 0.35, 'V': 0.08, 'vi': 0.43, 'viio': 0.02 },
    'IV':   { 'I': 0.10, 'ii': 0.08, 'iii': 0.02, 'IV': 0.02, 'V': 0.65, 'vi': 0.03, 'viio': 0.10 },
    'V':    { 'I': 0.82, 'ii': 0.01, 'iii': 0.01, 'IV': 0.02, 'V': 0.02, 'vi': 0.10, 'viio': 0.02 },
    'vi':   { 'I': 0.05, 'ii': 0.30, 'iii': 0.03, 'IV': 0.40, 'V': 0.15, 'vi': 0.02, 'viio': 0.05 },
    'viio': { 'I': 0.88, 'ii': 0.01, 'iii': 0.03, 'IV': 0.01, 'V': 0.02, 'vi': 0.03, 'viio': 0.02 }
};

// Cadencias
var CADENCES = {
    'autentica':    { pattern: ['V', 'I'], name: 'Autentica Perfecta' },
    'plagal':       { pattern: ['IV', 'I'], name: 'Plagal' },
    'rota':         { pattern: ['V', 'vi'], name: 'Rota (Deceptiva)' },
    'semicadencia': { pattern: ['*', 'V'], name: 'Semicadencia' }
};

// Funciones de utilidad

function getChords(mode) {
    return mode === 'minor' ? CHORDS_MINOR : CHORDS_MAJOR;
}

function getTransitions(mode) {
    return mode === 'minor' ? TRANSITIONS_MINOR : TRANSITIONS_MAJOR;
}

function getTonic(mode) {
    return mode === 'minor' ? 'i' : 'I';
}

function getDominant(mode) {
    return 'V';  // Siempre V en ambos modos
}

function getChordPitchClasses(chordName, mode, keyPitch) {
    var chords = getChords(mode);
    var chord = chords[chordName];
    if (!chord) return null;

    return [
        (chord.root + keyPitch) % 12,
        (chord.third + keyPitch) % 12,
        (chord.fifth + keyPitch) % 12
    ];
}

function midiToNoteName(midi) {
    var pc = midi % 12;
    var octave = Math.floor(midi / 12) - 1;
    return NOTE_NAMES[pc] + octave;
}
