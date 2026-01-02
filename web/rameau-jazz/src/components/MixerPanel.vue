<template>
  <div class="panel">
    <div class="panel-header">Mixer</div>
    <div class="mixer-channels">
      <div class="channel" v-for="ch in channels" :key="ch.id">
        <label>{{ ch.label }}</label>
        <input
          type="range"
          min="0"
          max="100"
          :value="getVolume(ch.id) * 100"
          @input="setVolume(ch.id, $event)"
        />
        <span class="volume-value">{{ Math.round(getVolume(ch.id) * 100) }}</span>
        <button
          v-if="ch.toggleable"
          class="toggle-btn"
          :class="{ active: isEnabled(ch.id) }"
          @click="toggleChannel(ch.id)"
          :title="isEnabled(ch.id) ? 'Mute' : 'Unmute'"
        >
          {{ isEnabled(ch.id) ? 'ON' : 'OFF' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useHarmonyStore } from '../stores/harmony'

const harmonyStore = useHarmonyStore()

const channels = [
  { id: 'piano', label: 'Piano', toggleable: false },
  { id: 'bass', label: 'Bass', toggleable: true },
  { id: 'drums', label: 'Drums', toggleable: true }
]

function getVolume(channelId) {
  switch (channelId) {
    case 'piano': return harmonyStore.pianoVolume
    case 'bass': return harmonyStore.bassVolume
    case 'drums': return harmonyStore.drumsVolume
    default: return 0.5
  }
}

function setVolume(channelId, event) {
  harmonyStore.setVolume(channelId, event.target.value / 100)
}

function isEnabled(channelId) {
  switch (channelId) {
    case 'bass': return harmonyStore.bassEnabled
    case 'drums': return harmonyStore.drumsEnabled
    default: return true
  }
}

function toggleChannel(channelId) {
  switch (channelId) {
    case 'bass':
      harmonyStore.setBassEnabled(!harmonyStore.bassEnabled)
      break
    case 'drums':
      harmonyStore.setDrumsEnabled(!harmonyStore.drumsEnabled)
      break
  }
}
</script>

<style scoped>
.mixer-channels {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.channel {
  display: grid;
  grid-template-columns: 50px 1fr 30px 40px;
  align-items: center;
  gap: 8px;
}

.channel label {
  font-size: 11px;
  color: var(--text-secondary);
  text-transform: uppercase;
}

.channel input[type="range"] {
  width: 100%;
}

.volume-value {
  font-size: 11px;
  color: var(--text-muted);
  font-family: 'SF Mono', Monaco, monospace;
  text-align: right;
}

.toggle-btn {
  padding: 2px 6px;
  font-size: 9px;
  border: 1px solid var(--border-color);
  background: var(--bg-tertiary);
  color: var(--text-muted);
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: all 0.2s;
}

.toggle-btn.active {
  background: var(--accent-green);
  color: white;
  border-color: var(--accent-green);
}
</style>
