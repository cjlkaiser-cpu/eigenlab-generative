<template>
  <div class="panel">
    <div class="panel-header">Modulacion</div>
    <div class="modulation-controls">
      <label class="checkbox-row">
        <input type="checkbox" v-model="enabled" />
        <span>Activar modulaciones</span>
      </label>

      <div class="control-row" v-if="enabled">
        <label>Probabilidad</label>
        <input
          type="range"
          min="0"
          max="50"
          :value="probability * 100"
          @input="onProbabilityChange"
        />
        <span class="value">{{ Math.round(probability * 100) }}%</span>
      </div>

      <div class="control-row" v-if="enabled">
        <label>Nivel</label>
        <select class="form-control" v-model="level">
          <option :value="0">Basicas</option>
          <option :value="1">Extendidas</option>
          <option :value="2">Coltrane</option>
        </select>
      </div>

      <label class="checkbox-row" v-if="enabled">
        <input type="checkbox" v-model="returnToTonic" />
        <span>Retorno a tonica</span>
      </label>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useHarmonyStore } from '../stores/harmony'

const harmonyStore = useHarmonyStore()

const enabled = computed({
  get: () => harmonyStore.modulationEnabled,
  set: (val) => { harmonyStore.modulationEnabled = val }
})

const probability = computed(() => harmonyStore.modulationProbability)

const level = computed({
  get: () => harmonyStore.modulationLevel,
  set: (val) => { harmonyStore.modulationLevel = val }
})

const returnToTonic = computed({
  get: () => harmonyStore.returnToTonic,
  set: (val) => { harmonyStore.returnToTonic = val }
})

function onProbabilityChange(event) {
  harmonyStore.setModulationProbability(event.target.value / 100)
}
</script>

<style scoped>
.modulation-controls {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.checkbox-row {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  font-size: 13px;
}

.checkbox-row input {
  cursor: pointer;
}

.control-row {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.control-row label {
  font-size: 12px;
  color: var(--text-secondary);
}

.control-row .value {
  font-size: 11px;
  color: var(--accent-blue);
  text-align: right;
}
</style>
