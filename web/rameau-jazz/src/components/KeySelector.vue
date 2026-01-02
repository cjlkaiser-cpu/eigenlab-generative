<template>
  <div class="panel">
    <div class="panel-header">Tonalidad</div>
    <div class="key-controls">
      <select class="form-control" v-model="selectedKey" @change="onKeyChange">
        <option v-for="k in keys" :key="k" :value="k">{{ k }}</option>
      </select>
      <div class="mode-toggle">
        <button
          class="mode-btn"
          :class="{ active: mode === 'major' }"
          @click="setMode('major')"
        >
          Mayor
        </button>
        <button
          class="mode-btn"
          :class="{ active: mode === 'minor' }"
          @click="setMode('minor')"
        >
          menor
        </button>
      </div>
    </div>
    <div class="key-display">
      <span class="key-badge">{{ harmonyStore.keySignature }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useHarmonyStore } from '../stores/harmony'

const harmonyStore = useHarmonyStore()

const keys = ['C', 'G', 'D', 'A', 'E', 'B', 'F', 'Bb', 'Eb', 'Ab', 'Db', 'Gb']
const selectedKey = ref(harmonyStore.key)
const mode = computed(() => harmonyStore.mode)

function onKeyChange() {
  harmonyStore.setKey(selectedKey.value)
}

function setMode(newMode) {
  harmonyStore.setMode(newMode)
}
</script>

<style scoped>
.key-controls {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.mode-toggle {
  display: flex;
  gap: 4px;
}

.mode-btn {
  flex: 1;
  padding: 6px 12px;
  border: 1px solid var(--border-color);
  background: var(--bg-tertiary);
  color: var(--text-secondary);
  border-radius: var(--radius-md);
  cursor: pointer;
  font-size: 13px;
  transition: all 0.2s;
}

.mode-btn.active {
  background: var(--accent-blue);
  color: white;
  border-color: var(--accent-blue);
}

.key-display {
  margin-top: 12px;
  text-align: center;
}
</style>
