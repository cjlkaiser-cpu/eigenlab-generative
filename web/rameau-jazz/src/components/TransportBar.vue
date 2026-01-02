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
import { ref, computed } from 'vue'
import { useHarmonyStore } from '../stores/harmony'

const harmonyStore = useHarmonyStore()

const isPlaying = computed(() => harmonyStore.isPlaying)
const currentMeasure = computed(() => harmonyStore.currentMeasure)
const currentBeat = computed(() => harmonyStore.currentBeat)
const tempo = computed(() => harmonyStore.tempo)
const swingAmount = computed(() => harmonyStore.swingAmount)

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
</style>
