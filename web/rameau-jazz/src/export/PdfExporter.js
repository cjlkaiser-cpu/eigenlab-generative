/**
 * PdfExporter.js - Export lead sheets in authentic Real Book style
 *
 * Features:
 * - Clean staff lines with proper spacing
 * - Chord symbols above staff
 * - Slash notation for rhythm
 * - Professional layout like the original Real Book
 */

import { jsPDF } from 'jspdf'

// Page dimensions (Letter size in mm)
const PAGE = {
  width: 215.9,
  height: 279.4,
  marginLeft: 20,
  marginRight: 20,
  marginTop: 25,
  marginBottom: 20
}

// Staff configuration
const STAFF = {
  lineSpacing: 2,        // Space between staff lines
  height: 8,             // Total staff height (4 spaces)
  systemSpacing: 28,     // Space between systems
  barsPerLine: 4,
  clefWidth: 8,          // Minimal space before first bar
  barLinePadding: 3
}

// Colors
const INK = '#000000'
const GRAY = '#666666'

/**
 * Main export function
 */
export function exportToPdf({
  progression,
  title = 'Untitled',
  key = 'C',
  tempo = 120,
  style = 'Swing',
  composer = 'RameauJazz',
  barsPerLine = 4
}) {
  if (!progression || progression.length === 0) {
    throw new Error('No progression to export')
  }

  const doc = new jsPDF({
    orientation: 'portrait',
    unit: 'mm',
    format: 'letter'
  })

  let y = PAGE.marginTop

  // Draw header
  y = drawHeader(doc, { title, style, composer, tempo }, y)

  // Calculate dimensions
  const contentWidth = PAGE.width - PAGE.marginLeft - PAGE.marginRight
  const barWidth = (contentWidth - STAFF.clefWidth) / barsPerLine

  // Draw systems
  y = drawAllSystems(doc, progression, {
    startY: y,
    contentWidth,
    barWidth,
    barsPerLine,
    key
  })

  // Draw footer
  drawFooter(doc)

  return doc
}

/**
 * Draw header with title and composer
 */
function drawHeader(doc, { title, style, composer, tempo }, startY) {
  let y = startY

  // Title - centered, bold, large
  doc.setFontSize(20)
  doc.setFont('helvetica', 'bold')
  doc.setTextColor(INK)
  doc.text(title, PAGE.width / 2, y, { align: 'center' })

  y += 6

  // Composer - centered under title
  doc.setFontSize(10)
  doc.setFont('helvetica', 'italic')
  doc.setTextColor(GRAY)
  doc.text(`${composer}`, PAGE.width / 2, y, { align: 'center' })

  y += 4

  // Style and tempo - centered
  doc.setFontSize(9)
  doc.setFont('helvetica', 'normal')
  doc.text(`${style} - ${tempo} BPM`, PAGE.width / 2, y, { align: 'center' })

  y += 10

  return y
}

/**
 * Draw all systems (lines of music)
 */
function drawAllSystems(doc, progression, { startY, contentWidth, barWidth, barsPerLine, key }) {
  let y = startY
  let measureIndex = 0
  const totalMeasures = progression.length
  let isFirstSystem = true

  while (measureIndex < totalMeasures) {
    // Check for page break
    if (y + STAFF.systemSpacing > PAGE.height - PAGE.marginBottom) {
      doc.addPage()
      y = PAGE.marginTop
      isFirstSystem = true
    }

    const measuresInLine = Math.min(barsPerLine, totalMeasures - measureIndex)
    const isLastSystem = measureIndex + measuresInLine >= totalMeasures

    // Draw one system
    drawSystem(doc, progression, {
      startMeasure: measureIndex,
      numMeasures: measuresInLine,
      x: PAGE.marginLeft,
      y: y,
      barWidth,
      key,
      isFirstSystem,
      isLastSystem
    })

    measureIndex += measuresInLine
    y += STAFF.systemSpacing
    isFirstSystem = false
  }

  return y
}

/**
 * Draw a single system (one line of music)
 */
function drawSystem(doc, progression, { startMeasure, numMeasures, x, y, barWidth, key, isFirstSystem, isLastSystem }) {
  let currentX = x + STAFF.clefWidth

  // Draw staff lines
  const staffWidth = numMeasures * barWidth
  drawStaffLines(doc, currentX, y, staffWidth)

  // Draw initial bar line
  drawBarLine(doc, currentX, y, false)

  // Draw each measure
  for (let i = 0; i < numMeasures; i++) {
    const measureX = currentX + (i * barWidth)
    const chord = progression[startMeasure + i]
    const isLastMeasure = isLastSystem && i === numMeasures - 1

    // Draw chord symbol above staff
    drawChordSymbol(doc, chord, measureX + 3, y - 3, key)

    // Draw slash notation
    drawSlashNotation(doc, measureX, y, barWidth)

    // Draw bar line at end of measure
    const barLineX = measureX + barWidth
    drawBarLine(doc, barLineX, y, isLastMeasure)
  }

  // Draw measure number at start of line
  doc.setFontSize(8)
  doc.setFont('helvetica', 'normal')
  doc.setTextColor(GRAY)
  doc.text(`${startMeasure + 1}`, x, y + STAFF.height / 2 + 1)
  doc.setTextColor(INK)
}


/**
 * Draw 5 staff lines
 */
function drawStaffLines(doc, x, y, width) {
  doc.setDrawColor(INK)
  doc.setLineWidth(0.2)

  for (let i = 0; i < 5; i++) {
    const lineY = y + (i * STAFF.lineSpacing)
    doc.line(x, lineY, x + width, lineY)
  }
}

/**
 * Draw bar line
 */
function drawBarLine(doc, x, y, isDouble) {
  doc.setDrawColor(INK)

  if (isDouble) {
    // Final double bar line
    doc.setLineWidth(0.3)
    doc.line(x - 2, y, x - 2, y + STAFF.height)
    doc.setLineWidth(1)
    doc.line(x, y, x, y + STAFF.height)
  } else {
    doc.setLineWidth(0.3)
    doc.line(x, y, x, y + STAFF.height)
  }
}

/**
 * Draw chord symbol
 */
function drawChordSymbol(doc, chord, x, y, globalKey) {
  const symbol = degreeToChordSymbol(chord.degree, chord.key || globalKey)

  doc.setFontSize(11)
  doc.setFont('helvetica', 'bold')
  doc.setTextColor(INK)
  doc.text(symbol, x, y)
}

/**
 * Draw slash notation (4 quarter note slashes)
 */
function drawSlashNotation(doc, x, y, barWidth) {
  const slashSpacing = (barWidth - 6) / 4
  const slashWidth = 3
  const slashHeight = STAFF.lineSpacing * 1.5

  doc.setLineWidth(1.2)
  doc.setDrawColor(INK)

  // Center slashes in middle of staff
  const centerY = y + STAFF.height / 2

  for (let i = 0; i < 4; i++) {
    const slashX = x + 4 + (i * slashSpacing)

    // Draw diagonal slash
    doc.line(
      slashX,
      centerY + slashHeight / 2,
      slashX + slashWidth,
      centerY - slashHeight / 2
    )
  }

  doc.setLineWidth(0.3)
}

/**
 * Convert degree to chord symbol
 */
function degreeToChordSymbol(degree, key) {
  const notes = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B']
  const keyIndex = notes.indexOf(key) || 0

  // Parse degree
  const degreeRoots = {
    'I': 0, 'bII': 1, 'II': 2, 'bIII': 3, 'III': 4, 'IV': 5,
    '#IV': 6, 'bV': 6, 'V': 7, 'bVI': 8, 'VI': 9, 'bVII': 10, 'VII': 11
  }

  // Extract root and quality from degree
  const match = degree.match(/^(b|#)?(I{1,3}|IV|V|VI{0,2})(.*?)(?:\/.*)?$/)

  if (!match) return degree

  const accidental = match[1] || ''
  const roman = match[2]
  let quality = match[3] || ''

  const rootDegree = accidental + roman
  const rootOffset = degreeRoots[rootDegree] ?? 0
  const noteIndex = (keyIndex + rootOffset) % 12
  const rootNote = notes[noteIndex]

  // Format quality - use ASCII only for PDF compatibility
  quality = quality
    .replace('maj7', 'maj7')
    .replace('m7b5', 'm7b5')
    .replace('m7', 'm7')
    .replace('m6', 'm6')
    .replace('m9', 'm9')
    .replace('dim7', 'dim7')
    .replace('7alt', '7alt')
    .replace('7b13', '7b13')
    .replace('7b9', '7b9')
    .replace('7#9', '7#9')
    .replace('7#11', '7#11')
    .replace('7sus4', '7sus')

  return rootNote + quality
}

/**
 * Draw footer
 */
function drawFooter(doc) {
  const y = PAGE.height - PAGE.marginBottom + 8

  doc.setFontSize(8)
  doc.setFont('times', 'italic')
  doc.setTextColor(GRAY)

  const date = new Date().toLocaleDateString('es', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })

  doc.text(`Generated by RameauJazz — ${date}`, PAGE.width / 2, y, { align: 'center' })
}

/**
 * Download PDF
 */
export function downloadPdf(options) {
  const doc = exportToPdf(options)
  const filename = options.filename || generatePdfFilename(options.key, options.progression.length)
  doc.save(`${filename}.pdf`)
}

/**
 * Generate filename
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
