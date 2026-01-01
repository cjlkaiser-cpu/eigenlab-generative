/**
 * MarkovEngine.js - Motor de cadenas de Markov con gravedad tonal
 * Portado de Rameau Machine para MuseScore
 */

// Requiere: Chords.js cargado previamente

/**
 * Motor de gravedad tonal
 * Controla la seleccion de acordes segun probabilidades de Markov
 * modificadas por tension armonica
 */
function MarkovEngine() {
    this.position = 'I';
    this.tension = 0;
    this.history = ['I'];
    this.mode = 'major';
    this.keyPitch = 0;
    this.gravity = 0.5;  // 0 = caos, 1 = estricto
}

/**
 * Configura el modo (mayor/menor)
 */
MarkovEngine.prototype.setMode = function(mode) {
    this.mode = mode;
    var tonic = getTonic(mode);
    this.position = tonic;
    this.history = [tonic];
    this.tension = 0;
};

/**
 * Configura la tonalidad
 */
MarkovEngine.prototype.setKey = function(keyName) {
    this.keyPitch = KEY_PITCHES[keyName] || 0;
};

/**
 * Configura el nivel de gravedad (0-1)
 */
MarkovEngine.prototype.setGravity = function(value) {
    this.gravity = Math.max(0, Math.min(1, value));
};

/**
 * Obtiene probabilidades modificadas para el acorde actual
 */
MarkovEngine.prototype.getModifiedProbabilities = function() {
    var chords = getChords(this.mode);
    var transitions = getTransitions(this.mode);
    var base = transitions[this.position];

    if (!base) {
        // Fallback a tonica
        this.position = getTonic(this.mode);
        base = transitions[this.position];
    }

    var strictMatrix = this.mode === 'major' ? STRICT_TRANSITIONS_MAJOR : transitions;
    var strict = strictMatrix[this.position];

    var modified = {};
    var total = 0;
    var UNIFORM_PROB = 1.0 / Object.keys(base).length;

    for (var target in base) {
        var targetData = chords[target];
        var p;

        // Interpolar entre uniforme, base y estricta segun gravedad
        if (this.gravity <= 0.5) {
            // Entre uniforme y base
            var t = this.gravity * 2;
            p = UNIFORM_PROB * (1 - t) + base[target] * t;
        } else {
            // Entre base y estricta
            var t2 = (this.gravity - 0.5) * 2;
            p = base[target] * (1 - t2) + strict[target] * t2;
        }

        // Modificacion por tension
        var tensionEffect = this.gravity;
        if (this.tension > 0.7 && targetData.func === 'T') {
            // Alta tension favorece resolucion a tonica
            p *= (1 + this.tension * tensionEffect);
        } else if (this.tension < 0.3 && targetData.func === 'D') {
            // Baja tension favorece dominante
            p *= (1 + (0.5 - this.tension) * tensionEffect);
        }

        modified[target] = p;
        total += p;
    }

    // Normalizar
    for (var chord in modified) {
        modified[chord] /= total;
    }

    return modified;
};

/**
 * Selecciona el siguiente acorde basado en probabilidades de Markov
 */
MarkovEngine.prototype.selectNextChord = function() {
    var probs = this.getModifiedProbabilities();
    var rand = Math.random();
    var cumulative = 0;

    for (var chord in probs) {
        cumulative += probs[chord];
        if (rand < cumulative) {
            return chord;
        }
    }

    // Fallback
    return getTonic(this.mode);
};

/**
 * Avanza al siguiente acorde y actualiza estado
 */
MarkovEngine.prototype.step = function() {
    var nextChord = this.selectNextChord();
    var chords = getChords(this.mode);

    // Actualizar tension
    var chordData = chords[nextChord];
    if (chordData) {
        this.tension = chordData.tension;
    }

    // Actualizar posicion e historia
    this.position = nextChord;
    this.history.push(nextChord);

    return nextChord;
};

/**
 * Genera una progresion de n acordes
 */
MarkovEngine.prototype.generateProgression = function(numChords, startWithTonic, endWithCadence) {
    var progression = [];

    // Resetear a tonica si se pide
    if (startWithTonic) {
        this.position = getTonic(this.mode);
        this.tension = 0;
    }

    // Generar acordes
    for (var i = 0; i < numChords; i++) {
        // Si es el penultimo y queremos cadencia, forzar V
        if (endWithCadence && i === numChords - 2) {
            this.position = getDominant(this.mode);
            progression.push(this.position);
            this.tension = 0.8;
            continue;
        }

        // Si es el ultimo y queremos cadencia, forzar I
        if (endWithCadence && i === numChords - 1) {
            this.position = getTonic(this.mode);
            progression.push(this.position);
            this.tension = 0;
            continue;
        }

        var chord = this.step();
        progression.push(chord);
    }

    return progression;
};

/**
 * Detecta si hay una cadencia en la historia reciente
 */
MarkovEngine.prototype.detectCadence = function() {
    if (this.history.length < 2) return null;

    var last = this.history[this.history.length - 1];
    var prev = this.history[this.history.length - 2];
    var tonic = getTonic(this.mode);

    // Autentica perfecta: V -> I
    if (prev === 'V' && last === tonic) {
        return 'autentica';
    }

    // Plagal: IV -> I (o iv -> i en menor)
    var subdominant = this.mode === 'minor' ? 'iv' : 'IV';
    if (prev === subdominant && last === tonic) {
        return 'plagal';
    }

    // Rota/Deceptiva: V -> vi (o V -> VI en menor)
    var deceptiveTarget = this.mode === 'minor' ? 'VI' : 'vi';
    if (prev === 'V' && last === deceptiveTarget) {
        return 'rota';
    }

    // Semicadencia: * -> V
    if (last === 'V') {
        return 'semicadencia';
    }

    return null;
};

/**
 * Resetea el motor
 */
MarkovEngine.prototype.reset = function() {
    this.position = getTonic(this.mode);
    this.tension = 0;
    this.history = [this.position];
};
