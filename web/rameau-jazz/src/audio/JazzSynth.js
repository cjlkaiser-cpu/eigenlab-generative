/**
 * JazzSynth.js - Sintetizador estilo Rhodes/EP para acordes jazz
 *
 * Usa FM synthesis para emular el sonido caracteristico del
 * Fender Rhodes con tremolo y reverb.
 */

import * as Tone from 'tone'

export class JazzSynth {
  constructor() {
    // Sintetizador FM polifonico (sonido Rhodes-like)
    this.synth = new Tone.PolySynth(Tone.FMSynth, {
      harmonicity: 3.01,
      modulationIndex: 14,
      oscillator: {
        type: 'sine'
      },
      envelope: {
        attack: 0.01,
        decay: 0.3,
        sustain: 0.2,
        release: 1.2
      },
      modulation: {
        type: 'sine'
      },
      modulationEnvelope: {
        attack: 0.01,
        decay: 0.5,
        sustain: 0.3,
        release: 0.5
      }
    })

    // Efectos
    this.tremolo = new Tone.Tremolo({
      frequency: 4,
      depth: 0.3,
      spread: 180
    }).start()

    this.chorus = new Tone.Chorus({
      frequency: 1.5,
      delayTime: 3.5,
      depth: 0.4,
      wet: 0.3
    }).start()

    this.reverb = new Tone.Reverb({
      decay: 2.5,
      wet: 0.3,
      preDelay: 0.01
    })

    this.compressor = new Tone.Compressor({
      threshold: -20,
      ratio: 4,
      attack: 0.003,
      release: 0.25
    })

    this.volume = new Tone.Volume(0)

    // Cadena de efectos
    this.synth.chain(
      this.tremolo,
      this.chorus,
      this.reverb,
      this.compressor,
      this.volume,
      Tone.Destination
    )

    // Warm up reverb
    this.reverb.generate()
  }

  /**
   * Toca un acorde
   * @param {string[]} notes - Array de notas (ej: ['C4', 'E4', 'G4', 'B4'])
   * @param {string} duration - Duracion (ej: '2n', '4n', '1m')
   * @param {number} time - Tiempo de inicio (opcional, para scheduling)
   */
  playChord(notes, duration = '2n', time) {
    if (time !== undefined) {
      this.synth.triggerAttackRelease(notes, duration, time)
    } else {
      this.synth.triggerAttackRelease(notes, duration)
    }
  }

  /**
   * Toca notas individuales (para arpegios)
   * @param {string} note - Nota individual
   * @param {string} duration - Duracion
   * @param {number} time - Tiempo de inicio
   */
  playNote(note, duration = '8n', time) {
    if (time !== undefined) {
      this.synth.triggerAttackRelease(note, duration, time)
    } else {
      this.synth.triggerAttackRelease(note, duration)
    }
  }

  /**
   * Inicia notas (sustain)
   * @param {string[]} notes - Notas a tocar
   * @param {number} time - Tiempo de inicio
   */
  attack(notes, time) {
    if (time !== undefined) {
      this.synth.triggerAttack(notes, time)
    } else {
      this.synth.triggerAttack(notes)
    }
  }

  /**
   * Suelta notas
   * @param {string[]} notes - Notas a soltar (opcional, suelta todas si no se especifica)
   * @param {number} time - Tiempo de release
   */
  release(notes, time) {
    if (notes) {
      if (time !== undefined) {
        this.synth.triggerRelease(notes, time)
      } else {
        this.synth.triggerRelease(notes)
      }
    } else {
      this.synth.releaseAll()
    }
  }

  /**
   * Ajusta el volumen
   * @param {number} db - Volumen en dB (-60 a 0)
   */
  setVolume(db) {
    this.volume.volume.value = db
  }

  /**
   * Ajusta el volumen normalizado (0-1)
   * @param {number} value - Volumen normalizado
   */
  setVolumeNormalized(value) {
    // Convertir 0-1 a dB (-60 a 0)
    const db = value === 0 ? -Infinity : (value - 1) * 40
    this.volume.volume.value = db
  }

  /**
   * Ajusta la cantidad de tremolo
   * @param {number} depth - 0 a 1
   */
  setTremoloDepth(depth) {
    this.tremolo.depth.value = depth
  }

  /**
   * Ajusta la velocidad del tremolo
   * @param {number} freq - Frecuencia en Hz
   */
  setTremoloFrequency(freq) {
    this.tremolo.frequency.value = freq
  }

  /**
   * Ajusta la cantidad de reverb
   * @param {number} wet - 0 a 1
   */
  setReverbWet(wet) {
    this.reverb.wet.value = wet
  }

  /**
   * Limpia recursos
   */
  dispose() {
    this.synth.dispose()
    this.tremolo.dispose()
    this.chorus.dispose()
    this.reverb.dispose()
    this.compressor.dispose()
    this.volume.dispose()
  }
}

// Singleton para uso simple
let instance = null

export function getJazzSynth() {
  if (!instance) {
    instance = new JazzSynth()
  }
  return instance
}

export function disposeJazzSynth() {
  if (instance) {
    instance.dispose()
    instance = null
  }
}
