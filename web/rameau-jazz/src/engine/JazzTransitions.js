/**
 * JazzTransitions.js - Matriz de transicion de Markov para jazz
 *
 * Define las probabilidades de transicion entre acordes.
 * Basada en ii-V-I con sustituciones y dominantes secundarios.
 */

export const JAZZ_TRANSITIONS = {
  // ========== ACORDES DIATONICOS ==========
  'Imaj7': {
    'IIm7': 0.12, 'IIIm7': 0.04, 'IVmaj7': 0.12, 'V7': 0.06, 'VIm7': 0.12,
    'V7/ii': 0.10, '#Idim7': 0.08, 'V7/vi': 0.06, 'iiø/ii': 0.04, 'V7/IV': 0.03,
    'bVImaj7': 0.05, 'IVm7': 0.04, 'bIII7': 0.05, 'bVI7': 0.04, 'VI7': 0.05
  },
  'Imaj9': {
    'IIm7': 0.12, 'IIIm7': 0.04, 'IVmaj7': 0.12, 'V7': 0.06, 'VIm7': 0.12,
    'V7/ii': 0.10, '#Idim7': 0.08, 'V7/vi': 0.06, 'iiø/ii': 0.04, 'V7/IV': 0.03,
    'bVImaj7': 0.05, 'IVm7': 0.04, 'bIII7': 0.05, 'bVI7': 0.04, 'VI7': 0.05
  },
  'I6': {
    'IIm7': 0.15, 'IVmaj7': 0.15, 'V7': 0.10, 'VIm7': 0.15,
    'V7/ii': 0.12, '#Idim7': 0.10, 'V7/vi': 0.08, 'IVm7': 0.05,
    'bIII7': 0.05, 'VI7': 0.05
  },

  'IIm7': {
    'V7': 0.40, 'bII7': 0.12, 'V7/V': 0.08, '#IVdim7': 0.06, 'VIIm7b5': 0.04, 'IVmaj7': 0.04,
    'V7b13': 0.06, 'V7#11': 0.05, 'V7sus4': 0.05, 'V7#9#5': 0.04, 'IVm7': 0.03, 'bIImaj7': 0.03
  },
  'IIm9': {
    'V7': 0.40, 'V9': 0.15, 'bII7': 0.12, 'V7/V': 0.08, '#IVdim7': 0.06,
    'V7b13': 0.06, 'V7#11': 0.05, 'V7sus4': 0.04, 'V7#9#5': 0.04
  },

  'IIIm7': {
    'IIm7': 0.10, 'IVmaj7': 0.15, 'VIm7': 0.45, 'bIIIdim7': 0.15, 'V7/vi': 0.10, 'VIIm7b5': 0.05
  },

  'IVmaj7': {
    'Imaj7': 0.08, 'IIm7': 0.12, 'IIIm7': 0.06, 'V7': 0.25, '#IVdim7': 0.12, 'VIm7': 0.05, '#IVm7b5': 0.04, 'V7/V': 0.08,
    'IVm7': 0.06, 'IVmaj7#11': 0.05, 'bVImaj7': 0.04, 'V7sus4': 0.05
  },
  'IVmaj9': {
    'Imaj7': 0.08, 'IIm7': 0.12, 'V7': 0.25, '#IVdim7': 0.12, 'VIm7': 0.05, 'V7/V': 0.08,
    'IVm7': 0.08, 'IVmaj7#11': 0.08, 'bVImaj7': 0.06, 'V7sus4': 0.08
  },

  'V7': {
    'Imaj7': 0.55, 'VIm7': 0.20, 'IIm7': 0.05, 'IVmaj7': 0.05, 'bVII7': 0.05, 'V7/ii': 0.05, 'IIIm7': 0.05
  },
  'V9': {
    'Imaj7': 0.50, 'Imaj9': 0.15, 'VIm7': 0.15, 'IIm7': 0.05, 'IVmaj7': 0.05, 'bVII7': 0.05, 'V7/ii': 0.05
  },
  'V13': {
    'Imaj7': 0.45, 'Imaj9': 0.20, 'VIm7': 0.15, 'IIm7': 0.05, 'IVmaj7': 0.05, 'bVII7': 0.05, 'V7/ii': 0.05
  },
  'V7alt': {
    'Imaj7': 0.55, 'Imaj9': 0.15, 'VIm7': 0.15, 'IIm7': 0.05, 'bVImaj7': 0.05, 'IVm7': 0.05
  },

  'VIm7': {
    'Imaj7': 0.08, 'IIm7': 0.30, 'IVmaj7': 0.15, 'V7': 0.15, 'V7/ii': 0.15, 'iiø/ii': 0.10, 'VIIm7b5': 0.07
  },

  'VIIm7b5': {
    'IIIm7': 0.50, 'V7': 0.15, 'Imaj7': 0.10, 'IIm7': 0.10, 'IVmaj7': 0.10, 'VIm7': 0.05
  },

  // ========== SUSTITUTOS TRITONO ==========
  'bII7': {
    'Imaj7': 0.80, 'VIm7': 0.10, 'IIm7': 0.05, 'IVmaj7': 0.05
  },
  'bVII7': {
    'Imaj7': 0.25, 'IVmaj7': 0.40, 'VIm7': 0.25, 'IIm7': 0.10
  },
  '#IVm7b5': {
    'IVmaj7': 0.40, 'V7': 0.40, 'Imaj7': 0.10, '#IVdim7': 0.10
  },

  // ========== DOMINANTES SECUNDARIOS ==========
  'V7/ii': {
    'IIm7': 0.75, 'bII7': 0.10, 'V7': 0.10, 'Imaj7': 0.05
  },
  'V7/V': {
    'V7': 0.75, 'IIm7': 0.10, 'bII7': 0.10, 'Imaj7': 0.05
  },
  'V7/IV': {
    'IVmaj7': 0.75, 'IIm7': 0.10, 'Imaj7': 0.10, 'V7': 0.05
  },
  'V7/vi': {
    'VIm7': 0.75, 'IIm7': 0.10, 'IVmaj7': 0.10, 'V7': 0.05
  },

  // ========== ii RELACIONADOS ==========
  'iiø/ii': {
    'V7/ii': 0.80, 'IIm7': 0.10, 'V7': 0.05, 'Imaj7': 0.05
  },
  'iiø/V': {
    'V7/V': 0.80, 'V7': 0.10, 'IIm7': 0.05, 'Imaj7': 0.05
  },

  // ========== DIMINUIDOS DE PASO ==========
  '#Idim7': {
    'IIm7': 0.85, 'V7/ii': 0.10, 'Imaj7': 0.05
  },
  '#IVdim7': {
    'V7': 0.85, 'IIm7': 0.10, 'Imaj7': 0.05
  },
  'bIIIdim7': {
    'IIm7': 0.85, 'IIIm7': 0.10, 'V7': 0.05
  },

  // ========== BORROWED CHORDS ==========
  'bVImaj7': {
    'V7': 0.35, 'bVII7': 0.25, 'IVm7': 0.20, 'Imaj7': 0.10, 'bIImaj7': 0.10
  },
  'bIIImaj7': {
    'IIm7': 0.30, 'bVImaj7': 0.25, 'IVmaj7': 0.20, 'V7': 0.15, 'Imaj7': 0.10
  },
  'IVm7': {
    'V7': 0.40, 'bVII7': 0.20, 'Imaj7': 0.20, 'bVImaj7': 0.10, 'bII7': 0.10
  },
  'bIImaj7': {
    'V7': 0.50, 'Imaj7': 0.25, 'IIm7': 0.15, 'bII7': 0.10
  },

  // ========== DOMINANTES ALTERADOS ADICIONALES ==========
  'V7b13': {
    'Imaj7': 0.60, 'VIm7': 0.20, 'IVmaj7': 0.10, 'IIm7': 0.10
  },
  'V7#11': {
    'Imaj7': 0.55, 'VIm7': 0.20, 'IVmaj7': 0.15, 'bVII7': 0.10
  },
  'V7sus4': {
    'V7': 0.40, 'Imaj7': 0.35, 'VIm7': 0.15, 'IIm7': 0.10
  },

  // ========== ACORDES SUSPENDIDOS ==========
  'IIsus4': {
    'IIm7': 0.50, 'V7': 0.30, 'Imaj7': 0.10, 'IVmaj7': 0.10
  },
  'Isus2': {
    'Imaj7': 0.50, 'IIm7': 0.20, 'IVmaj7': 0.20, 'V7': 0.10
  },

  // ========== UPPER STRUCTURES ==========
  'V7#9#5': {
    'Imaj7': 0.65, 'VIm7': 0.20, 'bVImaj7': 0.10, 'IVm7': 0.05
  },
  'IVmaj7#11': {
    'V7': 0.40, 'IIm7': 0.25, 'Imaj7': 0.20, '#IVm7b5': 0.15
  },

  // ========== COLTRANE DOMINANTS ==========
  'bIII7': {
    'bVImaj7': 0.45, 'bVI7': 0.30, 'IVm7': 0.15, 'Imaj7': 0.10
  },
  'bVI7': {
    'bIImaj7': 0.40, 'bIII7': 0.25, 'V7': 0.20, 'Imaj7': 0.15
  },
  'VI7': {
    'IIm7': 0.50, 'V7/ii': 0.25, 'bIII7': 0.15, 'Imaj7': 0.10
  }
}

/**
 * Obtiene las probabilidades de transicion desde un grado
 * @param {string} fromDegree - Grado de origen
 * @returns {object} Objeto con probabilidades de transicion
 */
export function getTransitions(fromDegree) {
  return JAZZ_TRANSITIONS[fromDegree] || { 'Imaj7': 1.0 }
}

/**
 * Obtiene todos los posibles siguientes acordes desde un grado
 * @param {string} fromDegree - Grado de origen
 * @returns {string[]} Array de grados posibles
 */
export function getPossibleNextChords(fromDegree) {
  const transitions = JAZZ_TRANSITIONS[fromDegree]
  return transitions ? Object.keys(transitions) : ['Imaj7']
}

/**
 * Obtiene la probabilidad de transicion entre dos grados
 * @param {string} fromDegree - Grado de origen
 * @param {string} toDegree - Grado de destino
 * @returns {number} Probabilidad (0-1)
 */
export function getTransitionProbability(fromDegree, toDegree) {
  const transitions = JAZZ_TRANSITIONS[fromDegree]
  return transitions?.[toDegree] || 0
}
