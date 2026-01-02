/**
 * MidiExporter.js - Export progressions to Standard MIDI File
 *
 * Generates multi-track MIDI:
 * - Track 0: Metadata (tempo, time signature)
 * - Track 1: Piano chords (voicings)
 * - Track 2: Walking bass
 * - Track 3: Drums (optional)
 *
 * Uses midi-writer-js library
 */

import MidiWriter from 'midi-writer-js'
import { JAZZ_DEGREES } from '../engine/JazzDegrees.js'
import { CHORD_TYPES } from '../engine/ChordTypes.js'
import { getVoicing } from '../engine/Voicings.js'

/**
 * Key pitch offsets (C = 0)
 */
const KEY_PITCHES = {
  'C': 0, 'Db': 1, 'D': 2, 'Eb': 3, 'E': 4, 'F': 5,
  'Gb': 6, 'G': 7, 'Ab': 8, 'A': 9, 'Bb': 10, 'B': 11
}

/**
 * GM Drum map
 */
const DRUM_MAP = {
  kick: 36,
  snare: 38,
  rimshot: 37,
  hihatClosed: 42,
  hihatOpen: 46,
  ride: 51,
  crash: 49
}

/**
 * Calculates root pitch for a degree in a key
 * @param {string} degree - Chord degree (e.g., 'Imaj7', 'IIm7')
 * @param {string} key - Key (e.g., 'C', 'Bb')
 * @param {number} baseOctave - Base MIDI octave
 * @returns {number} MIDI pitch
 */
function getRootPitch(degree, key, baseOctave = 60) {
  const degreeInfo = JAZZ_DEGREES[degree]
  const keyOffset = KEY_PITCHES[key] || 0
  const root = degreeInfo?.root || 0
  return baseOctave + keyOffset + root
}

/**
 * Generates walking bass line for a measure
 * @param {object} currentChord - {degree, key}
 * @param {object} nextChord - {degree, key}
 * @returns {number[]} Array of 4 MIDI pitches
 */
function generateBassLine(currentChord, nextChord) {
  const rootPitch = getRootPitch(currentChord.degree, currentChord.key, 36) // C2
  const nextRootPitch = nextChord
    ? getRootPitch(nextChord.degree, nextChord.key, 36)
    : rootPitch

  const chordType = JAZZ_DEGREES[currentChord.degree]?.type || 'maj7'
  const intervals = CHORD_TYPES[chordType]?.intervals || [0, 4, 7]

  // Beat 1: Root
  const beat1 = rootPitch

  // Beat 2: Passing (scalar, arpeggio, or chromatic)
  const rand2 = Math.random()
  let beat2
  if (rand2 < 0.4) {
    beat2 = rootPitch + 2 // Major 2nd
  } else if (rand2 < 0.7) {
    const third = intervals.find(i => i === 3 || i === 4) || 4
    beat2 = rootPitch + third
  } else {
    beat2 = rootPitch + 1 // Chromatic
  }

  // Beat 3: Target (5th or 3rd)
  const rand3 = Math.random()
  let beat3
  if (rand3 < 0.5) {
    const fifth = intervals.find(i => i === 6 || i === 7 || i === 8) || 7
    beat3 = rootPitch + fifth
  } else {
    const third = intervals.find(i => i === 3 || i === 4) || 4
    beat3 = rootPitch + third
  }

  // Beat 4: Chromatic approach to next root
  const beat4 = nextRootPitch + (Math.random() < 0.5 ? 1 : -1)

  return [beat1, beat2, beat3, beat4]
}

/**
 * Generates drum pattern for a measure
 * @param {number} measureIndex - Current measure (for variation)
 * @returns {Array<{pitch: number, beat: number, velocity: number}>}
 */
function generateDrumPattern(measureIndex) {
  const pattern = []

  // Ride on all beats
  for (let beat = 0; beat < 4; beat++) {
    pattern.push({
      pitch: DRUM_MAP.ride,
      beat: beat,
      velocity: beat === 0 || beat === 2 ? 90 : 70
    })
  }

  // Hi-hat on 2 and 4 (swing feel)
  pattern.push({ pitch: DRUM_MAP.hihatClosed, beat: 1, velocity: 60 })
  pattern.push({ pitch: DRUM_MAP.hihatClosed, beat: 3, velocity: 60 })

  // Kick on 1 (occasionally on 3)
  pattern.push({ pitch: DRUM_MAP.kick, beat: 0, velocity: 100 })
  if (Math.random() < 0.3) {
    pattern.push({ pitch: DRUM_MAP.kick, beat: 2, velocity: 70 })
  }

  // Snare ghost notes
  if (Math.random() < 0.4) {
    pattern.push({ pitch: DRUM_MAP.snare, beat: 2.5, velocity: 40 })
  }

  return pattern
}

/**
 * Main export function
 * @param {object} options - Export options
 * @param {Array<{degree: string, key: string}>} options.progression - Chord progression
 * @param {string} options.key - Main key
 * @param {number} options.tempo - BPM
 * @param {string} options.voicingStyle - Voicing style
 * @param {boolean} options.includeBass - Include bass track
 * @param {boolean} options.includeDrums - Include drums track
 * @param {string} options.filename - Output filename
 * @returns {Blob} MIDI file blob
 */
export function exportToMidi({
  progression,
  key = 'C',
  tempo = 120,
  voicingStyle = 'shell',
  includeBass = true,
  includeDrums = false,
  filename = 'RameauJazz'
}) {
  if (!progression || progression.length === 0) {
    throw new Error('No progression to export')
  }

  const tracks = []

  // ============================================
  // Track 1: Piano (chords)
  // ============================================
  const pianoTrack = new MidiWriter.Track()
  pianoTrack.addTrackName('Piano')
  pianoTrack.setTempo(tempo)
  pianoTrack.setTimeSignature(4, 4)

  // Add program change (Piano = 0)
  pianoTrack.addEvent(new MidiWriter.ProgramChangeEvent({ instrument: 1 }))

  progression.forEach((chord, measureIndex) => {
    const degreeInfo = JAZZ_DEGREES[chord.degree]
    if (!degreeInfo) return

    const chordKey = chord.key || key
    const rootPitch = getRootPitch(chord.degree, chordKey, 60) // C4
    const chordType = degreeInfo.type

    // Get voicing
    const voicing = getVoicing(rootPitch, chordType, voicingStyle)
    const allNotes = [...voicing.left, ...voicing.right]

    // Add chord on beat 1, duration = dotted half note (3 beats)
    pianoTrack.addEvent(new MidiWriter.NoteEvent({
      pitch: allNotes,
      duration: 'd2', // Dotted half note
      velocity: 80,
      startTick: measureIndex * 480 * 4 // 480 ticks per quarter
    }))
  })

  tracks.push(pianoTrack)

  // ============================================
  // Track 2: Walking Bass
  // ============================================
  if (includeBass) {
    const bassTrack = new MidiWriter.Track()
    bassTrack.addTrackName('Bass')

    // Acoustic Bass = 32
    bassTrack.addEvent(new MidiWriter.ProgramChangeEvent({ instrument: 33 }))

    progression.forEach((chord, measureIndex) => {
      const nextChord = progression[(measureIndex + 1) % progression.length]
      const bassLine = generateBassLine(chord, nextChord)

      bassLine.forEach((pitch, beatIndex) => {
        bassTrack.addEvent(new MidiWriter.NoteEvent({
          pitch: [pitch],
          duration: '4',
          velocity: beatIndex === 0 ? 100 : 80,
          startTick: (measureIndex * 4 + beatIndex) * 480
        }))
      })
    })

    tracks.push(bassTrack)
  }

  // ============================================
  // Track 3: Drums (Channel 10)
  // ============================================
  if (includeDrums) {
    const drumTrack = new MidiWriter.Track()
    drumTrack.addTrackName('Drums')
    drumTrack.addEvent(new MidiWriter.ProgramChangeEvent({ instrument: 1 }))

    progression.forEach((_, measureIndex) => {
      const pattern = generateDrumPattern(measureIndex)

      pattern.forEach(hit => {
        const tickOffset = hit.beat * 480
        drumTrack.addEvent(new MidiWriter.NoteEvent({
          pitch: [hit.pitch],
          duration: '8',
          velocity: hit.velocity,
          startTick: measureIndex * 4 * 480 + tickOffset,
          channel: 10 // GM Drums
        }))
      })
    })

    tracks.push(drumTrack)
  }

  // ============================================
  // Generate MIDI file
  // ============================================
  const write = new MidiWriter.Writer(tracks)
  const midiData = write.buildFile()

  // Create Blob
  const blob = new Blob([midiData], { type: 'audio/midi' })

  return blob
}

/**
 * Download MIDI file
 * @param {object} options - Same as exportToMidi
 */
export function downloadMidi(options) {
  const blob = exportToMidi(options)
  const filename = options.filename || 'RameauJazz'

  // Create download link
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = `${filename}.mid`

  // Trigger download
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)

  // Cleanup
  URL.revokeObjectURL(url)
}

/**
 * Generate filename from progression info
 * @param {string} key - Key
 * @param {number} numChords - Number of chords
 * @param {string} style - Style preset
 * @returns {string} Filename
 */
export function generateFilename(key, numChords, style = 'jazz') {
  const timestamp = new Date().toISOString().slice(0, 10)
  return `RameauJazz_${key}_${numChords}bars_${style}_${timestamp}`
}

export default {
  exportToMidi,
  downloadMidi,
  generateFilename
}
