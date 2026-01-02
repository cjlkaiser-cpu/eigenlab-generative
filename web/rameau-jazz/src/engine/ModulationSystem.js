/**
 * ModulationSystem.js - Sistema de modulaciones para jazz
 *
 * Define targets de modulacion y funciones de transposicion.
 * Soporta modulaciones basicas, extendidas y Coltrane changes.
 */

/**
 * Targets de modulacion disponibles
 * - interval: semitonos desde la tonalidad actual
 * - prob: probabilidad relativa
 * - level: 0=basicas, 1=extendidas, 2=coltrane
 */
export const MODULATION_TARGETS = {
  // Nivel 0: Basicas (relaciones diatonicas)
  relative: {
    interval: -3,
    prob: 0.20,
    level: 0,
    name: 'Relativa',
    description: 'Relativa menor/mayor (Am desde C)'
  },
  dominant: {
    interval: 7,
    prob: 0.20,
    level: 0,
    name: 'Dominante',
    description: 'Quinta arriba (G desde C)'
  },
  subdominant: {
    interval: 5,
    prob: 0.15,
    level: 0,
    name: 'Subdominante',
    description: 'Cuarta arriba (F desde C)'
  },

  // Nivel 1: Extendidas (cromaticas)
  chromUp: {
    interval: 1,
    prob: 0.12,
    level: 1,
    name: 'Cromatica +',
    description: 'Semitono arriba (Db desde C)'
  },
  chromDown: {
    interval: -1,
    prob: 0.10,
    level: 1,
    name: 'Cromatica -',
    description: 'Semitono abajo (B desde C)'
  },

  // Nivel 2: Coltrane (terceras mayores)
  maj3Down: {
    interval: -4,
    prob: 0.08,
    level: 2,
    name: 'Coltrane -3M',
    description: '3a mayor abajo (Ab desde C, Giant Steps)'
  },
  maj3Up: {
    interval: 4,
    prob: 0.08,
    level: 2,
    name: 'Coltrane +3M',
    description: '3a mayor arriba (E desde C)'
  },
  min3: {
    interval: 3,
    prob: 0.07,
    level: 2,
    name: 'Tercera menor',
    description: '3a menor arriba (Eb desde C)'
  }
}

/**
 * Nombres de las tonalidades
 */
export const KEY_NAMES = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B']

/**
 * Transpone una tonalidad por un intervalo
 * @param {string} key - Tonalidad original
 * @param {number} interval - Intervalo en semitonos (puede ser negativo)
 * @returns {string} Nueva tonalidad
 */
export function transposeKey(key, interval) {
  const currentIndex = KEY_NAMES.indexOf(key)
  if (currentIndex === -1) return 'C'

  const newIndex = (currentIndex + interval + 12) % 12
  return KEY_NAMES[newIndex]
}

/**
 * Calcula el intervalo entre dos tonalidades
 * @param {string} fromKey - Tonalidad origen
 * @param {string} toKey - Tonalidad destino
 * @returns {number} Intervalo en semitonos
 */
export function getInterval(fromKey, toKey) {
  const fromIndex = KEY_NAMES.indexOf(fromKey)
  const toIndex = KEY_NAMES.indexOf(toKey)

  if (fromIndex === -1 || toIndex === -1) return 0

  let interval = toIndex - fromIndex
  if (interval < -6) interval += 12
  if (interval > 6) interval -= 12

  return interval
}

/**
 * Obtiene targets de modulacion disponibles segun el nivel
 * @param {number} level - Nivel maximo (0, 1, 2)
 * @returns {object} Targets filtrados
 */
export function getAvailableTargets(level = 2) {
  const available = {}

  for (const [key, target] of Object.entries(MODULATION_TARGETS)) {
    if (target.level <= level) {
      available[key] = target
    }
  }

  return available
}

/**
 * Selecciona un target de modulacion aleatorio
 * @param {number} level - Nivel maximo
 * @returns {{name: string, interval: number}}
 */
export function selectRandomTarget(level = 2) {
  const targets = getAvailableTargets(level)
  const entries = Object.entries(targets)

  // Calcular probabilidad total
  const totalProb = entries.reduce((sum, [, t]) => sum + t.prob, 0)

  // Seleccion ponderada
  const rand = Math.random() * totalProb
  let cumulative = 0

  for (const [name, target] of entries) {
    cumulative += target.prob
    if (rand < cumulative) {
      return { name, interval: target.interval }
    }
  }

  // Fallback
  return { name: 'dominant', interval: 7 }
}

/**
 * Detecta si un acorde sugiere modulacion
 * @param {string} degree - Grado del acorde
 * @param {object} degreeInfo - Info del grado (de JazzDegrees)
 * @returns {boolean}
 */
export function suggestsModulation(degree, degreeInfo) {
  if (!degreeInfo) return false

  // Acordes Coltrane siempre sugieren modulacion
  if (degreeInfo.func === 'coltrane') return true

  // Dominantes secundarios pueden sugerir
  if (degreeInfo.func === 'secD') return true

  // bII7 (tritono sub) a veces
  if (degree === 'bII7') return true

  return false
}

/**
 * Obtiene la tonalidad sugerida por un acorde
 * (basado en resolucion natural del dominante)
 * @param {string} degree - Grado del acorde
 * @param {string} currentKey - Tonalidad actual
 * @returns {string|null} Nueva tonalidad sugerida o null
 */
export function getSuggestedKey(degree, currentKey) {
  // Dominantes secundarios resuelven a su target
  const secondaryTargets = {
    'V7/ii': 2,   // Resuelve a ii (D en C → Dm)
    'V7/V': 7,    // Resuelve a V (D en C → G)
    'V7/IV': 5,   // Resuelve a IV (C7 en C → F)
    'V7/vi': 9    // Resuelve a vi (E7 en C → Am)
  }

  if (secondaryTargets[degree] !== undefined) {
    return transposeKey(currentKey, secondaryTargets[degree])
  }

  // Coltrane dominants
  const coltraneTargets = {
    'bIII7': 8,   // Eb7 → Ab
    'bVI7': 1,    // Ab7 → Db
    'VI7': 2      // A7 → D (o Dm)
  }

  if (coltraneTargets[degree] !== undefined) {
    return transposeKey(currentKey, coltraneTargets[degree])
  }

  return null
}

/**
 * Calcula el ciclo de Coltrane desde una tonalidad
 * @param {string} startKey - Tonalidad inicial
 * @returns {string[]} Array de 3 tonalidades (Giant Steps cycle)
 */
export function getColtraneCycle(startKey) {
  return [
    startKey,
    transposeKey(startKey, -4), // 3a mayor abajo
    transposeKey(startKey, -8)  // Otra 3a mayor abajo (= 4a arriba)
  ]
}

/**
 * Niveles de modulacion
 */
export const MODULATION_LEVELS = [
  { id: 0, name: 'Basicas', description: 'Relativa, dominante, subdominante' },
  { id: 1, name: 'Extendidas', description: '+ Cromaticas' },
  { id: 2, name: 'Coltrane', description: '+ Terceras mayores (Giant Steps)' }
]
