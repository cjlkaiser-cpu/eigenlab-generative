<template>
  <div class="app-container">
    <!-- Header -->
    <header class="app-header">
      <h1 class="app-title">RameauJazz</h1>
      <div class="header-controls">
        <StylePresets />
        <div class="tempo-control">
          <span class="tempo-value">{{ harmonyStore.tempo }} BPM</span>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="app-main">
      <!-- Left: Circle of Fifths -->
      <aside class="sidebar-left">
        <CircleOfFifths />
      </aside>

      <!-- Center: Force Graph -->
      <section class="center-panel">
        <ForceGraph />
      </section>

      <!-- Right: Controls -->
      <aside class="sidebar-right">
        <div class="controls-stack">
          <KeySelector />
          <GravitySlider />
          <ModulationPanel />
          <VoicingSelector />
          <TensionMeter />
          <MixerPanel />
        </div>
      </aside>
    </main>

    <!-- Piano Roll -->
    <section class="piano-roll-section">
      <PianoRoll />
    </section>

    <!-- Transport Bar -->
    <footer class="app-footer">
      <TransportBar />
      <ProgressionDisplay />
    </footer>
  </div>
</template>

<script setup>
import { useHarmonyStore } from './stores/harmony'

// Components
import TransportBar from './components/TransportBar.vue'
import KeySelector from './components/KeySelector.vue'
import GravitySlider from './components/GravitySlider.vue'
import ModulationPanel from './components/ModulationPanel.vue'
import VoicingSelector from './components/VoicingSelector.vue'
import StylePresets from './components/StylePresets.vue'
import MixerPanel from './components/MixerPanel.vue'
import ProgressionDisplay from './components/ProgressionDisplay.vue'
import TensionMeter from './components/TensionMeter.vue'

// Visualization
import ForceGraph from './visualization/ForceGraph.vue'
import PianoRoll from './visualization/PianoRoll.vue'
import CircleOfFifths from './visualization/CircleOfFifths.vue'

const harmonyStore = useHarmonyStore()
</script>

<style scoped>
.app-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  max-height: 100vh;
  overflow: hidden;
}

.app-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 24px;
  background: var(--bg-secondary);
  border-bottom: 1px solid var(--border-color);
}

.app-title {
  font-size: 24px;
  font-weight: 700;
  background: linear-gradient(135deg, var(--accent-blue), var(--accent-purple));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.header-controls {
  display: flex;
  align-items: center;
  gap: 16px;
}

.tempo-control {
  background: var(--bg-tertiary);
  padding: 6px 12px;
  border-radius: var(--radius-md);
}

.tempo-value {
  font-family: 'SF Mono', Monaco, monospace;
  font-size: 14px;
  color: var(--text-secondary);
}

.app-main {
  flex: 1;
  display: grid;
  grid-template-columns: 200px 1fr 280px;
  gap: 16px;
  padding: 16px;
  overflow: hidden;
}

.sidebar-left,
.sidebar-right {
  display: flex;
  flex-direction: column;
}

.center-panel {
  min-height: 0;
  display: flex;
}

.controls-stack {
  display: flex;
  flex-direction: column;
  gap: 12px;
  overflow-y: auto;
}

.piano-roll-section {
  height: 180px;
  padding: 0 16px;
}

.app-footer {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 12px 24px;
  background: var(--bg-secondary);
  border-top: 1px solid var(--border-color);
}
</style>
