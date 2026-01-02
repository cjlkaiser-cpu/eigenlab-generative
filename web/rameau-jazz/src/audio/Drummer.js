/**
 * Drummer.js - Bateria jazz basica
 *
 * Patrones de ride cymbal y hi-hat para acompanamiento jazz.
 * Incluye swing feel y variaciones dinamicas.
 */

import * as Tone from 'tone'

export class Drummer {
  constructor() {
    // Ride cymbal (sintetizado)
    this.ride = new Tone.MetalSynth({
      frequency: 300,
      envelope: {
        attack: 0.001,
        decay: 0.4,
        release: 0.2
      },
      harmonicity: 5.1,
      modulationIndex: 32,
      resonance: 4000,
      octaves: 1.5
    })

    // Hi-hat cerrado
    this.hihatClosed = new Tone.NoiseSynth({
      noise: {
        type: 'white'
      },
      envelope: {
        attack: 0.001,
        decay: 0.05,
        sustain: 0,
        release: 0.02
      }
    })

    // Hi-hat abierto
    this.hihatOpen = new Tone.NoiseSynth({
      noise: {
        type: 'white'
      },
      envelope: {
        attack: 0.001,
        decay: 0.3,
        sustain: 0.1,
        release: 0.1
      }
    })

    // Kick suave (jazz)
    this.kick = new Tone.MembraneSynth({
      pitchDecay: 0.05,
      octaves: 4,
      oscillator: {
        type: 'sine'
      },
      envelope: {
        attack: 0.001,
        decay: 0.2,
        sustain: 0,
        release: 0.4
      }
    })

    // Filtros para sonido mas realista
    this.rideFilter = new Tone.Filter({
      type: 'highpass',
      frequency: 3000
    })

    this.hihatFilter = new Tone.Filter({
      type: 'bandpass',
      frequency: 8000,
      Q: 1
    })

    // Volumenes individuales
    this.rideVolume = new Tone.Volume(-12)
    this.hihatVolume = new Tone.Volume(-18)
    this.kickVolume = new Tone.Volume(-15)

    // Volumen master
    this.masterVolume = new Tone.Volume(-6)

    // Conexiones
    this.ride.chain(this.rideFilter, this.rideVolume, this.masterVolume, Tone.Destination)
    this.hihatClosed.chain(this.hihatFilter, this.hihatVolume, this.masterVolume, Tone.Destination)
    this.hihatOpen.chain(this.hihatFilter, this.hihatVolume, this.masterVolume, Tone.Destination)
    this.kick.chain(this.kickVolume, this.masterVolume, Tone.Destination)

    // Configuracion
    this.pattern = 'ride' // 'ride', 'hihat', 'brushes'
    this.swingAmount = 0.3
  }

  /**
   * Patron de ride jazz clasico (spang-a-lang)
   * Beat 1: Ride
   * Beat 2: Ride (skip beat - swing)
   * Beat 2.5: Ride (and)
   * Beat 3: Ride
   * Beat 4: Ride (skip beat - swing)
   * Beat 4.5: Ride (and)
   */
  playRidePattern(startTime) {
    const quarter = Tone.Time('4n').toSeconds()
    const swingOffset = quarter * 0.33 * this.swingAmount

    // Beats principales
    this.ride.triggerAttackRelease('C4', '16n', startTime, 0.8)          // 1
    this.ride.triggerAttackRelease('C4', '16n', startTime + quarter, 0.5) // 2
    this.ride.triggerAttackRelease('C4', '16n', startTime + quarter * 2, 0.8) // 3
    this.ride.triggerAttackRelease('C4', '16n', startTime + quarter * 3, 0.5) // 4

    // Skip beats (swing feel)
    this.ride.triggerAttackRelease('C4', '16n', startTime + quarter * 1.5 + swingOffset, 0.6) // 2-and
    this.ride.triggerAttackRelease('C4', '16n', startTime + quarter * 3.5 + swingOffset, 0.6) // 4-and
  }

  /**
   * Patron de hi-hat jazz
   */
  playHihatPattern(startTime) {
    const quarter = Tone.Time('4n').toSeconds()

    // 2 y 4 con foot hi-hat (cerrado)
    this.hihatClosed.triggerAttackRelease('16n', startTime + quarter, 0.7)     // 2
    this.hihatClosed.triggerAttackRelease('16n', startTime + quarter * 3, 0.7) // 4
  }

  /**
   * Kick suave en 1 (opcional)
   */
  playKick(startTime) {
    this.kick.triggerAttackRelease('C1', '8n', startTime, 0.4)
  }

  /**
   * Toca un compas completo
   */
  playMeasure(startTime, options = {}) {
    const { includeKick = false, hihatOnly = false } = options

    if (hihatOnly) {
      this.playHihatPattern(startTime)
    } else {
      this.playRidePattern(startTime)
      this.playHihatPattern(startTime)
    }

    if (includeKick && Math.random() < 0.3) {
      this.playKick(startTime)
    }
  }

  /**
   * Ajusta el swing
   */
  setSwing(amount) {
    this.swingAmount = Math.max(0, Math.min(1, amount))
  }

  /**
   * Ajusta el volumen master
   */
  setVolume(db) {
    this.masterVolume.volume.value = db
  }

  /**
   * Ajusta el volumen normalizado (0-1)
   */
  setVolumeNormalized(value) {
    const db = value === 0 ? -Infinity : (value - 1) * 40 - 6
    this.masterVolume.volume.value = db
  }

  /**
   * Ajusta volumen individual del ride
   */
  setRideVolume(db) {
    this.rideVolume.volume.value = db
  }

  /**
   * Ajusta volumen individual del hi-hat
   */
  setHihatVolume(db) {
    this.hihatVolume.volume.value = db
  }

  /**
   * Limpia recursos
   */
  dispose() {
    this.ride.dispose()
    this.hihatClosed.dispose()
    this.hihatOpen.dispose()
    this.kick.dispose()
    this.rideFilter.dispose()
    this.hihatFilter.dispose()
    this.rideVolume.dispose()
    this.hihatVolume.dispose()
    this.kickVolume.dispose()
    this.masterVolume.dispose()
  }
}

// Singleton
let instance = null

export function getDrummer() {
  if (!instance) {
    instance = new Drummer()
  }
  return instance
}

export function disposeDrummer() {
  if (instance) {
    instance.dispose()
    instance = null
  }
}
