/**
 * MarkovEngine.js - Motor de generacion de progresiones con cadenas de Markov
 *
 * Genera progresiones armonicas jazz basadas en probabilidades de transicion,
 * con soporte para modulaciones y configuracion de gravedad tonal.
 */

import { JAZZ_DEGREES } from './JazzDegrees.js'
import { JAZZ_TRANSITIONS } from './JazzTransitions.js'

// Configuracion por defecto
const DEFAULT_CONFIG = {
  gravity: 0.5,              // 0 = caos, 1 = estricto
  modulationEnabled: true,
  modulationProbability: 0.15,
  modulationLevel: 2,        // 0 = basicas, 1 = extendidas, 2 = coltrane
  returnToTonic: true,
  forceCadence: true
}

// Targets de modulacion
const MODULATION_TARGETS = {
  'relative':    { interval: -3, prob: 0.20, level: 0 },  // Am desde C
  'dominant':    { interval: 7,  prob: 0.20, level: 0 },  // G desde C
  'subdominant': { interval: 5,  prob: 0.15, level: 0 },  // F desde C
  'chromUp':     { interval: 1,  prob: 0.12, level: 1 },  // Db desde C
  'chromDown':   { interval: -1, prob: 0.10, level: 1 },  // B desde C
  'maj3Down':    { interval: -4, prob: 0.08, level: 2 },  // Ab desde C (Coltrane)
  'maj3Up':      { interval: 4,  prob: 0.08, level: 2 },  // E desde C (Coltrane)
  'min3':        { interval: 3,  prob: 0.07, level: 2 }   // Eb desde C
}

/**
 * Motor de Markov para generacion de progresiones jazz
 */
export class MarkovEngine {
  constructor(config = {}) {
    this.config = { ...DEFAULT_CONFIG, ...config }
    this.currentKey = 'C'
    this.currentChord = 'Imaj7'
    this.progression = []
    this.modulationCount = 0
  }

  /**
   * Configura el motor
   * @param {object} config - Configuracion parcial
   */
  configure(config) {
    this.config = { ...this.config, ...config }
  }

  /**
   * Reinicia el motor
   * @param {string} key - Tonalidad inicial
   */
  reset(key = 'C') {
    this.currentKey = key
    this.currentChord = 'Imaj7'
    this.progression = []
    this.modulationCount = 0
  }

  /**
   * Genera una progresion completa
   * @param {number} numChords - Numero de acordes a generar
   * @param {string} startKey - Tonalidad inicial
   * @returns {Array<{degree: string, key: string, tension: number}>}
   */
  generateProgression(numChords = 8, startKey = 'C') {
    this.reset(startKey)

    // Primer acorde: siempre Imaj7
    this.progression.push({
      degree: 'Imaj7',
      key: this.currentKey,
      tension: 0
    })

    // Generar resto de acordes
    for (let i = 1; i < numChords; i++) {
      const isLastChord = i === numChords - 1
      const isSecondToLast = i === numChords - 2

      // Forzar cadencia al final
      if (this.config.forceCadence) {
        if (isSecondToLast) {
          // Penultimo: dominante
          if (this.config.returnToTonic && this.currentKey !== startKey) {
            // Modular de vuelta a la tonica original
            this.currentKey = startKey
          }
          this.currentChord = 'V7'
          this.progression.push({
            degree: 'V7',
            key: this.currentKey,
            tension: JAZZ_DEGREES['V7'].tension
          })
          continue
        }
        if (isLastChord) {
          // Ultimo: tonica
          if (this.config.returnToTonic) {
            this.currentKey = startKey
          }
          this.currentChord = 'Imaj7'
          this.progression.push({
            degree: 'Imaj7',
            key: this.currentKey,
            tension: 0
          })
          continue
        }
      }

      // Seleccionar siguiente acorde
      const nextChord = this.selectNextChord()

      // Verificar modulacion
      if (this.shouldModulate(nextChord)) {
        const interval = this.selectModulationTarget()
        this.currentKey = this.transposeKey(this.currentKey, interval)
        this.modulationCount++
        this.currentChord = 'Imaj7' // Empezar en tonica de nueva tonalidad
      } else {
        this.currentChord = nextChord
      }

      this.progression.push({
        degree: this.currentChord,
        key: this.currentKey,
        tension: JAZZ_DEGREES[this.currentChord]?.tension || 0.5
      })
    }

    return this.progression
  }

  /**
   * Selecciona el siguiente acorde basado en probabilidades
   * @returns {string} Nombre del siguiente grado
   */
  selectNextChord() {
    const transitions = JAZZ_TRANSITIONS[this.currentChord]
    if (!transitions) return 'Imaj7'

    // Aplicar gravedad: modificar probabilidades
    const modifiedProbs = this.applyGravity(transitions)

    // Seleccion aleatoria ponderada
    const rand = Math.random()
    let cumulative = 0

    for (const [chord, prob] of Object.entries(modifiedProbs)) {
      cumulative += prob
      if (rand < cumulative) {
        return chord
      }
    }

    return 'Imaj7' // Fallback
  }

  /**
   * Aplica gravedad tonal a las probabilidades
   * @param {object} transitions - Probabilidades originales
   * @returns {object} Probabilidades modificadas
   */
  applyGravity(transitions) {
    const gravity = this.config.gravity
    const modified = {}
    let total = 0

    for (const [chord, prob] of Object.entries(transitions)) {
      const degreeInfo = JAZZ_DEGREES[chord]
      if (!degreeInfo) continue

      // Gravedad alta: favorece acordes estables (menor tension)
      // Gravedad baja: favorece acordes tensos
      const tensionFactor = gravity > 0.5
        ? 1 - degreeInfo.tension * (gravity - 0.5) * 2
        : 1 + degreeInfo.tension * (0.5 - gravity) * 2

      modified[chord] = prob * Math.max(0.1, tensionFactor)
      total += modified[chord]
    }

    // Normalizar
    for (const chord of Object.keys(modified)) {
      modified[chord] /= total
    }

    return modified
  }

  /**
   * Determina si deberia modular
   * @param {string} chord - Acorde actual
   * @returns {boolean}
   */
  shouldModulate(chord) {
    if (!this.config.modulationEnabled) return false
    if (this.progression.length < 2) return false // No modular muy pronto

    const degreeInfo = JAZZ_DEGREES[chord]
    if (!degreeInfo) return false

    // Acordes Coltrane siempre intentan modular
    if (degreeInfo.func === 'coltrane') {
      return Math.random() < 0.7
    }

    // Dominantes secundarios pueden disparar modulacion
    if (degreeInfo.func === 'secD') {
      return Math.random() < this.config.modulationProbability * 1.5
    }

    // Probabilidad base
    return Math.random() < this.config.modulationProbability
  }

  /**
   * Selecciona el intervalo de modulacion
   * @returns {number} Intervalo en semitonos
   */
  selectModulationTarget() {
    const level = this.config.modulationLevel
    const availableTargets = Object.entries(MODULATION_TARGETS)
      .filter(([, info]) => info.level <= level)

    // Normalizar probabilidades
    const total = availableTargets.reduce((sum, [, info]) => sum + info.prob, 0)

    const rand = Math.random() * total
    let cumulative = 0

    for (const [, info] of availableTargets) {
      cumulative += info.prob
      if (rand < cumulative) {
        return info.interval
      }
    }

    return 7 // Dominante por defecto
  }

  /**
   * Transpone una tonalidad por un intervalo
   * @param {string} key - Tonalidad original
   * @param {number} interval - Intervalo en semitonos
   * @returns {string} Nueva tonalidad
   */
  transposeKey(key, interval) {
    const keys = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B']
    const currentIndex = keys.indexOf(key)
    if (currentIndex === -1) return 'C'

    const newIndex = (currentIndex + interval + 12) % 12
    return keys[newIndex]
  }

  /**
   * Avanza un paso (para modo interactivo)
   * @returns {{degree: string, key: string, tension: number}}
   */
  step() {
    const nextChord = this.selectNextChord()

    if (this.shouldModulate(nextChord)) {
      const interval = this.selectModulationTarget()
      this.currentKey = this.transposeKey(this.currentKey, interval)
      this.modulationCount++
      this.currentChord = 'Imaj7'
    } else {
      this.currentChord = nextChord
    }

    const result = {
      degree: this.currentChord,
      key: this.currentKey,
      tension: JAZZ_DEGREES[this.currentChord]?.tension || 0.5
    }

    this.progression.push(result)
    return result
  }

  /**
   * Obtiene la progresion actual
   * @returns {Array}
   */
  getProgression() {
    return this.progression
  }

  /**
   * Obtiene el estado actual del motor
   * @returns {object}
   */
  getState() {
    return {
      currentKey: this.currentKey,
      currentChord: this.currentChord,
      modulationCount: this.modulationCount,
      progressionLength: this.progression.length
    }
  }
}

// Exportar instancia singleton para uso simple
export const markovEngine = new MarkovEngine()
