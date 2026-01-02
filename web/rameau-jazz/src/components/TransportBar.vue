<template>
  <div class="transport-bar">
    <div class="transport-controls">
      <button class="btn btn-icon btn-secondary" @click="stop" title="Stop">
        <span class="icon">&#9632;</span>
      </button>
      <button class="btn btn-icon" :class="isPlaying ? 'btn-secondary' : 'btn-success'" @click="togglePlay" :title="isPlaying ? 'Pause' : 'Play'">
        <span class="icon">{{ isPlaying ? '&#10074;&#10074;' : '&#9654;' }}</span>
      </button>
      <button class="btn btn-secondary" @click="generate" title="Generate new progression">
        Generar
      </button>
      <div class="export-dropdown" ref="exportDropdown">
        <button
          class="btn btn-secondary export-btn"
          @click="toggleExportMenu"
          :disabled="!hasProgression"
          title="Export MIDI"
        >
          <span class="export-icon">&#9835;</span>
          Export
          <span class="dropdown-arrow">&#9662;</span>
        </button>
        <div v-if="showExportMenu" class="export-menu">
          <button class="export-option" @click="exportMidi(false)">
            <span class="option-icon">&#127929;</span>
            MIDI (Piano only)
          </button>
          <button class="export-option" @click="exportMidi(true)">
            <span class="option-icon">&#127928;</span>
            MIDI (Piano + Bass)
          </button>
          <button class="export-option" @click="exportMidiFull">
            <span class="option-icon">&#127927;</span>
            MIDI (Full band)
          </button>
        </div>
      </div>
    </div>

    <!-- Tempo Control -->
    <div class="tempo-control">
      <button class="tempo-btn" @click="decreaseTempo" title="Decrease tempo">−</button>
      <div
        class="tempo-display"
        @click="tapTempo"
        @wheel.prevent="onTempoWheel"
        :class="{ tapping: isTapping }"
        title="Click to tap tempo, scroll to adjust"
      >
        <span class="tempo-value">{{ tempo }}</span>
        <span class="tempo-label">BPM</span>
      </div>
      <button class="tempo-btn" @click="increaseTempo" title="Increase tempo">+</button>
    </div>

    <!-- Swing Control -->
    <div class="swing-control">
      <label>Swing</label>
      <input
        type="range"
        min="0"
        max="100"
        :value="swingAmount * 100"
        @input="setSwing"
        class="swing-slider"
      />
      <span class="swing-value">{{ Math.round(swingAmount * 100) }}%</span>
    </div>

    <!-- Beat Display -->
    <div class="transport-info">
      <span class="beat-display">{{ currentMeasure + 1 }}.{{ currentBeat + 1 }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useHarmonyStore } from '../stores/harmony'
import { downloadMidi, generateFilename } from '../export/MidiExporter.js'

const harmonyStore = useHarmonyStore()

const isPlaying = computed(() => harmonyStore.isPlaying)
const currentMeasure = computed(() => harmonyStore.currentMeasure)
const currentBeat = computed(() => harmonyStore.currentBeat)
const tempo = computed(() => harmonyStore.tempo)
const swingAmount = computed(() => harmonyStore.swingAmount)
const hasProgression = computed(() => harmonyStore.progression.length > 0)

// Export dropdown state
const showExportMenu = ref(false)
const exportDropdown = ref(null)

// Tap tempo state
const tapTimes = ref([])
const isTapping = ref(false)
let tapTimeout = null

function togglePlay() {
  if (harmonyStore.isPlaying) {
    harmonyStore.pause()
  } else {
    harmonyStore.play()
  }
}

function stop() {
  harmonyStore.stop()
}

function generate() {
  harmonyStore.generateProgression(8)
}

function increaseTempo() {
  harmonyStore.setTempo(tempo.value + 5)
}

function decreaseTempo() {
  harmonyStore.setTempo(tempo.value - 5)
}

function onTempoWheel(event) {
  const delta = event.deltaY > 0 ? -2 : 2
  harmonyStore.setTempo(tempo.value + delta)
}

function tapTempo() {
  const now = Date.now()

  // Clear old taps after 2 seconds
  if (tapTimeout) clearTimeout(tapTimeout)
  tapTimeout = setTimeout(() => {
    tapTimes.value = []
    isTapping.value = false
  }, 2000)

  // Add current tap
  tapTimes.value.push(now)
  isTapping.value = true

  // Need at least 2 taps to calculate tempo
  if (tapTimes.value.length >= 2) {
    // Keep only last 4 taps for average
    if (tapTimes.value.length > 4) {
      tapTimes.value = tapTimes.value.slice(-4)
    }

    // Calculate average interval
    let totalInterval = 0
    for (let i = 1; i < tapTimes.value.length; i++) {
      totalInterval += tapTimes.value[i] - tapTimes.value[i - 1]
    }
    const avgInterval = totalInterval / (tapTimes.value.length - 1)

    // Convert to BPM
    const newTempo = Math.round(60000 / avgInterval)
    if (newTempo >= 40 && newTempo <= 240) {
      harmonyStore.setTempo(newTempo)
    }
  }
}

function setSwing(event) {
  harmonyStore.setSwingAmount(event.target.value / 100)
}

// Export functions
function toggleExportMenu() {
  showExportMenu.value = !showExportMenu.value
}

function closeExportMenu(event) {
  if (exportDropdown.value && !exportDropdown.value.contains(event.target)) {
    showExportMenu.value = false
  }
}

function exportMidi(includeBass) {
  const filename = generateFilename(
    harmonyStore.key,
    harmonyStore.progression.length,
    harmonyStore.stylePreset
  )

  downloadMidi({
    progression: harmonyStore.progression,
    key: harmonyStore.key,
    tempo: harmonyStore.tempo,
    voicingStyle: harmonyStore.voicingStyle,
    includeBass,
    includeDrums: false,
    filename
  })

  showExportMenu.value = false
}

function exportMidiFull() {
  const filename = generateFilename(
    harmonyStore.key,
    harmonyStore.progression.length,
    harmonyStore.stylePreset
  )

  downloadMidi({
    progression: harmonyStore.progression,
    key: harmonyStore.key,
    tempo: harmonyStore.tempo,
    voicingStyle: harmonyStore.voicingStyle,
    includeBass: true,
    includeDrums: true,
    filename
  })

  showExportMenu.value = false
}

onMounted(() => {
  document.addEventListener('click', closeExportMenu)
})

onUnmounted(() => {
  document.removeEventListener('click', closeExportMenu)
})
</script>

<style scoped>
.transport-bar {
  display: flex;
  align-items: center;
  gap: 20px;
}

.transport-controls {
  display: flex;
  gap: 8px;
}

.icon {
  font-size: 12px;
}

/* Tempo Control */
.tempo-control {
  display: flex;
  align-items: center;
  gap: 4px;
  background: var(--bg-tertiary);
  border-radius: var(--radius-md);
  padding: 4px;
}

.tempo-btn {
  width: 28px;
  height: 28px;
  border: none;
  background: var(--bg-secondary);
  color: var(--text-secondary);
  border-radius: var(--radius-sm);
  cursor: pointer;
  font-size: 16px;
  font-weight: 600;
  transition: all 0.15s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.tempo-btn:hover {
  background: var(--accent-blue);
  color: white;
}

.tempo-display {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 4px 12px;
  cursor: pointer;
  border-radius: var(--radius-sm);
  transition: all 0.15s;
  user-select: none;
}

.tempo-display:hover {
  background: var(--bg-secondary);
}

.tempo-display.tapping {
  background: var(--accent-green);
}

.tempo-display.tapping .tempo-value,
.tempo-display.tapping .tempo-label {
  color: white;
}

.tempo-value {
  font-family: 'SF Mono', Monaco, monospace;
  font-size: 20px;
  font-weight: 700;
  color: var(--accent-blue);
  line-height: 1;
}

.tempo-label {
  font-size: 9px;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 1px;
}

/* Swing Control */
.swing-control {
  display: flex;
  align-items: center;
  gap: 8px;
}

.swing-control label {
  font-size: 11px;
  color: var(--text-secondary);
  text-transform: uppercase;
}

.swing-slider {
  width: 80px;
  height: 4px;
  -webkit-appearance: none;
  appearance: none;
  background: var(--bg-tertiary);
  border-radius: 2px;
  cursor: pointer;
}

.swing-slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 14px;
  height: 14px;
  background: var(--accent-purple);
  border-radius: 50%;
  cursor: pointer;
  transition: transform 0.1s;
}

.swing-slider::-webkit-slider-thumb:hover {
  transform: scale(1.2);
}

.swing-value {
  font-family: 'SF Mono', Monaco, monospace;
  font-size: 11px;
  color: var(--text-muted);
  min-width: 36px;
}

/* Beat Display */
.transport-info {
  margin-left: auto;
}

.beat-display {
  font-family: 'SF Mono', Monaco, monospace;
  font-size: 18px;
  color: var(--accent-blue);
  min-width: 60px;
}

/* Export Dropdown */
.export-dropdown {
  position: relative;
}

.export-btn {
  display: flex;
  align-items: center;
  gap: 6px;
}

.export-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.export-icon {
  font-size: 14px;
}

.dropdown-arrow {
  font-size: 10px;
  opacity: 0.7;
}

.export-menu {
  position: absolute;
  bottom: 100%;
  left: 0;
  margin-bottom: 4px;
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  box-shadow: 0 -8px 24px rgba(0, 0, 0, 0.4);
  min-width: 180px;
  z-index: 100;
  overflow: hidden;
}

.export-option {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
  padding: 10px 14px;
  border: none;
  background: transparent;
  color: var(--text-primary);
  font-size: 13px;
  text-align: left;
  cursor: pointer;
  transition: all 0.15s;
}

.export-option:hover {
  background: var(--accent-blue);
  color: white;
}

.option-icon {
  font-size: 16px;
}
</style>
