<template>
  <div class="panel">
    <div class="panel-header">Tension</div>
    <div class="tension-container">
      <div class="tension-bar">
        <div
          class="tension-fill"
          :style="{
            width: `${tension * 100}%`,
            background: tensionColor
          }"
        ></div>
      </div>
      <div class="tension-labels">
        <span>Reposo</span>
        <span class="tension-value" :style="{ color: tensionColor }">
          {{ tensionLabel }}
        </span>
        <span>Tension</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useHarmonyStore } from '../stores/harmony'

const harmonyStore = useHarmonyStore()

const tension = computed(() => harmonyStore.tension)

const tensionColor = computed(() => {
  const t = tension.value
  if (t < 0.3) return 'var(--tonic-color)'
  if (t < 0.6) return 'var(--subdominant-color)'
  return 'var(--dominant-color)'
})

const tensionLabel = computed(() => {
  const t = tension.value
  if (t < 0.2) return 'Estable'
  if (t < 0.4) return 'Leve'
  if (t < 0.6) return 'Media'
  if (t < 0.8) return 'Alta'
  return 'Maxima'
})
</script>

<style scoped>
.tension-container {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.tension-labels {
  display: flex;
  justify-content: space-between;
  font-size: 10px;
  color: var(--text-muted);
}

.tension-value {
  font-weight: 600;
}
</style>
