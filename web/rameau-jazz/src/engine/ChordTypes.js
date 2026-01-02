/**
 * ChordTypes.js - Definiciones de intervalos para cada tipo de acorde jazz
 *
 * Cada tipo define:
 * - intervals: Array de semitonos desde la fundamental
 * - symbol: Notacion estandar del acorde
 * - color: Color para visualizacion
 */

export const CHORD_TYPES = {
  // === ACORDES MAYORES ===
  'maj7':     { intervals: [0, 4, 7, 11], symbol: 'maj7', color: '#70ff70' },
  'maj9':     { intervals: [0, 4, 7, 11, 14], symbol: 'maj9', color: '#70ff70' },
  '6':        { intervals: [0, 4, 7, 9], symbol: '6', color: '#70ff70' },
  'maj7#11':  { intervals: [0, 4, 7, 11, 18], symbol: 'maj7#11', color: '#90ff70' },

  // === ACORDES MENORES ===
  'm7':       { intervals: [0, 3, 7, 10], symbol: 'm7', color: '#7070ff' },
  'm9':       { intervals: [0, 3, 7, 10, 14], symbol: 'm9', color: '#7070ff' },
  'm6':       { intervals: [0, 3, 7, 9], symbol: 'm6', color: '#7070ff' },

  // === DOMINANTES ===
  '7':        { intervals: [0, 4, 7, 10], symbol: '7', color: '#ffff70' },
  '9':        { intervals: [0, 4, 7, 10, 14], symbol: '9', color: '#ffff70' },
  '13':       { intervals: [0, 4, 7, 10, 14, 21], symbol: '13', color: '#ffff70' },
  '7b13':     { intervals: [0, 4, 7, 10, 20], symbol: '7b13', color: '#ff9070' },
  '7#11':     { intervals: [0, 4, 7, 10, 18], symbol: '7#11', color: '#ff9070' },
  '7sus4':    { intervals: [0, 5, 7, 10], symbol: '7sus4', color: '#70ffff' },

  // === DOMINANTES ALTERADOS ===
  '7alt':     { intervals: [0, 4, 8, 10, 13], symbol: '7alt', color: '#ff7070' },
  '7b9':      { intervals: [0, 4, 7, 10, 13], symbol: '7b9', color: '#ff7070' },
  '7#9':      { intervals: [0, 4, 7, 10, 15], symbol: '7#9', color: '#ff7070' },
  '7#9#5':    { intervals: [0, 4, 8, 10, 15], symbol: '7#9#5', color: '#ff5050' },

  // === DISMINUIDOS Y SEMIDISMINUIDOS ===
  'm7b5':     { intervals: [0, 3, 6, 10], symbol: 'm7b5', color: '#ff70ff' },
  'dim7':     { intervals: [0, 3, 6, 9], symbol: 'dim7', color: '#ff70ff' },

  // === SUSPENDIDOS ===
  'sus4':     { intervals: [0, 5, 7], symbol: 'sus4', color: '#70ffff' },
  'sus2':     { intervals: [0, 2, 7], symbol: 'sus2', color: '#70ffff' }
}

/**
 * Obtiene las notas MIDI de un acorde dado
 * @param {number} rootPitch - Nota fundamental en MIDI (ej: 60 = C4)
 * @param {string} chordType - Tipo de acorde (ej: 'maj7', 'm7', '7')
 * @returns {number[]} Array de notas MIDI
 */
export function getChordNotes(rootPitch, chordType) {
  const type = CHORD_TYPES[chordType]
  if (!type) {
    console.warn(`Tipo de acorde desconocido: ${chordType}`)
    return [rootPitch]
  }
  return type.intervals.map(interval => rootPitch + interval)
}

/**
 * Obtiene el simbolo de un tipo de acorde
 * @param {string} chordType - Tipo de acorde
 * @returns {string} Simbolo
 */
export function getChordSymbol(chordType) {
  return CHORD_TYPES[chordType]?.symbol || chordType
}

/**
 * Obtiene el color asociado a un tipo de acorde
 * @param {string} chordType - Tipo de acorde
 * @returns {string} Color hex
 */
export function getChordColor(chordType) {
  return CHORD_TYPES[chordType]?.color || '#ffffff'
}
