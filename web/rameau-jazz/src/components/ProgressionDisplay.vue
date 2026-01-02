<template>
  <div class="progression-display">
    <div class="chord-sequence" v-if="progression.length > 0">
      <span
        v-for="(chord, idx) in progression"
        :key="idx"
        class="chord-item"
        :class="{ active: idx === currentIndex }"
      >
        <span class="chord-badge" :class="getChordClass(chord.degree)">
          {{ chord.degree }}
        </span>
        <span v-if="chord.key !== baseKey" class="key-indicator">
          [{{ chord.key }}]
        </span>
        <span v-if="idx < progression.length - 1" class="arrow">→</span>
      </span>
    </div>
    <div class="empty-state" v-else>
      Click "Generar" para crear una progresion
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useHarmonyStore } from '../stores/harmony'

const harmonyStore = useHarmonyStore()

const progression = computed(() => harmonyStore.progression)
const baseKey = computed(() => harmonyStore.key)
const currentIndex = computed(() => harmonyStore.currentMeasure)

function getChordClass(degree) {
  // Determine function based on degree
  if (degree.includes('I') && !degree.includes('II') && !degree.includes('IV') && !degree.includes('VI') && !degree.includes('VII')) {
    return 'chord-tonic'
  }
  if (degree.includes('V') || degree.includes('VII') || degree.includes('bII')) {
    return 'chord-dominant'
  }
  return 'chord-subdominant'
}
</script>

<style scoped>
.progression-display {
  flex: 1;
  overflow-x: auto;
  white-space: nowrap;
  padding: 8px 0;
}

.chord-sequence {
  display: flex;
  align-items: center;
  gap: 4px;
}

.chord-item {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  transition: transform 0.2s;
}

.chord-item.active {
  transform: scale(1.1);
}

.chord-item.active .chord-badge {
  box-shadow: 0 0 12px currentColor;
}

.chord-badge {
  padding: 4px 8px;
  border-radius: var(--radius-sm);
  font-size: 12px;
  font-weight: 600;
  font-family: 'SF Mono', Monaco, monospace;
}

.chord-tonic {
  background: rgba(63, 185, 80, 0.2);
  color: var(--accent-green);
  border: 1px solid rgba(63, 185, 80, 0.3);
}

.chord-subdominant {
  background: rgba(210, 153, 34, 0.2);
  color: var(--accent-yellow);
  border: 1px solid rgba(210, 153, 34, 0.3);
}

.chord-dominant {
  background: rgba(248, 81, 73, 0.2);
  color: var(--accent-red);
  border: 1px solid rgba(248, 81, 73, 0.3);
}

.key-indicator {
  font-size: 10px;
  color: var(--accent-purple);
}

.arrow {
  color: var(--text-muted);
  margin: 0 4px;
}

.empty-state {
  color: var(--text-muted);
  font-style: italic;
}
</style>
