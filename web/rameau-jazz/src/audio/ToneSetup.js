/**
 * ToneSetup.js - Configuracion central de Tone.js
 *
 * Maneja el contexto de audio, transport y efectos globales.
 */

import * as Tone from 'tone'

// Estado del audio
let isInitialized = false

/**
 * Inicializa el contexto de audio (requiere interaccion del usuario)
 */
export async function initAudio() {
  if (isInitialized) return true

  try {
    await Tone.start()
    console.log('Audio context started')
    isInitialized = true
    return true
  } catch (err) {
    console.error('Failed to start audio context:', err)
    return false
  }
}

/**
 * Verifica si el audio esta inicializado
 */
export function isAudioReady() {
  return isInitialized && Tone.context.state === 'running'
}

/**
 * Configura el tempo del transport
 * @param {number} bpm - Beats por minuto
 */
export function setTempo(bpm) {
  Tone.Transport.bpm.value = bpm
}

/**
 * Obtiene el tempo actual
 */
export function getTempo() {
  return Tone.Transport.bpm.value
}

/**
 * Configura el swing
 * @param {number} amount - 0 = straight, 1 = full swing
 */
export function setSwing(amount) {
  // Tone.js swing: 0 = straight, 1 = full triplet swing
  Tone.Transport.swing = amount * 0.5 // Scale to reasonable range
  Tone.Transport.swingSubdivision = '8n'
}

/**
 * Inicia el transport
 */
export function startTransport() {
  if (!isInitialized) {
    console.warn('Audio not initialized. Call initAudio() first.')
    return
  }
  Tone.Transport.start()
}

/**
 * Pausa el transport
 */
export function pauseTransport() {
  Tone.Transport.pause()
}

/**
 * Detiene el transport y reinicia posicion
 */
export function stopTransport() {
  Tone.Transport.stop()
  Tone.Transport.position = 0
}

/**
 * Obtiene la posicion actual del transport
 * @returns {{bars: number, beats: number, sixteenths: number}}
 */
export function getPosition() {
  const pos = Tone.Transport.position.toString()
  const parts = pos.split(':')
  return {
    bars: parseInt(parts[0]) || 0,
    beats: parseInt(parts[1]) || 0,
    sixteenths: parseFloat(parts[2]) || 0
  }
}

/**
 * Programa un callback en el transport
 * @param {Function} callback - Funcion a ejecutar
 * @param {string} time - Tiempo en notacion Tone.js (ej: '4n', '0:1:0')
 * @returns {number} ID del evento para cancelar
 */
export function scheduleRepeat(callback, interval = '4n') {
  return Tone.Transport.scheduleRepeat(callback, interval)
}

/**
 * Cancela un evento programado
 * @param {number} eventId - ID del evento
 */
export function cancelScheduled(eventId) {
  Tone.Transport.clear(eventId)
}

/**
 * Crea un canal de efectos maestro
 * @returns {Tone.Channel}
 */
export function createMasterChannel() {
  const channel = new Tone.Channel({
    volume: 0,
    pan: 0
  }).toDestination()

  // Limiter para evitar clipping
  const limiter = new Tone.Limiter(-1)
  channel.connect(limiter)
  limiter.toDestination()

  return channel
}

/**
 * Crea reverb global para ambiente jazz
 * @returns {Tone.Reverb}
 */
export function createReverb() {
  return new Tone.Reverb({
    decay: 2.5,
    wet: 0.25,
    preDelay: 0.01
  }).toDestination()
}

/**
 * Convierte nota MIDI a notacion Tone.js
 * @param {number} midi - Nota MIDI (0-127)
 * @returns {string} Notacion (ej: 'C4', 'F#3')
 */
export function midiToNote(midi) {
  const noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
  const octave = Math.floor(midi / 12) - 1
  const noteIndex = midi % 12
  return `${noteNames[noteIndex]}${octave}`
}

/**
 * Convierte array de notas MIDI a notacion Tone.js
 * @param {number[]} midiNotes - Array de notas MIDI
 * @returns {string[]} Array de notaciones
 */
export function midiArrayToNotes(midiNotes) {
  return midiNotes.map(midiToNote)
}

/**
 * Obtiene la duracion en segundos segun el tempo
 * @param {string} notation - Notacion de duracion ('4n', '8n', etc.)
 * @returns {number} Duracion en segundos
 */
export function getDuration(notation) {
  return Tone.Time(notation).toSeconds()
}

// Exportar Tone para uso directo si es necesario
export { Tone }
