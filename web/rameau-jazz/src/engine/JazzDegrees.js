/**
 * JazzDegrees.js - 38 grados de acordes jazz
 *
 * Cada grado define:
 * - type: Tipo de acorde (referencia a ChordTypes)
 * - root: Intervalo desde la tonica (en semitonos)
 * - func: Funcion armonica (T=Tonica, SD=Subdominante, D=Dominante, secD=Dom secundario, etc.)
 * - tension: Nivel de tension 0.0-1.0
 */

export const JAZZ_DEGREES = {
  // ========== ACORDES DIATONICOS ==========
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

  // ========== SUSTITUTOS TRITONO ==========
  'bII7':    { type: '7', root: 1, func: 'D', tension: 0.85 },
  'bVII7':   { type: '7', root: 10, func: 'SD', tension: 0.5 },
  '#IVm7b5': { type: 'm7b5', root: 6, func: 'SD', tension: 0.6 },

  // ========== DOMINANTES SECUNDARIOS ==========
  'V7/ii':   { type: '7', root: 9, func: 'secD', tension: 0.7 },   // A7 en C → Dm
  'V7/V':    { type: '7', root: 2, func: 'secD', tension: 0.7 },   // D7 en C → G
  'V7/IV':   { type: '7', root: 0, func: 'secD', tension: 0.6 },   // C7 en C → F
  'V7/vi':   { type: '7', root: 4, func: 'secD', tension: 0.7 },   // E7 en C → Am

  // ========== ii-V SECUNDARIOS (related ii) ==========
  'iiø/ii':  { type: 'm7b5', root: 4, func: 'secSD', tension: 0.5 },  // Em7b5 → A7 → Dm
  'iiø/V':   { type: 'm7b5', root: 9, func: 'secSD', tension: 0.5 },  // Am7b5 → D7 → G

  // ========== ACORDES DIMINUIDOS DE PASO ==========
  '#Idim7':  { type: 'dim7', root: 1, func: 'pass', tension: 0.6 },   // C#dim7: I → ii
  '#IVdim7': { type: 'dim7', root: 6, func: 'pass', tension: 0.6 },   // F#dim7: IV → V
  'bIIIdim7':{ type: 'dim7', root: 3, func: 'pass', tension: 0.6 },   // Ebdim7: iii → ii

  // ========== BORROWED CHORDS (intercambio modal) ==========
  'bVImaj7': { type: 'maj7', root: 8, func: 'SD', tension: 0.5 },     // Abmaj7 en C (de C menor)
  'bIIImaj7':{ type: 'maj7', root: 3, func: 'T', tension: 0.4 },      // Ebmaj7 en C (de C menor)
  'IVm7':    { type: 'm7', root: 5, func: 'SD', tension: 0.5 },       // Fm7 en C (subdominante menor)
  'bIImaj7': { type: 'maj7', root: 1, func: 'SD', tension: 0.7 },     // Dbmaj7 (Napolitana)

  // ========== DOMINANTES ALTERADOS ADICIONALES ==========
  'V7b13':   { type: '7b13', root: 7, func: 'D', tension: 0.85 },     // G7b13
  'V7#11':   { type: '7#11', root: 7, func: 'D', tension: 0.8 },      // G7#11 (Lydian dominant)
  'V7sus4':  { type: '7sus4', root: 7, func: 'D', tension: 0.6 },     // G7sus4

  // ========== ACORDES SUSPENDIDOS ==========
  'IIsus4':  { type: 'sus4', root: 2, func: 'SD', tension: 0.3 },     // Dsus4
  'Isus2':   { type: 'sus2', root: 0, func: 'T', tension: 0.1 },      // Csus2

  // ========== UPPER STRUCTURES ==========
  'V7#9#5':  { type: '7#9#5', root: 7, func: 'D', tension: 0.95 },    // G7#9#5 (Hendrix)
  'IVmaj7#11':{ type: 'maj7#11', root: 5, func: 'SD', tension: 0.5 }, // Fmaj7#11 (Lydian IV)

  // ========== COLTRANE DOMINANTS (Giant Steps) ==========
  'bIII7':   { type: '7', root: 3, func: 'coltrane', tension: 0.75 }, // Eb7 en C → Ab
  'bVI7':    { type: '7', root: 8, func: 'coltrane', tension: 0.75 }, // Ab7 en C → Db
  'VI7':     { type: '7', root: 9, func: 'coltrane', tension: 0.7 }   // A7 en C → D (= V7/ii pero coltrane)
}

// Funciones armonicas
export const HARMONIC_FUNCTIONS = {
  'T': { name: 'Tonica', color: '#3fb950', stable: true },
  'SD': { name: 'Subdominante', color: '#d29922', stable: false },
  'D': { name: 'Dominante', color: '#f85149', stable: false },
  'secD': { name: 'Dominante secundario', color: '#ff7070', stable: false },
  'secSD': { name: 'Subdominante secundario', color: '#ffaa70', stable: false },
  'pass': { name: 'Paso', color: '#a371f7', stable: false },
  'coltrane': { name: 'Coltrane', color: '#58a6ff', stable: false }
}

/**
 * Obtiene la informacion de un grado
 * @param {string} degree - Nombre del grado (ej: 'IIm7', 'V7')
 * @returns {object|null} Informacion del grado o null si no existe
 */
export function getDegree(degree) {
  return JAZZ_DEGREES[degree] || null
}

/**
 * Obtiene la nota fundamental de un grado en una tonalidad
 * @param {string} degree - Nombre del grado
 * @param {string} key - Tonalidad (ej: 'C', 'G', 'F')
 * @returns {number} Nota MIDI de la fundamental
 */
export function getRootPitch(degree, key) {
  const degreeInfo = JAZZ_DEGREES[degree]
  if (!degreeInfo) return 60 // C4 por defecto

  const keyPitches = {
    'C': 0, 'Db': 1, 'D': 2, 'Eb': 3, 'E': 4, 'F': 5,
    'Gb': 6, 'G': 7, 'Ab': 8, 'A': 9, 'Bb': 10, 'B': 11
  }

  const keyOffset = keyPitches[key] || 0
  return 48 + keyOffset + degreeInfo.root // C3 + offset
}

/**
 * Obtiene el color de un grado segun su funcion armonica
 * @param {string} degree - Nombre del grado
 * @returns {string} Color hex
 */
export function getDegreeColor(degree) {
  const degreeInfo = JAZZ_DEGREES[degree]
  if (!degreeInfo) return '#ffffff'

  const funcInfo = HARMONIC_FUNCTIONS[degreeInfo.func]
  return funcInfo?.color || '#ffffff'
}

/**
 * Lista de todos los grados disponibles
 */
export const ALL_DEGREES = Object.keys(JAZZ_DEGREES)

/**
 * Filtra grados por funcion armonica
 * @param {string} func - Funcion ('T', 'SD', 'D', etc.)
 * @returns {string[]} Array de nombres de grados
 */
export function getDegreesByFunction(func) {
  return ALL_DEGREES.filter(d => JAZZ_DEGREES[d].func === func)
}
