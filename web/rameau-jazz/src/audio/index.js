/**
 * Audio module index - Exporta todas las funciones de audio
 */

export { initAudio, isAudioReady, setTempo, setSwing, midiToNote, midiArrayToNotes } from './ToneSetup.js'
export { JazzSynth, getJazzSynth, disposeJazzSynth } from './JazzSynth.js'
export { WalkingBass, getWalkingBass, disposeWalkingBass } from './WalkingBass.js'
export { Drummer, getDrummer, disposeDrummer } from './Drummer.js'
export { AudioEngine, getAudioEngine, disposeAudioEngine } from './AudioEngine.js'
