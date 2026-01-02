<template>
  <div v-if="isOpen" class="modal-overlay" @click.self="close">
    <div class="modal-content">
      <div class="modal-header">
        <h2>Progresiones Guardadas</h2>
        <button class="close-btn" @click="close">&times;</button>
      </div>

      <div class="modal-body">
        <!-- Save current -->
        <div class="save-section">
          <input
            v-model="saveName"
            type="text"
            placeholder="Nombre de la progresión..."
            class="save-input"
            @keyup.enter="saveCurrentProgression"
          />
          <button
            class="btn btn-primary"
            @click="saveCurrentProgression"
            :disabled="!hasProgression"
          >
            Guardar actual
          </button>
        </div>

        <!-- List of saved progressions -->
        <div class="progressions-list">
          <div v-if="progressions.length === 0" class="empty-state">
            No hay progresiones guardadas
          </div>

          <div
            v-for="prog in progressions"
            :key="prog.id"
            class="progression-item"
            :class="{ selected: selectedId === prog.id }"
            @click="selectProgression(prog.id)"
          >
            <div class="prog-info">
              <span class="prog-name">{{ prog.name }}</span>
              <span class="prog-meta">
                {{ prog.key }} · {{ prog.tempo }} BPM · {{ prog.progression.length }} bars
              </span>
              <span class="prog-chords">{{ prog.chordSummary }}</span>
            </div>
            <div class="prog-actions">
              <button
                class="action-btn load"
                @click.stop="loadSelectedProgression(prog)"
                title="Cargar"
              >
                ▶
              </button>
              <button
                class="action-btn delete"
                @click.stop="deleteSelectedProgression(prog.id)"
                title="Eliminar"
              >
                ✕
              </button>
            </div>
          </div>
        </div>

        <!-- Storage info -->
        <div class="storage-info">
          {{ storageInfo.count }}/{{ storageInfo.maxCount }} guardadas
          ({{ storageInfo.sizeKB }} KB)
        </div>
      </div>

      <div class="modal-footer">
        <button class="btn btn-secondary" @click="exportAll">
          Exportar JSON
        </button>
        <label class="btn btn-secondary import-btn">
          Importar JSON
          <input type="file" accept=".json" @change="importFromFile" hidden />
        </label>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { useHarmonyStore } from '../stores/harmony'
import {
  getSavedProgressions,
  saveProgression,
  loadProgression,
  deleteProgression,
  exportAllProgressions,
  importProgressions,
  getStorageInfo
} from '../storage/ProgressionStorage.js'

const props = defineProps({
  isOpen: Boolean
})

const emit = defineEmits(['close'])

const harmonyStore = useHarmonyStore()

const saveName = ref('')
const progressions = ref([])
const selectedId = ref(null)
const storageInfo = ref({ count: 0, maxCount: 50, sizeKB: '0' })

const hasProgression = computed(() => harmonyStore.progression.length > 0)

// Load progressions when modal opens
watch(() => props.isOpen, (open) => {
  if (open) {
    refreshList()
  }
})

function refreshList() {
  progressions.value = getSavedProgressions()
  storageInfo.value = getStorageInfo()
}

function close() {
  emit('close')
}

function saveCurrentProgression() {
  if (!hasProgression.value) return

  saveProgression({
    name: saveName.value || null,
    progression: harmonyStore.progression,
    key: harmonyStore.key,
    tempo: harmonyStore.tempo,
    style: harmonyStore.stylePreset,
    voicingStyle: harmonyStore.voicingStyle,
    gravity: harmonyStore.gravity,
    modulationProbability: harmonyStore.modulationProbability
  })

  saveName.value = ''
  refreshList()
}

function selectProgression(id) {
  selectedId.value = selectedId.value === id ? null : id
}

function loadSelectedProgression(prog) {
  // Apply saved settings
  harmonyStore.setKey(prog.key)
  harmonyStore.setTempo(prog.tempo)
  harmonyStore.setStylePreset(prog.style)
  harmonyStore.setVoicingStyle(prog.voicingStyle)
  harmonyStore.setGravity(prog.gravity)
  harmonyStore.setModulationProbability(prog.modulationProbability)

  // Load progression directly
  harmonyStore.progression = [...prog.progression]

  if (prog.progression.length > 0) {
    harmonyStore.currentChord = prog.progression[0].degree
  }

  close()
}

function deleteSelectedProgression(id) {
  if (confirm('¿Eliminar esta progresión?')) {
    deleteProgression(id)
    refreshList()
  }
}

function exportAll() {
  const json = exportAllProgressions()
  const blob = new Blob([json], { type: 'application/json' })
  const url = URL.createObjectURL(blob)

  const link = document.createElement('a')
  link.href = url
  link.download = `RameauJazz_progressions_${new Date().toISOString().slice(0, 10)}.json`
  link.click()

  URL.revokeObjectURL(url)
}

function importFromFile(event) {
  const file = event.target.files[0]
  if (!file) return

  const reader = new FileReader()
  reader.onload = (e) => {
    const count = importProgressions(e.target.result)
    if (count > 0) {
      refreshList()
      alert(`${count} progresiones importadas`)
    } else {
      alert('No se pudieron importar las progresiones')
    }
  }
  reader.readAsText(file)

  // Reset input
  event.target.value = ''
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
}

.modal-content {
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-lg);
  width: 90%;
  max-width: 600px;
  max-height: 80vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid var(--border-color);
}

.modal-header h2 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  color: var(--text-secondary);
  cursor: pointer;
  padding: 0;
  line-height: 1;
}

.close-btn:hover {
  color: var(--text-primary);
}

.modal-body {
  flex: 1;
  overflow-y: auto;
  padding: 16px 20px;
}

.save-section {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
}

.save-input {
  flex: 1;
  padding: 10px 14px;
  background: var(--bg-tertiary);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  color: var(--text-primary);
  font-size: 14px;
}

.save-input:focus {
  outline: none;
  border-color: var(--accent-blue);
}

.progressions-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 16px;
}

.empty-state {
  text-align: center;
  color: var(--text-muted);
  padding: 40px 20px;
}

.progression-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 14px;
  background: var(--bg-tertiary);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all 0.15s;
}

.progression-item:hover {
  border-color: var(--accent-blue);
}

.progression-item.selected {
  border-color: var(--accent-blue);
  background: rgba(88, 166, 255, 0.1);
}

.prog-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
  overflow: hidden;
}

.prog-name {
  font-weight: 600;
  color: var(--text-primary);
}

.prog-meta {
  font-size: 12px;
  color: var(--text-secondary);
}

.prog-chords {
  font-size: 11px;
  color: var(--text-muted);
  font-family: 'SF Mono', Monaco, monospace;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 400px;
}

.prog-actions {
  display: flex;
  gap: 6px;
}

.action-btn {
  width: 28px;
  height: 28px;
  border: none;
  border-radius: var(--radius-sm);
  cursor: pointer;
  font-size: 12px;
  transition: all 0.15s;
}

.action-btn.load {
  background: var(--accent-green);
  color: white;
}

.action-btn.load:hover {
  background: #2ea043;
}

.action-btn.delete {
  background: var(--bg-secondary);
  color: var(--text-secondary);
}

.action-btn.delete:hover {
  background: var(--accent-red);
  color: white;
}

.storage-info {
  font-size: 11px;
  color: var(--text-muted);
  text-align: center;
}

.modal-footer {
  display: flex;
  justify-content: center;
  gap: 12px;
  padding: 16px 20px;
  border-top: 1px solid var(--border-color);
}

.import-btn {
  cursor: pointer;
}
</style>
