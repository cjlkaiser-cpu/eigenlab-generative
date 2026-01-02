<template>
  <div class="panel">
    <div class="panel-header">Gravedad Tonal</div>
    <div class="gravity-control">
      <input
        type="range"
        min="0"
        max="100"
        :value="gravity * 100"
        @input="onGravityChange"
      />
      <div class="gravity-labels">
        <span>Caos</span>
        <span class="gravity-value">{{ Math.round(gravity * 100) }}%</span>
        <span>Estricto</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useHarmonyStore } from '../stores/harmony'

const harmonyStore = useHarmonyStore()

const gravity = computed(() => harmonyStore.gravity)

function onGravityChange(event) {
  harmonyStore.setGravity(event.target.value / 100)
}
</script>

<style scoped>
.gravity-control {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.gravity-labels {
  display: flex;
  justify-content: space-between;
  font-size: 11px;
  color: var(--text-muted);
}

.gravity-value {
  color: var(--accent-blue);
  font-weight: 600;
}
</style>
