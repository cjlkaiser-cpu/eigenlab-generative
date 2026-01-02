/**
 * Voicings.js - 5 estilos de voicing para acordes jazz
 *
 * Estilos:
 * - Shell: Root + 3 + 7 (trio, combo)
 * - Drop 2: Root bajado + 3-5-7 (solo piano, guitarra)
 * - Rootless A: 3-5-7-9 (con bajista)
 * - Rootless B: 7-9-3-5 (con bajista)
 * - Block: Acorde completo
 */

import { CHORD_TYPES } from './ChordTypes.js'

/**
 * Genera voicing Shell (Root + 3 + 7)
 * @param {number} rootPitch - Nota fundamental MIDI
 * @param {string} chordType - Tipo de acorde
 * @returns {{left: number[], right: number[]}} Notas para cada mano
 */
export function shellVoicing(rootPitch, chordType) {
  const type = CHORD_TYPES[chordType]
  if (!type) return { left: [rootPitch], right: [rootPitch + 4] }

  const intervals = type.intervals

  // LH: Root (octava grave)
  const bassNote = rootPitch - 12

  // RH: 3ra + 7ma (o lo que tenga el acorde)
  const third = intervals.find(i => i === 3 || i === 4) ?? 4
  const seventh = intervals.find(i => i >= 9 && i <= 11) ?? 10

  return {
    left: [bassNote],
    right: [rootPitch + third, rootPitch + seventh]
  }
}

/**
 * Genera voicing Drop 2
 * Segunda voz desde arriba baja una octava
 * @param {number} rootPitch - Nota fundamental MIDI
 * @param {string} chordType - Tipo de acorde
 * @returns {{left: number[], right: number[]}}
 */
export function drop2Voicing(rootPitch, chordType) {
  const type = CHORD_TYPES[chordType]
  if (!type) return { left: [rootPitch], right: [rootPitch + 4, rootPitch + 7] }

  const intervals = type.intervals.slice(0, 4) // Max 4 notas

  // Voicing cerrado original (root position)
  const closed = intervals.map(i => rootPitch + i)

  // Drop 2: segunda desde arriba baja una octava
  if (closed.length >= 4) {
    const dropped = closed[2] - 12
    return {
      left: [dropped],
      right: [closed[0], closed[1], closed[3]]
    }
  }

  // Si tiene menos de 4 notas
  return {
    left: [rootPitch - 12],
    right: closed.slice(1)
  }
}

/**
 * Genera voicing Rootless A (3-5-7-9)
 * Sin fundamental, comienza en la 3ra
 * @param {number} rootPitch - Nota fundamental MIDI
 * @param {string} chordType - Tipo de acorde
 * @returns {{left: number[], right: number[]}}
 */
export function rootlessA(rootPitch, chordType) {
  const type = CHORD_TYPES[chordType]
  if (!type) return { left: [rootPitch - 12], right: [rootPitch + 4, rootPitch + 7] }

  const intervals = type.intervals

  // Encontrar intervalos
  const third = intervals.find(i => i === 3 || i === 4) ?? 4
  const fifth = intervals.find(i => i === 6 || i === 7 || i === 8) ?? 7
  const seventh = intervals.find(i => i >= 9 && i <= 11) ?? 10
  const ninth = intervals.find(i => i >= 13 && i <= 15) ?? 14

  // LH: Root (para el bajista mentalmente, pero tocamos algo)
  // En realidad Rootless es sin bajo, asi que LH toca parte del voicing
  return {
    left: [rootPitch + third, rootPitch + fifth - 12], // 3 + 5 grave
    right: [rootPitch + seventh, rootPitch + ninth]     // 7 + 9
  }
}

/**
 * Genera voicing Rootless B (7-9-3-5)
 * Sin fundamental, comienza en la 7ma
 * @param {number} rootPitch - Nota fundamental MIDI
 * @param {string} chordType - Tipo de acorde
 * @returns {{left: number[], right: number[]}}
 */
export function rootlessB(rootPitch, chordType) {
  const type = CHORD_TYPES[chordType]
  if (!type) return { left: [rootPitch - 12], right: [rootPitch + 4, rootPitch + 7] }

  const intervals = type.intervals

  // Encontrar intervalos
  const third = intervals.find(i => i === 3 || i === 4) ?? 4
  const fifth = intervals.find(i => i === 6 || i === 7 || i === 8) ?? 7
  const seventh = intervals.find(i => i >= 9 && i <= 11) ?? 10
  const ninth = intervals.find(i => i >= 13 && i <= 15) ?? 14

  // Orden: 7-9-3-5
  return {
    left: [rootPitch + seventh - 12, rootPitch + ninth - 12], // 7 + 9 graves
    right: [rootPitch + third, rootPitch + fifth]              // 3 + 5
  }
}

/**
 * Genera voicing Block (acorde completo)
 * @param {number} rootPitch - Nota fundamental MIDI
 * @param {string} chordType - Tipo de acorde
 * @returns {{left: number[], right: number[]}}
 */
export function blockVoicing(rootPitch, chordType) {
  const type = CHORD_TYPES[chordType]
  if (!type) return { left: [rootPitch - 12], right: [rootPitch, rootPitch + 4, rootPitch + 7] }

  const intervals = type.intervals

  // LH: Root + una nota adicional (5ta o 3ra grave)
  const bassNote = rootPitch - 12
  const fifthOrThird = intervals.find(i => i === 7) ?? intervals.find(i => i === 3 || i === 4) ?? 4

  // RH: Resto del acorde
  const rightNotes = intervals.slice(1).map(i => rootPitch + i)

  return {
    left: [bassNote, bassNote + fifthOrThird],
    right: rightNotes.length > 0 ? rightNotes : [rootPitch + 4, rootPitch + 7]
  }
}

/**
 * Obtiene el voicing segun el estilo seleccionado
 * @param {number} rootPitch - Nota fundamental MIDI
 * @param {string} chordType - Tipo de acorde
 * @param {string} style - Estilo de voicing
 * @returns {{left: number[], right: number[]}}
 */
export function getVoicing(rootPitch, chordType, style = 'shell') {
  switch (style) {
    case 'shell':
      return shellVoicing(rootPitch, chordType)
    case 'drop2':
      return drop2Voicing(rootPitch, chordType)
    case 'rootlessA':
      return rootlessA(rootPitch, chordType)
    case 'rootlessB':
      return rootlessB(rootPitch, chordType)
    case 'block':
      return blockVoicing(rootPitch, chordType)
    default:
      return shellVoicing(rootPitch, chordType)
  }
}

/**
 * Convierte notas MIDI a nombres de notas
 * @param {number} midiNote - Nota MIDI
 * @returns {string} Nombre de la nota (ej: "C4", "F#3")
 */
export function midiToNoteName(midiNote) {
  const noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
  const octave = Math.floor(midiNote / 12) - 1
  const noteIndex = midiNote % 12
  return `${noteNames[noteIndex]}${octave}`
}

/**
 * Convierte notas MIDI a frecuencias (para Tone.js)
 * @param {number} midiNote - Nota MIDI
 * @returns {number} Frecuencia en Hz
 */
export function midiToFrequency(midiNote) {
  return 440 * Math.pow(2, (midiNote - 69) / 12)
}

// Estilos disponibles
export const VOICING_STYLES = [
  { id: 'shell', name: 'Shell', description: 'Root + 3 + 7 (trio)' },
  { id: 'drop2', name: 'Drop 2', description: 'Solo piano, guitarra' },
  { id: 'rootlessA', name: 'Rootless A', description: '3-5-7-9 (con bajista)' },
  { id: 'rootlessB', name: 'Rootless B', description: '7-9-3-5 (con bajista)' },
  { id: 'block', name: 'Block', description: 'Acordes completos' }
]
