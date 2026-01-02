<template>
  <div class="force-graph-container panel">
    <svg ref="svgRef" :width="width" :height="height"></svg>
    <div class="graph-legend">
      <span class="legend-item"><span class="dot tonic"></span>Tonica</span>
      <span class="legend-item"><span class="dot subdominant"></span>Subdominante</span>
      <span class="legend-item"><span class="dot dominant"></span>Dominante</span>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch, computed } from 'vue'
import * as d3 from 'd3'
import { useHarmonyStore } from '../stores/harmony'
import { JAZZ_DEGREES, HARMONIC_FUNCTIONS } from '../engine/JazzDegrees.js'
import { JAZZ_TRANSITIONS } from '../engine/JazzTransitions.js'

const harmonyStore = useHarmonyStore()
const svgRef = ref(null)

const width = ref(400)
const height = ref(300)

// D3 elements
let svg = null
let simulation = null
let nodeGroup = null
let linkGroup = null

// Data
const nodes = ref([])
const links = ref([])

// Colores por funcion
const functionColors = {
  'T': '#3fb950',      // Tonica - verde
  'SD': '#d29922',     // Subdominante - amarillo
  'D': '#f85149',      // Dominante - rojo
  'secD': '#ff7070',   // Dominante secundario
  'secSD': '#ffaa70',  // Subdominante secundario
  'pass': '#a371f7',   // Paso - morado
  'coltrane': '#58a6ff' // Coltrane - azul
}

// Grados mas comunes para mostrar (no todos los 38)
const commonDegrees = [
  'Imaj7', 'IIm7', 'IIIm7', 'IVmaj7', 'V7', 'VIm7', 'VIIm7b5',
  'bII7', 'V7/ii', 'V7/V', '#Idim7', '#IVdim7',
  'bVImaj7', 'IVm7', 'V7alt'
]

onMounted(() => {
  initGraph()
  updateSize()
  window.addEventListener('resize', updateSize)
})

onUnmounted(() => {
  window.removeEventListener('resize', updateSize)
  if (simulation) simulation.stop()
})

// Watch for chord changes
watch(() => harmonyStore.currentChord, (newChord) => {
  highlightNode(newChord)
})

// Watch for progression changes
watch(() => harmonyStore.progression, () => {
  updateActiveLinks()
}, { deep: true })

function updateSize() {
  if (!svgRef.value) return
  const container = svgRef.value.parentElement
  width.value = container.clientWidth
  height.value = container.clientHeight - 40 // Account for legend

  if (simulation) {
    simulation.force('center', d3.forceCenter(width.value / 2, height.value / 2))
    simulation.force('x', d3.forceX(width.value / 2).strength(0.05))
    simulation.force('y', d3.forceY(height.value / 2).strength(0.05))
    simulation.alpha(0.5).restart()
  }
}

function initGraph() {
  if (!svgRef.value) return

  svg = d3.select(svgRef.value)
  svg.selectAll('*').remove()

  // Crear grupos
  linkGroup = svg.append('g').attr('class', 'links')
  nodeGroup = svg.append('g').attr('class', 'nodes')

  // Preparar datos
  prepareData()

  // Crear simulacion - más esparcida y centrada
  simulation = d3.forceSimulation(nodes.value)
    .force('link', d3.forceLink(links.value)
      .id(d => d.id)
      .distance(100)
      .strength(0.3))
    .force('charge', d3.forceManyBody().strength(-400))
    .force('center', d3.forceCenter(width.value / 2, height.value / 2))
    .force('collision', d3.forceCollide().radius(40))
    .force('x', d3.forceX(width.value / 2).strength(0.05))
    .force('y', d3.forceY(height.value / 2).strength(0.05))

  // Dibujar
  drawLinks()
  drawNodes()

  // Actualizar posiciones
  simulation.on('tick', () => {
    linkGroup.selectAll('line')
      .attr('x1', d => d.source.x)
      .attr('y1', d => d.source.y)
      .attr('x2', d => d.target.x)
      .attr('y2', d => d.target.y)

    nodeGroup.selectAll('.node')
      .attr('transform', d => `translate(${d.x},${d.y})`)
  })

  // Highlight inicial
  highlightNode(harmonyStore.currentChord)
}

function prepareData() {
  // Nodos: grados comunes
  nodes.value = commonDegrees.map(degree => {
    const info = JAZZ_DEGREES[degree]
    return {
      id: degree,
      label: degree,
      func: info?.func || 'T',
      tension: info?.tension || 0,
      color: functionColors[info?.func] || '#ffffff'
    }
  })

  // Links: transiciones entre grados visibles
  links.value = []
  const nodeIds = new Set(commonDegrees)

  commonDegrees.forEach(from => {
    const transitions = JAZZ_TRANSITIONS[from]
    if (!transitions) return

    Object.entries(transitions).forEach(([to, prob]) => {
      if (nodeIds.has(to) && prob > 0.05) { // Solo mostrar transiciones significativas
        links.value.push({
          source: from,
          target: to,
          probability: prob,
          active: false
        })
      }
    })
  })
}

function drawLinks() {
  linkGroup.selectAll('line')
    .data(links.value)
    .join('line')
    .attr('stroke', '#30363d')
    .attr('stroke-width', d => Math.max(1, d.probability * 5))
    .attr('stroke-opacity', 0.4)
    .attr('class', 'link')
}

function drawNodes() {
  const nodeEnter = nodeGroup.selectAll('.node')
    .data(nodes.value)
    .join('g')
    .attr('class', 'node')
    .call(drag(simulation))
    .on('click', (event, d) => {
      // Preview chord on click
      harmonyStore.previewChord(d.id, harmonyStore.key)
    })

  // Circulo de fondo - más grande
  nodeEnter.append('circle')
    .attr('r', d => 22 + d.tension * 8)
    .attr('fill', d => d.color)
    .attr('fill-opacity', 0.15)
    .attr('stroke', d => d.color)
    .attr('stroke-width', 2.5)
    .attr('class', 'node-circle')

  // Texto - más grande
  nodeEnter.append('text')
    .text(d => d.label)
    .attr('text-anchor', 'middle')
    .attr('dy', '0.35em')
    .attr('fill', '#e6edf3')
    .attr('font-size', '11px')
    .attr('font-weight', '600')
    .attr('pointer-events', 'none')
}

function highlightNode(chordId) {
  if (!nodeGroup) return

  // Reset all nodes
  nodeGroup.selectAll('.node-circle')
    .attr('fill-opacity', 0.2)
    .attr('stroke-width', 2)

  // Highlight active node
  nodeGroup.selectAll('.node')
    .filter(d => d.id === chordId)
    .select('.node-circle')
    .attr('fill-opacity', 0.6)
    .attr('stroke-width', 4)

  // Highlight outgoing links
  if (linkGroup) {
    linkGroup.selectAll('line')
      .attr('stroke', d => d.source.id === chordId ? '#58a6ff' : '#30363d')
      .attr('stroke-opacity', d => d.source.id === chordId ? 0.8 : 0.4)
  }
}

function updateActiveLinks() {
  if (!linkGroup || harmonyStore.progression.length < 2) return

  const activeTransitions = new Set()

  // Mark transitions used in current progression
  for (let i = 0; i < harmonyStore.progression.length - 1; i++) {
    const from = harmonyStore.progression[i].degree
    const to = harmonyStore.progression[i + 1].degree
    activeTransitions.add(`${from}->${to}`)
  }

  linkGroup.selectAll('line')
    .attr('stroke', d => {
      const key = `${d.source.id || d.source}->${d.target.id || d.target}`
      return activeTransitions.has(key) ? '#58a6ff' : '#30363d'
    })
    .attr('stroke-opacity', d => {
      const key = `${d.source.id || d.source}->${d.target.id || d.target}`
      return activeTransitions.has(key) ? 0.9 : 0.3
    })
}

// Drag behavior
function drag(simulation) {
  function dragstarted(event) {
    if (!event.active) simulation.alphaTarget(0.3).restart()
    event.subject.fx = event.subject.x
    event.subject.fy = event.subject.y
  }

  function dragged(event) {
    event.subject.fx = event.x
    event.subject.fy = event.y
  }

  function dragended(event) {
    if (!event.active) simulation.alphaTarget(0)
    event.subject.fx = null
    event.subject.fy = null
  }

  return d3.drag()
    .on('start', dragstarted)
    .on('drag', dragged)
    .on('end', dragended)
}
</script>

<style scoped>
.force-graph-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-height: 0;
  overflow: hidden;
}

.force-graph-container svg {
  flex: 1;
  min-height: 0;
  cursor: grab;
}

.force-graph-container svg:active {
  cursor: grabbing;
}

.graph-legend {
  display: flex;
  justify-content: center;
  gap: 16px;
  padding: 8px;
  font-size: 11px;
  color: var(--text-secondary);
  border-top: 1px solid var(--border-color);
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 4px;
}

.dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
}

.dot.tonic { background: #3fb950; }
.dot.subdominant { background: #d29922; }
.dot.dominant { background: #f85149; }

:deep(.node) {
  cursor: pointer;
}

:deep(.node:hover .node-circle) {
  fill-opacity: 0.5 !important;
}
</style>
