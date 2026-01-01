/**
 * VoiceLeading.js - Voice Leading SATB
 * Portado de Rameau Machine para MuseScore
 */

// Requiere: Chords.js cargado previamente

// Rangos vocales (MIDI)
var VOICE_RANGES = {
    bass:    { min: 36, max: 60 },   // C2 - C4
    tenor:   { min: 48, max: 67 },   // C3 - G4
    alto:    { min: 55, max: 74 },   // G3 - D5
    soprano: { min: 60, max: 81 }    // C4 - A5
};

// Centros ideales (registro mas resonante)
var VOICE_CENTERS = {
    bass:    48,   // C3
    tenor:   57,   // A3
    alto:    64,   // E4
    soprano: 72    // C5
};

// Reglas de voice leading por estilo
var VOICE_LEADING_RULES = {
    barroco:   { strictParallels: true,  resolveLeadingTone: true,  maxLeap: 8 },
    clasico:   { strictParallels: true,  resolveLeadingTone: true,  maxLeap: 10 },
    romantico: { strictParallels: false, resolveLeadingTone: false, maxLeap: 12 },
    jazz:      { strictParallels: false, resolveLeadingTone: false, maxLeap: 14 }
};

/**
 * Clase VoiceLeader - Gestiona voice leading SATB
 */
function VoiceLeader() {
    // Voicing actual [bass, tenor, alto, soprano]
    this.voices = [48, 52, 55, 60];  // C3, E3, G3, C4 (acorde de C mayor)
    this.style = 'clasico';
    this.centerPenaltyWeight = 0.15;
}

/**
 * Configura el estilo de voice leading
 */
VoiceLeader.prototype.setStyle = function(style) {
    if (VOICE_LEADING_RULES[style]) {
        this.style = style;
    }
};

/**
 * Obtiene el voicing actual
 */
VoiceLeader.prototype.getVoices = function() {
    return this.voices.slice();  // Copia
};

/**
 * Transiciona a un nuevo acorde
 * @param {string} chordName - Nombre del acorde (ej: 'I', 'V', 'vi')
 * @param {string} mode - 'major' o 'minor'
 * @param {number} keyPitch - Transposicion de la tonalidad (0-11)
 * @param {number} inversion - 0 = fundamental, 1 = primera, 2 = segunda
 * @returns {object} - { from: [midi], to: [midi] } o null si falla
 */
VoiceLeader.prototype.transition = function(chordName, mode, keyPitch, inversion) {
    inversion = inversion || 0;
    var chords = getChords(mode);
    var chordData = chords[chordName];

    if (!chordData) return null;

    // Obtener pitch classes del acorde transpuesto
    var pitchClasses = [
        (chordData.root + keyPitch) % 12,
        (chordData.third + keyPitch) % 12,
        (chordData.fifth + keyPitch) % 12
    ];

    // Determinar nota del bajo segun inversion
    var bassPC = pitchClasses[inversion % pitchClasses.length];

    // Encontrar voicing optimo
    var newVoicing = this.findOptimalVoicing(pitchClasses, bassPC);

    if (newVoicing) {
        var oldVoices = this.voices.slice();
        this.voices = newVoicing;
        return { from: oldVoices, to: newVoicing };
    }

    return null;
};

/**
 * Encuentra el voicing optimo minimizando movimiento de voces
 */
VoiceLeader.prototype.findOptimalVoicing = function(pitchClasses, bassNote) {
    var candidates = this.generateVoicings(pitchClasses, bassNote);
    var rules = VOICE_LEADING_RULES[this.style];

    // Filtrar voicings validos
    var valid = candidates;
    if (rules.strictParallels) {
        var self = this;
        valid = candidates.filter(function(v) {
            return self.isValidVoiceLeading(self.voices, v);
        });
    }

    // Si no hay validos, usar todos
    if (valid.length === 0) valid = candidates;
    if (valid.length === 0) return null;

    // Centros para penalizacion
    var centers = [
        VOICE_CENTERS.bass,
        VOICE_CENTERS.tenor,
        VOICE_CENTERS.alto,
        VOICE_CENTERS.soprano
    ];

    var self = this;
    var best = { voicing: null, cost: Infinity };

    for (var i = 0; i < valid.length; i++) {
        var candidate = valid[i];

        // Costo por movimiento de voces
        var movementCost = self.totalVoiceDistance(self.voices, candidate);

        // Costo por alejarse del centro ideal
        var centerCost = 0;
        for (var j = 0; j < candidate.length; j++) {
            centerCost += Math.abs(candidate[j] - centers[j]);
        }

        var totalCost = movementCost + (centerCost * self.centerPenaltyWeight);

        if (totalCost < best.cost) {
            best = { voicing: candidate, cost: totalCost };
        }
    }

    return best.voicing;
};

/**
 * Genera todos los voicings posibles para un acorde
 */
VoiceLeader.prototype.generateVoicings = function(pitchClasses, bassNote) {
    var voicings = [];
    var bassOptions = this.getNotesInRange(bassNote, VOICE_RANGES.bass);

    // Limitar opciones para eficiencia
    var bassSlice = bassOptions.slice(0, 2);

    for (var bi = 0; bi < bassSlice.length; bi++) {
        var b = bassSlice[bi];

        // Notas disponibles para voces superiores
        var remaining = pitchClasses.filter(function(p) { return p !== bassNote % 12; });
        var upperPCs = remaining.concat(pitchClasses);

        var tenorOptions = this.getNotesInRange(upperPCs, VOICE_RANGES.tenor).slice(0, 4);
        var altoOptions = this.getNotesInRange(upperPCs, VOICE_RANGES.alto).slice(0, 4);
        var sopranoOptions = this.getNotesInRange(pitchClasses, VOICE_RANGES.soprano).slice(0, 4);

        for (var ti = 0; ti < tenorOptions.length; ti++) {
            var t = tenorOptions[ti];
            for (var ai = 0; ai < altoOptions.length; ai++) {
                var a = altoOptions[ai];
                for (var si = 0; si < sopranoOptions.length; si++) {
                    var s = sopranoOptions[si];

                    // Verificar orden correcto (sin cruces)
                    if (b < t && t <= a && a <= s) {
                        voicings.push([b, t, a, s]);
                    }
                }
            }
        }
    }

    return voicings;
};

/**
 * Obtiene notas MIDI de una pitch class dentro de un rango
 */
VoiceLeader.prototype.getNotesInRange = function(pitchClassOrArray, range) {
    var pcs = Array.isArray(pitchClassOrArray) ? pitchClassOrArray : [pitchClassOrArray];
    var notes = [];

    for (var i = 0; i < pcs.length; i++) {
        var pc = pcs[i];
        for (var octave = 0; octave < 8; octave++) {
            var note = pc + octave * 12;
            if (note >= range.min && note <= range.max) {
                notes.push(note);
            }
        }
    }

    // Eliminar duplicados y ordenar
    var unique = [];
    for (var j = 0; j < notes.length; j++) {
        if (unique.indexOf(notes[j]) === -1) {
            unique.push(notes[j]);
        }
    }
    unique.sort(function(a, b) { return a - b; });

    return unique;
};

/**
 * Calcula distancia total entre dos voicings
 */
VoiceLeader.prototype.totalVoiceDistance = function(from, to) {
    var sum = 0;
    for (var i = 0; i < from.length; i++) {
        sum += Math.abs(from[i] - to[i]);
    }
    return sum;
};

/**
 * Verifica si un voice leading es valido (sin paralelas prohibidas)
 */
VoiceLeader.prototype.isValidVoiceLeading = function(from, to) {
    // Verificar quintas y octavas paralelas
    for (var i = 0; i < from.length - 1; i++) {
        for (var j = i + 1; j < from.length; j++) {
            var interval1 = Math.abs(from[i] - from[j]) % 12;
            var interval2 = Math.abs(to[i] - to[j]) % 12;

            // Quintas (7 semitonos) u octavas (0 semitonos) paralelas
            if ((interval1 === 7 && interval2 === 7) || (interval1 === 0 && interval2 === 0)) {
                var dir1 = Math.sign(to[i] - from[i]);
                var dir2 = Math.sign(to[j] - from[j]);

                // Movimiento paralelo en la misma direccion
                if (dir1 === dir2 && dir1 !== 0) {
                    return false;
                }
            }
        }
    }

    // Verificar cruce de voces
    if (to[0] >= to[1] || to[1] > to[2] || to[2] > to[3]) {
        return false;
    }

    // Verificar overlapping (voz cruza la posicion anterior de otra)
    for (var k = 0; k < from.length - 1; k++) {
        // Voz inferior sube mas que donde estaba la superior
        if (to[k] > from[k + 1]) return false;
        // Voz superior baja mas que donde estaba la inferior
        if (to[k + 1] < from[k]) return false;
    }

    return true;
};

/**
 * Resetea a un voicing inicial en la tonalidad dada
 */
VoiceLeader.prototype.reset = function(mode, keyPitch) {
    mode = mode || 'major';
    keyPitch = keyPitch || 0;

    // Iniciar con acorde de tonica
    var tonic = getTonic(mode);
    this.transition(tonic, mode, keyPitch, 0);
};
