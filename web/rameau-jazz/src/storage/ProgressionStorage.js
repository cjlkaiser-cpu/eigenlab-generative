/**
 * ProgressionStorage.js - Save/Load progressions to LocalStorage
 *
 * Stores progressions with metadata:
 * - name, date, key, tempo, style
 * - Full progression data
 */

const STORAGE_KEY = 'rameau_jazz_progressions'
const MAX_PROGRESSIONS = 50

/**
 * Get all saved progressions
 * @returns {Array} Array of saved progressions
 */
export function getSavedProgressions() {
  try {
    const data = localStorage.getItem(STORAGE_KEY)
    return data ? JSON.parse(data) : []
  } catch (err) {
    console.error('Failed to load progressions:', err)
    return []
  }
}

/**
 * Save a progression
 * @param {object} options - Save options
 * @param {string} options.name - Name for the progression
 * @param {Array} options.progression - The chord progression
 * @param {string} options.key - Musical key
 * @param {number} options.tempo - BPM
 * @param {string} options.style - Style preset
 * @param {string} options.voicingStyle - Voicing style
 * @param {number} options.gravity - Gravity setting
 * @param {number} options.modulationProbability - Modulation probability
 * @returns {string} ID of saved progression
 */
export function saveProgression({
  name,
  progression,
  key,
  tempo,
  style,
  voicingStyle,
  gravity,
  modulationProbability
}) {
  const progressions = getSavedProgressions()

  // Generate unique ID
  const id = `prog_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`

  // Create entry
  const entry = {
    id,
    name: name || generateDefaultName(key, progression.length),
    date: new Date().toISOString(),
    key,
    tempo,
    style,
    voicingStyle,
    gravity,
    modulationProbability,
    progression,
    chordSummary: progression.map(c => c.degree).join(' → ')
  }

  // Add to beginning of array
  progressions.unshift(entry)

  // Limit total stored
  if (progressions.length > MAX_PROGRESSIONS) {
    progressions.pop()
  }

  // Save
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(progressions))
    return id
  } catch (err) {
    console.error('Failed to save progression:', err)
    // Try to clear old data if storage is full
    if (err.name === 'QuotaExceededError') {
      progressions.splice(Math.floor(progressions.length / 2))
      localStorage.setItem(STORAGE_KEY, JSON.stringify(progressions))
      return id
    }
    return null
  }
}

/**
 * Load a progression by ID
 * @param {string} id - Progression ID
 * @returns {object|null} Progression data or null
 */
export function loadProgression(id) {
  const progressions = getSavedProgressions()
  return progressions.find(p => p.id === id) || null
}

/**
 * Delete a progression by ID
 * @param {string} id - Progression ID
 * @returns {boolean} Success
 */
export function deleteProgression(id) {
  const progressions = getSavedProgressions()
  const index = progressions.findIndex(p => p.id === id)

  if (index === -1) return false

  progressions.splice(index, 1)

  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(progressions))
    return true
  } catch (err) {
    console.error('Failed to delete progression:', err)
    return false
  }
}

/**
 * Rename a progression
 * @param {string} id - Progression ID
 * @param {string} newName - New name
 * @returns {boolean} Success
 */
export function renameProgression(id, newName) {
  const progressions = getSavedProgressions()
  const progression = progressions.find(p => p.id === id)

  if (!progression) return false

  progression.name = newName

  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(progressions))
    return true
  } catch (err) {
    console.error('Failed to rename progression:', err)
    return false
  }
}

/**
 * Generate default name for a progression
 * @param {string} key - Musical key
 * @param {number} bars - Number of bars
 * @returns {string} Default name
 */
function generateDefaultName(key, bars) {
  const date = new Date()
  const timeStr = date.toLocaleTimeString('es', { hour: '2-digit', minute: '2-digit' })
  return `${key} ${bars} bars - ${timeStr}`
}

/**
 * Export all progressions as JSON
 * @returns {string} JSON string
 */
export function exportAllProgressions() {
  const progressions = getSavedProgressions()
  return JSON.stringify(progressions, null, 2)
}

/**
 * Import progressions from JSON
 * @param {string} jsonString - JSON string
 * @returns {number} Number of progressions imported
 */
export function importProgressions(jsonString) {
  try {
    const imported = JSON.parse(jsonString)

    if (!Array.isArray(imported)) {
      throw new Error('Invalid format')
    }

    const existing = getSavedProgressions()
    const existingIds = new Set(existing.map(p => p.id))

    // Filter out duplicates and add new ones
    const newProgressions = imported.filter(p => !existingIds.has(p.id))
    const merged = [...newProgressions, ...existing].slice(0, MAX_PROGRESSIONS)

    localStorage.setItem(STORAGE_KEY, JSON.stringify(merged))

    return newProgressions.length
  } catch (err) {
    console.error('Failed to import progressions:', err)
    return 0
  }
}

/**
 * Clear all saved progressions
 * @returns {boolean} Success
 */
export function clearAllProgressions() {
  try {
    localStorage.removeItem(STORAGE_KEY)
    return true
  } catch (err) {
    console.error('Failed to clear progressions:', err)
    return false
  }
}

/**
 * Get storage usage info
 * @returns {object} Usage info
 */
export function getStorageInfo() {
  const progressions = getSavedProgressions()
  const dataSize = new Blob([JSON.stringify(progressions)]).size

  return {
    count: progressions.length,
    maxCount: MAX_PROGRESSIONS,
    sizeBytes: dataSize,
    sizeKB: (dataSize / 1024).toFixed(2)
  }
}

export default {
  getSavedProgressions,
  saveProgression,
  loadProgression,
  deleteProgression,
  renameProgression,
  exportAllProgressions,
  importProgressions,
  clearAllProgressions,
  getStorageInfo
}
