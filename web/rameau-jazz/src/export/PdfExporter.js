/**
 * PdfExporter.js - Export lead sheets in Real Book style
 *
 * Generates professional jazz lead sheets with:
 * - Title and metadata
 * - Chord symbols above staff
 * - Slash notation for rhythm
 * - 4 bars per line (configurable)
 * - Clean, minimalist design
 */

import { jsPDF } from 'jspdf'

// Page dimensions (Letter size in mm)
const PAGE_WIDTH = 215.9
const PAGE_HEIGHT = 279.4
const MARGIN_LEFT = 20
const MARGIN_RIGHT = 20
const MARGIN_TOP = 25
const MARGIN_BOTTOM = 20

// Staff dimensions
const STAFF_HEIGHT = 24
const STAFF_LINE_SPACING = 3
const STAFF_SPACING = 45 // Space between systems
const BARS_PER_LINE = 4

// Colors
const BLACK = '#000000'
const GRAY = '#666666'

/**
 * Main export function - generates Real Book style PDF
 */
export function exportToPdf({
  progression,
  title = 'Untitled',
  key = 'C',
  tempo = 120,
  style = 'Swing',
  composer = 'RameauJazz',
  barsPerLine = BARS_PER_LINE
}) {
  if (!progression || progression.length === 0) {
    throw new Error('No progression to export')
  }

  const doc = new jsPDF({
    orientation: 'portrait',
    unit: 'mm',
    format: 'letter'
  })

  // Set up fonts
  doc.setFont('helvetica')

  let y = MARGIN_TOP

  // Draw header
  y = drawHeader(doc, { title, key, tempo, style, composer }, y)

  // Calculate staff area
  const staffWidth = PAGE_WIDTH - MARGIN_LEFT - MARGIN_RIGHT
  const barWidth = staffWidth / barsPerLine

  // Draw chord chart
  y = drawChordChart(doc, progression, {
    startY: y,
    staffWidth,
    barWidth,
    barsPerLine
  })

  // Draw footer
  drawFooter(doc)

  return doc
}

/**
 * Draw the header (title, key, tempo, etc.)
 */
function drawHeader(doc, { title, key, tempo, style, composer }, startY) {
  let y = startY

  // Title - large, bold, centered
  doc.setFontSize(24)
  doc.setFont('helvetica', 'bold')
  doc.text(title.toUpperCase(), PAGE_WIDTH / 2, y, { align: 'center' })
  y += 8

  // Composer - right aligned, italic
  doc.setFontSize(10)
  doc.setFont('helvetica', 'italic')
  doc.text(composer, PAGE_WIDTH - MARGIN_RIGHT, y, { align: 'right' })
  y += 6

  // Key and tempo - left side
  doc.setFontSize(11)
  doc.setFont('helvetica', 'normal')

  const keyName = getKeyName(key)
  doc.text(`${keyName}`, MARGIN_LEFT, y)

  // Tempo with note symbol
  doc.text(`${style}  ♩= ${tempo}`, MARGIN_LEFT + 30, y)

  y += 12

  return y
}

/**
 * Draw the chord chart with staff lines and chord symbols
 */
function drawChordChart(doc, progression, { startY, staffWidth, barWidth, barsPerLine }) {
  let y = startY
  let measureIndex = 0
  const totalMeasures = progression.length

  while (measureIndex < totalMeasures) {
    // Check if we need a new page
    if (y + STAFF_SPACING > PAGE_HEIGHT - MARGIN_BOTTOM) {
      doc.addPage()
      y = MARGIN_TOP
    }

    // Draw one line (system) of measures
    const measuresInLine = Math.min(barsPerLine, totalMeasures - measureIndex)

    // Draw staff lines
    drawStaffLines(doc, MARGIN_LEFT, y, staffWidth, measuresInLine, barWidth)

    // Draw chords and slashes for each measure
    for (let i = 0; i < measuresInLine; i++) {
      const chord = progression[measureIndex + i]
      const x = MARGIN_LEFT + (i * barWidth)

      // Draw chord symbol
      drawChordSymbol(doc, chord, x + 2, y - 6)

      // Draw rhythm slashes
      drawSlashes(doc, x, y, barWidth)

      // Draw bar number (small, at bottom)
      if ((measureIndex + i) % 4 === 0) {
        doc.setFontSize(7)
        doc.setFont('helvetica', 'normal')
        doc.setTextColor(GRAY)
        doc.text(`${measureIndex + i + 1}`, x + 1, y + STAFF_HEIGHT + 4)
        doc.setTextColor(BLACK)
      }
    }

    // Draw final barline (double for last line)
    const isLastLine = measureIndex + measuresInLine >= totalMeasures
    drawBarline(doc, MARGIN_LEFT + (measuresInLine * barWidth), y, isLastLine)

    measureIndex += measuresInLine
    y += STAFF_SPACING
  }

  return y
}

/**
 * Draw 5-line staff with measure bars
 */
function drawStaffLines(doc, x, y, width, numMeasures, barWidth) {
  doc.setDrawColor(BLACK)
  doc.setLineWidth(0.3)

  // Draw 5 staff lines
  for (let i = 0; i < 5; i++) {
    const lineY = y + (i * STAFF_LINE_SPACING)
    doc.line(x, lineY, x + (numMeasures * barWidth), lineY)
  }

  // Draw bar lines
  for (let i = 0; i <= numMeasures; i++) {
    const barX = x + (i * barWidth)
    doc.line(barX, y, barX, y + (4 * STAFF_LINE_SPACING))
  }
}

/**
 * Draw chord symbol above staff
 */
function drawChordSymbol(doc, chord, x, y) {
  const degree = chord.degree
  const chordKey = chord.key

  // Convert degree to chord symbol
  const symbol = degreeToChordSymbol(degree, chordKey)

  doc.setFontSize(14)
  doc.setFont('helvetica', 'bold')
  doc.text(symbol, x, y)
}

/**
 * Draw 4 rhythm slashes in a measure
 */
function drawSlashes(doc, x, y, barWidth) {
  const slashWidth = 4
  const slashHeight = 8
  const spacing = (barWidth - 8) / 4

  doc.setLineWidth(1.5)
  doc.setDrawColor(BLACK)

  for (let i = 0; i < 4; i++) {
    const slashX = x + 6 + (i * spacing)
    const slashY = y + STAFF_LINE_SPACING // On second line from top

    // Draw slash (diagonal line)
    doc.line(
      slashX,
      slashY + slashHeight / 2,
      slashX + slashWidth,
      slashY - slashHeight / 2
    )
  }

  doc.setLineWidth(0.3)
}

/**
 * Draw barline (single or double)
 */
function drawBarline(doc, x, y, isDouble) {
  doc.setLineWidth(0.3)

  if (isDouble) {
    // Double barline at end
    doc.line(x - 2, y, x - 2, y + (4 * STAFF_LINE_SPACING))
    doc.setLineWidth(1)
    doc.line(x, y, x, y + (4 * STAFF_LINE_SPACING))
    doc.setLineWidth(0.3)
  }
}

/**
 * Draw footer with generation info
 */
function drawFooter(doc) {
  const y = PAGE_HEIGHT - MARGIN_BOTTOM + 5

  doc.setFontSize(8)
  doc.setFont('helvetica', 'italic')
  doc.setTextColor(GRAY)

  const date = new Date().toLocaleDateString('es', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })

  doc.text(`Generated by RameauJazz - ${date}`, PAGE_WIDTH / 2, y, { align: 'center' })
  doc.setTextColor(BLACK)
}

/**
 * Convert degree notation to chord symbol
 */
function degreeToChordSymbol(degree, key) {
  // Map key to note name
  const keyNotes = {
    'C': 'C', 'Db': 'Db', 'D': 'D', 'Eb': 'Eb', 'E': 'E', 'F': 'F',
    'Gb': 'Gb', 'G': 'G', 'Ab': 'Ab', 'A': 'A', 'Bb': 'Bb', 'B': 'B'
  }

  // Map degree roots to semitones from key
  const degreeRoots = {
    'I': 0, 'bII': 1, 'II': 2, 'bIII': 3, 'III': 4, 'IV': 5,
    '#IV': 6, 'bV': 6, 'V': 7, 'bVI': 8, 'VI': 9, 'bVII': 10, 'VII': 11
  }

  // Parse degree to get root and quality
  let rootDegree = ''
  let quality = ''

  // Handle complex degrees like "V7/ii", "bII7", "#IVdim7"
  const match = degree.match(/^(b|#)?(I{1,3}|IV|V|VI{0,2})(.*?)(?:\/.*)?$/)

  if (match) {
    const accidental = match[1] || ''
    const roman = match[2]
    quality = match[3] || ''

    rootDegree = accidental + roman
  } else {
    // Fallback - just use the degree as is
    return degree
  }

  // Calculate root note
  const keyIndex = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'].indexOf(key)
  const rootOffset = degreeRoots[rootDegree] ?? 0
  const noteIndex = (keyIndex + rootOffset) % 12
  const notes = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B']
  const rootNote = notes[noteIndex]

  // Format quality for display
  let displayQuality = quality
    .replace('maj7', 'maj7')
    .replace('m7b5', 'm7b5')
    .replace('m7', 'm7')
    .replace('m6', 'm6')
    .replace('dim7', '°7')
    .replace('7alt', '7alt')
    .replace('7b13', '7b13')
    .replace('7#11', '7#11')
    .replace('7sus4', '7sus')

  return rootNote + displayQuality
}

/**
 * Get full key name
 */
function getKeyName(key) {
  const keyNames = {
    'C': 'C Major', 'Db': 'Db Major', 'D': 'D Major', 'Eb': 'Eb Major',
    'E': 'E Major', 'F': 'F Major', 'Gb': 'Gb Major', 'G': 'G Major',
    'Ab': 'Ab Major', 'A': 'A Major', 'Bb': 'Bb Major', 'B': 'B Major'
  }
  return keyNames[key] || key
}

/**
 * Download PDF file
 */
export function downloadPdf(options) {
  const doc = exportToPdf(options)
  const filename = options.filename || generatePdfFilename(options.key, options.progression.length)
  doc.save(`${filename}.pdf`)
}

/**
 * Generate filename for PDF
 */
export function generatePdfFilename(key, numBars, title = 'RameauJazz') {
  const date = new Date().toISOString().slice(0, 10)
  const safeName = title.replace(/[^a-zA-Z0-9]/g, '_')
  return `${safeName}_${key}_${numBars}bars_${date}`
}

export default {
  exportToPdf,
  downloadPdf,
  generatePdfFilename
}
