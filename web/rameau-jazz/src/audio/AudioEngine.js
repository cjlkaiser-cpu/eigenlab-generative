/**
 * AudioEngine.js - Orquestador principal de audio
 *
 * Coordina JazzSynth, WalkingBass y Drummer con el Transport de Tone.js.
 * Reproduce progresiones completas sincronizadas.
 */

import * as Tone from 'tone'
import { JazzSynth, getJazzSynth, disposeJazzSynth } from './JazzSynth.js'
import { WalkingBass, getWalkingBass, disposeWalkingBass } from './WalkingBass.js'
import { Drummer, getDrummer, disposeDrummer } from './Drummer.js'
import { initAudio, setTempo, setSwing, midiToNote, midiArrayToNotes } from './ToneSetup.js'
import { JAZZ_DEGREES } from '../engine/JazzDegrees.js'
import { CHORD_TYPES } from '../engine/ChordTypes.js'
import { getVoicing } from '../engine/Voicings.js'

export class AudioEngine {
  constructor() {
    this.piano = null
    this.bass = null
    this.drums = null

    this.isInitialized = false
    this.isPlaying = false
    this.scheduledEvents = []

    this.progression = []
    this.currentMeasure = 0
    this.loopEnabled = true

    // Configuracion
    this.config = {
      tempo: 120,
      swing: 0.3,
      voicingStyle: 'shell',
      bassEnabled: true,
      drumsEnabled: true,
      pianoVolume: 0.8,
      bassVolume: 0.7,
      drumsVolume: 0.5
    }

    // Callback para actualizar UI
    this.onBeatCallback = null
    this.onMeasureCallback = null
  }

  /**
   * Inicializa el engine (requiere click del usuario)
   */
  async init() {
    if (this.isInitialized) return true

    const audioStarted = await initAudio()
    if (!audioStarted) return false

    // Crear instrumentos
    this.piano = getJazzSynth()
    this.bass = getWalkingBass()
    this.drums = getDrummer()

    // Aplicar configuracion inicial
    this.applyConfig()

    this.isInitialized = true
    console.log('AudioEngine initialized')
    return true
  }

  /**
   * Aplica la configuracion actual a los instrumentos
   */
  applyConfig() {
    setTempo(this.config.tempo)
    setSwing(this.config.swing)

    if (this.piano) {
      this.piano.setVolumeNormalized(this.config.pianoVolume)
    }
    if (this.bass) {
      this.bass.setVolumeNormalized(this.config.bassVolume)
    }
    if (this.drums) {
      this.drums.setVolumeNormalized(this.config.drumsVolume)
      this.drums.setSwing(this.config.swing)
    }
  }

  /**
   * Configura el engine
   */
  configure(config) {
    this.config = { ...this.config, ...config }
    if (this.isInitialized) {
      this.applyConfig()
    }
  }

  /**
   * Carga una progresion para reproducir
   * @param {Array<{degree: string, key: string}>} progression
   */
  loadProgression(progression) {
    this.progression = progression
    this.currentMeasure = 0
  }

  /**
   * Inicia reproduccion
   */
  play() {
    if (!this.isInitialized) {
      console.warn('AudioEngine not initialized')
      return
    }

    if (this.progression.length === 0) {
      console.warn('No progression loaded')
      return
    }

    // Limpiar eventos anteriores
    this.clearScheduledEvents()

    // Programar la progresion
    this.scheduleProgression()

    // Iniciar transport
    Tone.Transport.start()
    this.isPlaying = true
  }

  /**
   * Pausa reproduccion
   */
  pause() {
    Tone.Transport.pause()
    this.isPlaying = false
  }

  /**
   * Detiene reproduccion
   */
  stop() {
    Tone.Transport.stop()
    Tone.Transport.position = 0
    this.isPlaying = false
    this.currentMeasure = 0
    this.clearScheduledEvents()

    // Soltar notas
    if (this.piano) {
      this.piano.release()
    }
  }

  /**
   * Programa la progresion completa
   */
  scheduleProgression() {
    const measureDuration = Tone.Time('1m').toSeconds()

    this.progression.forEach((chord, measureIndex) => {
      const startTime = measureIndex * measureDuration

      // Programar cada compas
      const eventId = Tone.Transport.schedule((time) => {
        this.playMeasure(chord, measureIndex, time)
      }, startTime)

      this.scheduledEvents.push(eventId)
    })

    // Si loop esta habilitado, programar repeat
    if (this.loopEnabled) {
      const totalDuration = this.progression.length * measureDuration
      Tone.Transport.loopEnd = totalDuration
      Tone.Transport.loop = true
    }

    // Programar beat callback
    if (this.onBeatCallback) {
      const beatEventId = Tone.Transport.scheduleRepeat((time) => {
        Tone.Draw.schedule(() => {
          this.onBeatCallback(this.getBeatInfo())
        }, time)
      }, '4n')
      this.scheduledEvents.push(beatEventId)
    }
  }

  /**
   * Reproduce un compas
   */
  playMeasure(chord, measureIndex, time) {
    this.currentMeasure = measureIndex

    // Obtener info del acorde
    const degreeInfo = JAZZ_DEGREES[chord.degree]
    if (!degreeInfo) return

    const rootPitch = this.getRootPitch(chord.degree, chord.key)
    const chordType = degreeInfo.type

    // Piano: voicing
    this.playPianoChord(rootPitch, chordType, time)

    // Bass: walking line
    if (this.config.bassEnabled) {
      const nextChord = this.progression[(measureIndex + 1) % this.progression.length]
      this.playBassLine(chord, nextChord, time)
    }

    // Drums
    if (this.config.drumsEnabled) {
      this.drums.playMeasure(time, { includeKick: measureIndex === 0 })
    }

    // Callback para UI
    if (this.onMeasureCallback) {
      Tone.Draw.schedule(() => {
        this.onMeasureCallback(measureIndex, chord)
      }, time)
    }
  }

  /**
   * Toca el acorde de piano con el voicing seleccionado
   */
  playPianoChord(rootPitch, chordType, time) {
    const voicing = getVoicing(rootPitch, chordType, this.config.voicingStyle)

    // Combinar mano izquierda y derecha
    const allNotes = [...voicing.left, ...voicing.right]
    const noteNames = midiArrayToNotes(allNotes)

    // Duracion: casi todo el compas
    this.piano.playChord(noteNames, '2n.', time)
  }

  /**
   * Toca la linea de bajo
   */
  playBassLine(currentChord, nextChord, time) {
    const line = this.bass.generateLine(currentChord, nextChord)
    this.bass.playLine(line, time)
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

    // Piano en octava 3-4 (MIDI 48 = C3)
    return 48 + keyOffset + root
  }

  /**
   * Obtiene info del beat actual
   */
  getBeatInfo() {
    const pos = Tone.Transport.position.toString().split(':')
    return {
      measure: parseInt(pos[0]) % this.progression.length,
      beat: parseInt(pos[1]),
      sixteenths: parseFloat(pos[2])
    }
  }

  /**
   * Limpia eventos programados
   */
  clearScheduledEvents() {
    this.scheduledEvents.forEach(id => {
      Tone.Transport.clear(id)
    })
    this.scheduledEvents = []
  }

  /**
   * Setters para volumenes
   */
  setPianoVolume(value) {
    this.config.pianoVolume = value
    if (this.piano) {
      this.piano.setVolumeNormalized(value)
    }
  }

  setBassVolume(value) {
    this.config.bassVolume = value
    if (this.bass) {
      this.bass.setVolumeNormalized(value)
    }
  }

  setDrumsVolume(value) {
    this.config.drumsVolume = value
    if (this.drums) {
      this.drums.setVolumeNormalized(value)
    }
  }

  setTempo(bpm) {
    this.config.tempo = bpm
    setTempo(bpm)
  }

  setSwing(amount) {
    this.config.swing = amount
    setSwing(amount)
    if (this.drums) {
      this.drums.setSwing(amount)
    }
  }

  setVoicingStyle(style) {
    this.config.voicingStyle = style
  }

  setBassEnabled(enabled) {
    this.config.bassEnabled = enabled
  }

  setDrumsEnabled(enabled) {
    this.config.drumsEnabled = enabled
  }

  /**
   * Registra callback para beats
   */
  onBeat(callback) {
    this.onBeatCallback = callback
  }

  /**
   * Registra callback para cambio de compas
   */
  onMeasure(callback) {
    this.onMeasureCallback = callback
  }

  /**
   * Toca un acorde inmediatamente (preview)
   */
  async previewChord(degree, key) {
    if (!this.isInitialized) {
      await this.init()
    }

    const degreeInfo = JAZZ_DEGREES[degree]
    if (!degreeInfo) return

    const rootPitch = this.getRootPitch(degree, key)
    const voicing = getVoicing(rootPitch, degreeInfo.type, this.config.voicingStyle)

    const allNotes = [...voicing.left, ...voicing.right]
    const noteNames = midiArrayToNotes(allNotes)

    this.piano.playChord(noteNames, '2n')
  }

  /**
   * Limpia recursos
   */
  dispose() {
    this.stop()
    this.clearScheduledEvents()

    disposeJazzSynth()
    disposeWalkingBass()
    disposeDrummer()

    this.piano = null
    this.bass = null
    this.drums = null
    this.isInitialized = false
  }
}

// Singleton
let engineInstance = null

export function getAudioEngine() {
  if (!engineInstance) {
    engineInstance = new AudioEngine()
  }
  return engineInstance
}

export function disposeAudioEngine() {
  if (engineInstance) {
    engineInstance.dispose()
    engineInstance = null
  }
}
