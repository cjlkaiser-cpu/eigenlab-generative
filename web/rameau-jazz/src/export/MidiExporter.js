/**
 * MidiExporter.js - Export progressions to Standard MIDI File
 *
 * Generates multi-track MIDI:
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
 */
function getRootPitch(degree, key, baseOctave = 60) {
  const degreeInfo = JAZZ_DEGREES[degree]
  const keyOffset = KEY_PITCHES[key] || 0
  const root = degreeInfo?.root || 0
  return baseOctave + keyOffset + root
}

/**
 * Generates walking bass line for a measure
 */
function generateBassLine(currentChord, nextChord, key) {
  const chordKey = currentChord.key || key
  const nextChordKey = nextChord?.key || key

  const rootPitch = getRootPitch(currentChord.degree, chordKey, 36) // C2
  const nextRootPitch = nextChord
    ? getRootPitch(nextChord.degree, nextChordKey, 36)
    : rootPitch

  const chordType = JAZZ_DEGREES[currentChord.degree]?.type || 'maj7'
  const intervals = CHORD_TYPES[chordType]?.intervals || [0, 4, 7]

  // Beat 1: Root
  const beat1 = rootPitch

  // Beat 2: Passing tone
  const rand2 = Math.random()
  let beat2
  if (rand2 < 0.4) {
    beat2 = rootPitch + 2
  } else if (rand2 < 0.7) {
    const third = intervals.find(i => i === 3 || i === 4) || 4
    beat2 = rootPitch + third
  } else {
    beat2 = rootPitch + 1
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

  // Beat 4: Chromatic approach
  const beat4 = nextRootPitch + (Math.random() < 0.5 ? 1 : -1)

  return [beat1, beat2, beat3, beat4]
}

/**
 * Main export function
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
  pianoTrack.addEvent(new MidiWriter.ProgramChangeEvent({ instrument: 1 }))

  progression.forEach((chord) => {
    const degreeInfo = JAZZ_DEGREES[chord.degree]
    if (!degreeInfo) {
      // Add rest for invalid chord
      pianoTrack.addEvent(new MidiWriter.NoteEvent({
        pitch: ['C4'],
        duration: '1',
        velocity: 0
      }))
      return
    }

    const chordKey = chord.key || key
    const rootPitch = getRootPitch(chord.degree, chordKey, 60)
    const chordType = degreeInfo.type

    // Get voicing
    const voicing = getVoicing(rootPitch, chordType, voicingStyle)
    const allNotes = [...voicing.left, ...voicing.right]

    // Add chord - whole note duration for full measure
    pianoTrack.addEvent(new MidiWriter.NoteEvent({
      pitch: allNotes,
      duration: '1',
      velocity: 80
    }))
  })

  tracks.push(pianoTrack)

  // ============================================
  // Track 2: Walking Bass
  // ============================================
  if (includeBass) {
    const bassTrack = new MidiWriter.Track()
    bassTrack.addTrackName('Bass')
    bassTrack.addEvent(new MidiWriter.ProgramChangeEvent({ instrument: 33 }))

    progression.forEach((chord, measureIndex) => {
      const nextChord = progression[(measureIndex + 1) % progression.length]
      const bassLine = generateBassLine(chord, nextChord, key)

      // Add each beat as quarter note
      bassLine.forEach((pitch, beatIndex) => {
        bassTrack.addEvent(new MidiWriter.NoteEvent({
          pitch: [pitch],
          duration: '4',
          velocity: beatIndex === 0 ? 100 : 80
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

    progression.forEach(() => {
      // Beat 1: Kick + Ride
      drumTrack.addEvent(new MidiWriter.NoteEvent({
        pitch: [DRUM_MAP.kick, DRUM_MAP.ride],
        duration: '4',
        velocity: 90,
        channel: 10
      }))

      // Beat 2: Hi-hat + Ride
      drumTrack.addEvent(new MidiWriter.NoteEvent({
        pitch: [DRUM_MAP.hihatClosed, DRUM_MAP.ride],
        duration: '4',
        velocity: 70,
        channel: 10
      }))

      // Beat 3: Ride
      drumTrack.addEvent(new MidiWriter.NoteEvent({
        pitch: [DRUM_MAP.ride],
        duration: '4',
        velocity: 80,
        channel: 10
      }))

      // Beat 4: Hi-hat + Ride
      drumTrack.addEvent(new MidiWriter.NoteEvent({
        pitch: [DRUM_MAP.hihatClosed, DRUM_MAP.ride],
        duration: '4',
        velocity: 70,
        channel: 10
      }))
    })

    tracks.push(drumTrack)
  }

  // ============================================
  // Generate MIDI file
  // ============================================
  const write = new MidiWriter.Writer(tracks)
  const midiData = write.buildFile()

  return new Blob([midiData], { type: 'audio/midi' })
}

/**
 * Download MIDI file
 */
export function downloadMidi(options) {
  const blob = exportToMidi(options)
  const filename = options.filename || 'RameauJazz'

  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = `${filename}.mid`

  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)

  URL.revokeObjectURL(url)
}

/**
 * Generate filename from progression info
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
