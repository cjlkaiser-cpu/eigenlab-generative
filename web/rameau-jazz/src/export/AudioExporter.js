/**
 * AudioExporter.js - Export audio using Tone.js Recorder
 *
 * Records the audio output and exports as WAV file.
 * Uses Tone.Recorder which captures from Tone.Destination.
 */

import * as Tone from 'tone'

// Recorder instance
let recorder = null
let isRecording = false
let recordingPromise = null

/**
 * Initialize the recorder
 */
export function initRecorder() {
  if (recorder) return recorder

  recorder = new Tone.Recorder()
  Tone.Destination.connect(recorder)

  return recorder
}

/**
 * Start recording
 */
export async function startRecording() {
  if (isRecording) {
    console.warn('Already recording')
    return false
  }

  if (!recorder) {
    initRecorder()
  }

  // Ensure audio context is running
  if (Tone.context.state !== 'running') {
    await Tone.start()
  }

  recorder.start()
  isRecording = true
  console.log('Recording started')

  return true
}

/**
 * Stop recording and get the audio blob
 * @returns {Promise<Blob>} Audio blob (webm format)
 */
export async function stopRecording() {
  if (!isRecording || !recorder) {
    console.warn('Not recording')
    return null
  }

  const blob = await recorder.stop()
  isRecording = false
  console.log('Recording stopped, blob size:', blob.size)

  return blob
}

/**
 * Check if currently recording
 */
export function getIsRecording() {
  return isRecording
}

/**
 * Convert webm blob to WAV
 * @param {Blob} webmBlob - The webm audio blob
 * @returns {Promise<Blob>} WAV blob
 */
async function convertToWav(webmBlob) {
  // Create audio context for decoding
  const audioContext = new AudioContext()

  // Decode the webm blob
  const arrayBuffer = await webmBlob.arrayBuffer()
  const audioBuffer = await audioContext.decodeAudioData(arrayBuffer)

  // Convert to WAV
  const wavBlob = audioBufferToWav(audioBuffer)

  audioContext.close()

  return wavBlob
}

/**
 * Convert AudioBuffer to WAV Blob
 * @param {AudioBuffer} buffer - The audio buffer
 * @returns {Blob} WAV blob
 */
function audioBufferToWav(buffer) {
  const numChannels = buffer.numberOfChannels
  const sampleRate = buffer.sampleRate
  const format = 1 // PCM
  const bitDepth = 16

  // Interleave channels
  let interleaved
  if (numChannels === 2) {
    const left = buffer.getChannelData(0)
    const right = buffer.getChannelData(1)
    interleaved = new Float32Array(left.length + right.length)
    for (let i = 0; i < left.length; i++) {
      interleaved[i * 2] = left[i]
      interleaved[i * 2 + 1] = right[i]
    }
  } else {
    interleaved = buffer.getChannelData(0)
  }

  // Create WAV file
  const dataLength = interleaved.length * (bitDepth / 8)
  const wavBuffer = new ArrayBuffer(44 + dataLength)
  const view = new DataView(wavBuffer)

  // WAV header
  writeString(view, 0, 'RIFF')
  view.setUint32(4, 36 + dataLength, true)
  writeString(view, 8, 'WAVE')
  writeString(view, 12, 'fmt ')
  view.setUint32(16, 16, true) // fmt chunk size
  view.setUint16(20, format, true)
  view.setUint16(22, numChannels, true)
  view.setUint32(24, sampleRate, true)
  view.setUint32(28, sampleRate * numChannels * (bitDepth / 8), true)
  view.setUint16(32, numChannels * (bitDepth / 8), true)
  view.setUint16(34, bitDepth, true)
  writeString(view, 36, 'data')
  view.setUint32(40, dataLength, true)

  // Write audio data
  const volume = 0.8 // Prevent clipping
  let offset = 44
  for (let i = 0; i < interleaved.length; i++) {
    const sample = Math.max(-1, Math.min(1, interleaved[i] * volume))
    view.setInt16(offset, sample < 0 ? sample * 0x8000 : sample * 0x7FFF, true)
    offset += 2
  }

  return new Blob([wavBuffer], { type: 'audio/wav' })
}

/**
 * Helper to write string to DataView
 */
function writeString(view, offset, string) {
  for (let i = 0; i < string.length; i++) {
    view.setUint8(offset + i, string.charCodeAt(i))
  }
}

/**
 * Download audio as WAV file
 * @param {Blob} blob - Audio blob (webm or wav)
 * @param {string} filename - Filename without extension
 */
export async function downloadAudio(blob, filename = 'RameauJazz') {
  let wavBlob = blob

  // Convert to WAV if needed (Tone.Recorder outputs webm)
  if (blob.type !== 'audio/wav') {
    try {
      wavBlob = await convertToWav(blob)
    } catch (err) {
      console.error('Failed to convert to WAV:', err)
      // Fallback: download original format
      wavBlob = blob
    }
  }

  const url = URL.createObjectURL(wavBlob)
  const link = document.createElement('a')
  link.href = url
  link.download = `${filename}.wav`

  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)

  URL.revokeObjectURL(url)
}

/**
 * Record a full progression playback
 * @param {Function} playFunction - Function to start playback
 * @param {Function} stopFunction - Function to stop playback
 * @param {number} durationMs - Total duration in milliseconds
 * @param {string} filename - Output filename
 */
export async function recordProgression(playFunction, stopFunction, durationMs, filename) {
  // Start recording
  await startRecording()

  // Start playback
  playFunction()

  // Wait for duration plus a small buffer
  await new Promise(resolve => setTimeout(resolve, durationMs + 500))

  // Stop playback
  stopFunction()

  // Stop recording
  const blob = await stopRecording()

  if (blob && blob.size > 0) {
    await downloadAudio(blob, filename)
    return true
  }

  return false
}

/**
 * Generate filename for audio export
 */
export function generateAudioFilename(key, numChords, tempo, style = 'jazz') {
  const timestamp = new Date().toISOString().slice(0, 10)
  return `RameauJazz_${key}_${numChords}bars_${tempo}bpm_${style}_${timestamp}`
}

export default {
  initRecorder,
  startRecording,
  stopRecording,
  getIsRecording,
  downloadAudio,
  recordProgression,
  generateAudioFilename
}
