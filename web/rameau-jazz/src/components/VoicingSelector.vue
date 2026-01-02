<template>
  <div class="panel">
    <div class="panel-header">Voicing</div>
    <div class="voicing-options">
      <button
        v-for="v in voicings"
        :key="v.id"
        class="voicing-btn"
        :class="{ active: selected === v.id }"
        @click="select(v.id)"
        :title="v.description"
      >
        {{ v.label }}
      </button>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useHarmonyStore } from '../stores/harmony'

const harmonyStore = useHarmonyStore()

const voicings = [
  { id: 'shell', label: 'Shell', description: 'Root + 3 + 7 (trio)' },
  { id: 'drop2', label: 'Drop 2', description: 'Solo piano, guitarra' },
  { id: 'rootlessA', label: 'Rootless A', description: '3-5-7-9 (con bajista)' },
  { id: 'rootlessB', label: 'Rootless B', description: '7-9-3-5 (con bajista)' },
  { id: 'block', label: 'Block', description: 'Acordes completos' }
]

const selected = computed(() => harmonyStore.voicingStyle)

function select(id) {
  harmonyStore.setVoicingStyle(id)
}
</script>

<style scoped>
.voicing-options {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 6px;
}

.voicing-btn {
  padding: 8px;
  border: 1px solid var(--border-color);
  background: var(--bg-tertiary);
  color: var(--text-secondary);
  border-radius: var(--radius-md);
  cursor: pointer;
  font-size: 12px;
  transition: all 0.2s;
}

.voicing-btn:hover {
  background: var(--bg-hover);
}

.voicing-btn.active {
  background: var(--accent-purple);
  color: white;
  border-color: var(--accent-purple);
}
</style>
