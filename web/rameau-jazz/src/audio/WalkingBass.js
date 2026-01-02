/**
 * WalkingBass.js - Generador de lineas de bajo caminante jazz
 *
 * Genera lineas de bajo siguiendo las reglas clasicas:
 * - Beat 1: Root (fundamental)
 * - Beat 2: Passing tone (escalar, arpegio o cromatico)
 * - Beat 3: Target harmonico (5ta, 3ra)
 * - Beat 4: Approach cromatico hacia siguiente root
 *
 * Incluye tecnicas avanzadas: double chromatic, enclosures, swing triplets
 */

import * as Tone from 'tone'
import { JAZZ_DEGREES } from '../engine/JazzDegrees.js'
import { CHORD_TYPES } from '../engine/ChordTypes.js'

export class WalkingBass {
  constructor() {
    // Sintetizador de bajo (MonoSynth para linea melodica)
    this.synth = new Tone.MonoSynth({
      oscillator: {
        type: 'triangle'
      },
      envelope: {
        attack: 0.02,
        decay: 0.1,
        sustain: 0.4,
        release: 0.3
      },
      filterEnvelope: {
        attack: 0.01,
        decay: 0.2,
        sustain: 0.5,
        release: 0.2,
        baseFrequency: 200,
        octaves: 2.5
      }
    })

    // Efectos de bajo
    this.compressor = new Tone.Compressor({
      threshold: -15,
      ratio: 6,
      attack: 0.01,
      release: 0.1
    })

    this.eq = new Tone.EQ3({
      low: 3,
      mid: 0,
      high: -6,
      lowFrequency: 200,
      highFrequency: 2000
    })

    this.volume = new Tone.Volume(-6)

    // Cadena
    this.synth.chain(
      this.compressor,
      this.eq,
      this.volume,
      Tone.Destination
    )

    // Configuracion
    this.pattern = 'blueNote' // 'blueNote', 'wave', 'scalar', 'chromatic'
    this.probSwingTriplet = 0.25
    this.probDoubleChromatic = 0.20
    this.probEnclosure = 0.15
  }

  /**
   * Genera una linea de bajo para un compas
   * @param {object} currentChord - {degree, key}
   * @param {object} nextChord - {degree, key} (para approach)
   * @returns {Array<{note: string, duration: string, time: string}>}
   */
  generateLine(currentChord, nextChord) {
    const rootPitch = this.getRootPitch(currentChord.degree, currentChord.key)
    const nextRootPitch = nextChord
      ? this.getRootPitch(nextChord.degree, nextChord.key)
      : rootPitch

    const chordType = JAZZ_DEGREES[currentChord.degree]?.type || 'maj7'
    const intervals = CHORD_TYPES[chordType]?.intervals || [0, 4, 7]

    // Generar 4 notas (una por beat)
    const line = []

    // Beat 1: Root
    line.push({
      pitch: rootPitch,
      beat: 0
    })

    // Beat 2: Passing tone
    const beat2 = this.getBeat2(rootPitch, intervals)
    line.push({
      pitch: beat2,
      beat: 1
    })

    // Beat 3: Target (con posible swing triplet)
    const useSwing = Math.random() < this.probSwingTriplet
    const beat3 = this.getBeat3(rootPitch, intervals)
    line.push({
      pitch: beat3,
      beat: 2,
      swing: useSwing
    })

    // Beat 4: Approach
    const beat4 = this.getBeat4(nextRootPitch)
    line.push({
      pitch: beat4,
      beat: 3
    })

    return line
  }

  /**
   * Obtiene la nota para beat 2 (passing tone)
   */
  getBeat2(rootPitch, intervals) {
    const rand = Math.random()

    if (rand < 0.4) {
      // Escalar: 2da o 2da menor
      return rootPitch + (Math.random() < 0.7 ? 2 : 1)
    } else if (rand < 0.7) {
      // Arpegio: 3ra
      const third = intervals.find(i => i === 3 || i === 4) || 4
      return rootPitch + third
    } else {
      // Cromatico
      return rootPitch + 1
    }
  }

  /**
   * Obtiene la nota para beat 3 (target harmonico)
   */
  getBeat3(rootPitch, intervals) {
    const rand = Math.random()

    if (rand < 0.5) {
      // 5ta
      const fifth = intervals.find(i => i === 6 || i === 7 || i === 8) || 7
      return rootPitch + fifth
    } else if (rand < 0.8) {
      // 3ra
      const third = intervals.find(i => i === 3 || i === 4) || 4
      return rootPitch + third
    } else {
      // 7ma (una octava abajo para mantener rango)
      const seventh = intervals.find(i => i >= 9 && i <= 11)
      return seventh ? rootPitch + seventh - 12 : rootPitch + 5
    }
  }

  /**
   * Obtiene la nota para beat 4 (approach)
   */
  getBeat4(nextRootPitch) {
    // Double chromatic approach (20% probabilidad)
    if (Math.random() < this.probDoubleChromatic) {
      // Retornamos nota 2 semitonos antes
      return nextRootPitch + (Math.random() < 0.5 ? 2 : -2)
    }

    // Approach simple: semitono arriba o abajo
    return nextRootPitch + (Math.random() < 0.5 ? 1 : -1)
  }

  /**
   * Calcula el pitch MIDI de la fundamental
   */
  getRootPitch(degree, key) {
    const keyPitches = {
      'C': 0, 'Db': 1, 'D': 2, 'Eb': 3, 'E': 4, 'F': 5,
      'Gb': 6, 'G': 7, 'Ab': 8, 'A': 9, 'Bb': 10, 'B': 11
    }

    const degreeInfo = JAZZ_DEGREES[degree]
    const keyOffset = keyPitches[key] || 0
    const root = degreeInfo?.root || 0

    // Bajo en octava 2 (MIDI 36 = C2)
    return 36 + keyOffset + root
  }

  /**
   * Convierte pitch MIDI a nota Tone.js
   */
  midiToNote(pitch) {
    const noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
    const octave = Math.floor(pitch / 12) - 1
    const noteIndex = pitch % 12
    return `${noteNames[noteIndex]}${octave}`
  }

  /**
   * Toca una nota de bajo
   */
  playNote(note, duration = '4n', time) {
    if (time !== undefined) {
      this.synth.triggerAttackRelease(note, duration, time)
    } else {
      this.synth.triggerAttackRelease(note, duration)
    }
  }

  /**
   * Toca una linea de bajo completa en un compas
   * @param {Array} line - Linea generada por generateLine()
   * @param {number} startTime - Tiempo de inicio del compas
   */
  playLine(line, startTime) {
    const quarterNote = Tone.Time('4n').toSeconds()

    line.forEach((note, i) => {
      const noteTime = startTime + (note.beat * quarterNote)
      const noteName = this.midiToNote(note.pitch)

      if (note.swing && i < line.length - 1) {
        // Swing: dividir en tresillo (2/3 + 1/3)
        const swingLong = quarterNote * 0.67
        const swingShort = quarterNote * 0.33

        this.synth.triggerAttackRelease(noteName, swingLong, noteTime)

        // Ghost note
        const ghostPitch = note.pitch + (Math.random() < 0.5 ? 1 : -1)
        const ghostNote = this.midiToNote(ghostPitch)
        this.synth.triggerAttackRelease(ghostNote, swingShort, noteTime + swingLong, 0.5)
      } else {
        this.synth.triggerAttackRelease(noteName, '4n', noteTime)
      }
    })
  }

  /**
   * Ajusta el volumen
   */
  setVolume(db) {
    this.volume.volume.value = db
  }

  /**
   * Ajusta el volumen normalizado (0-1)
   */
  setVolumeNormalized(value) {
    const db = value === 0 ? -Infinity : (value - 1) * 40 - 6
    this.volume.volume.value = db
  }

  /**
   * Limpia recursos
   */
  dispose() {
    this.synth.dispose()
    this.compressor.dispose()
    this.eq.dispose()
    this.volume.dispose()
  }
}

// Singleton
let instance = null

export function getWalkingBass() {
  if (!instance) {
    instance = new WalkingBass()
  }
  return instance
}

export function disposeWalkingBass() {
  if (instance) {
    instance.dispose()
    instance = null
  }
}
