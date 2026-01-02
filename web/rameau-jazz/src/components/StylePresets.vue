<template>
  <select class="form-control style-select" v-model="selected" @change="onSelect">
    <option v-for="s in styles" :key="s.id" :value="s.id">
      {{ s.label }}
    </option>
  </select>
</template>

<script setup>
import { computed } from 'vue'
import { useHarmonyStore } from '../stores/harmony'

const harmonyStore = useHarmonyStore()

const styles = [
  { id: 'standard', label: 'Standard' },
  { id: 'bebop', label: 'Bebop' },
  { id: 'bossaNova', label: 'Bossa Nova' },
  { id: 'modal', label: 'Modal' },
  { id: 'ballad', label: 'Ballad' }
]

const selected = computed({
  get: () => harmonyStore.stylePreset,
  set: (val) => { harmonyStore.setStylePreset(val) }
})

function onSelect() {
  // Handled by computed setter
}
</script>

<style scoped>
.style-select {
  min-width: 120px;
}
</style>
