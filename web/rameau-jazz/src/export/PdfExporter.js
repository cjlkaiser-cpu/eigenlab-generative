/**
 * PdfExporter.js - Export lead sheets in authentic Real Book style
 *
 * Features:
 * - Treble clef + key signature + time signature
 * - Chord symbols above staff (handwritten style)
 * - Slash notation for rhythm
 * - Professional layout like the original Real Book
 */

import { jsPDF } from 'jspdf'

// Page dimensions (Letter size in mm)
const PAGE = {
  width: 215.9,
  height: 279.4,
  marginLeft: 18,
  marginRight: 18,
  marginTop: 20,
  marginBottom: 15
}

// Staff configuration
const STAFF = {
  lineSpacing: 2.2,      // Space between staff lines
  height: 8.8,           // Total staff height (4 spaces)
  systemSpacing: 32,     // Space between systems
  barsPerLine: 4,
  clefWidth: 12,         // Space for clef + key sig + time sig
  barLinePadding: 3
}

// Colors
const INK = '#1a1a1a'
const GRAY = '#555555'

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

  // Style indicator (top left, in parentheses)
  doc.setFontSize(9)
  doc.setFont('times', 'italic')
  doc.setTextColor(GRAY)
  doc.text(`(${style} ♩=${tempo})`, PAGE.marginLeft, y)

  // Title - centered, bold, large
  doc.setFontSize(22)
  doc.setFont('times', 'bold')
  doc.setTextColor(INK)
  const titleText = title.toUpperCase()
  doc.text(titleText, PAGE.width / 2, y, { align: 'center' })

  // Composer - right aligned
  doc.setFontSize(10)
  doc.setFont('times', 'italic')
  doc.setTextColor(GRAY)
  doc.text(`- ${composer}`, PAGE.width - PAGE.marginRight, y, { align: 'right' })

  y += 4

  // Decorative double line under title
  const titleWidth = doc.getTextWidth(titleText)
  const lineStart = (PAGE.width - titleWidth) / 2 - 10
  const lineEnd = (PAGE.width + titleWidth) / 2 + 10

  doc.setDrawColor(INK)
  doc.setLineWidth(0.8)
  doc.line(lineStart, y, lineEnd, y)
  doc.setLineWidth(0.3)
  doc.line(lineStart, y + 1.5, lineEnd, y + 1.5)

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
  let currentX = x

  // Draw clef, key sig, time sig on first system
  if (isFirstSystem) {
    currentX = drawClefAndSignatures(doc, x, y, key)
  } else {
    // Just draw clef on subsequent systems
    currentX = drawTrebleClef(doc, x, y)
    currentX += 4
  }

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
    drawChordSymbol(doc, chord, measureX + 2, y - 4, key)

    // Draw slash notation
    drawSlashNotation(doc, measureX, y, barWidth)

    // Draw bar line at end of measure
    const barLineX = measureX + barWidth
    drawBarLine(doc, barLineX, y, isLastMeasure)

    // Draw measure number (every 4 measures or at start of line)
    if ((startMeasure + i) % 4 === 0 || i === 0) {
      doc.setFontSize(7)
      doc.setFont('helvetica', 'normal')
      doc.setTextColor(GRAY)
      doc.text(`${startMeasure + i + 1}`, measureX + 1, y + STAFF.height + 5)
      doc.setTextColor(INK)
    }
  }
}

/**
 * Draw treble clef, key signature, and time signature
 */
function drawClefAndSignatures(doc, x, y, key) {
  let currentX = x

  // Draw treble clef
  currentX = drawTrebleClef(doc, currentX, y)

  // Draw key signature
  currentX = drawKeySignature(doc, currentX, y, key)

  // Draw time signature (4/4)
  currentX = drawTimeSignature(doc, currentX, y)

  return currentX + 2
}

/**
 * Draw treble clef (stylized G clef)
 */
function drawTrebleClef(doc, x, y) {
  doc.setFontSize(28)
  doc.setFont('times', 'normal')
  doc.setTextColor(INK)

  // Use Unicode treble clef
  doc.text('𝄞', x, y + 6)

  return x + 8
}

/**
 * Draw key signature (sharps or flats)
 */
function drawKeySignature(doc, x, y, key) {
  const keySignatures = {
    'C': { sharps: 0, flats: 0 },
    'G': { sharps: 1, flats: 0 },
    'D': { sharps: 2, flats: 0 },
    'A': { sharps: 3, flats: 0 },
    'E': { sharps: 4, flats: 0 },
    'B': { sharps: 5, flats: 0 },
    'Gb': { sharps: 0, flats: 6 },
    'F': { sharps: 0, flats: 1 },
    'Bb': { sharps: 0, flats: 2 },
    'Eb': { sharps: 0, flats: 3 },
    'Ab': { sharps: 0, flats: 4 },
    'Db': { sharps: 0, flats: 5 }
  }

  const keySig = keySignatures[key] || { sharps: 0, flats: 0 }

  doc.setFontSize(14)
  doc.setFont('times', 'normal')

  // Sharp positions (F, C, G, D, A, E, B)
  const sharpYOffsets = [0, 3, -0.5, 2.5, 5.5, 1.5, 4.5]
  // Flat positions (B, E, A, D, G, C, F)
  const flatYOffsets = [4, 1, 4.5, 1.5, 5, 2, 5.5]

  let currentX = x

  if (keySig.sharps > 0) {
    for (let i = 0; i < keySig.sharps; i++) {
      const yOffset = sharpYOffsets[i] * (STAFF.lineSpacing / 2)
      doc.text('♯', currentX, y + yOffset + 2)
      currentX += 2.5
    }
  } else if (keySig.flats > 0) {
    for (let i = 0; i < keySig.flats; i++) {
      const yOffset = flatYOffsets[i] * (STAFF.lineSpacing / 2)
      doc.text('♭', currentX, y + yOffset + 2)
      currentX += 2.5
    }
  }

  return currentX + 2
}

/**
 * Draw time signature
 */
function drawTimeSignature(doc, x, y) {
  doc.setFontSize(14)
  doc.setFont('times', 'bold')
  doc.setTextColor(INK)

  // Draw 4/4
  doc.text('4', x + 1, y + 2.5)
  doc.text('4', x + 1, y + 6.5)

  return x + 6
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

  // Use Times for handwritten look
  doc.setFontSize(12)
  doc.setFont('times', 'italic')
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

  // Format quality for Real Book style
  quality = quality
    .replace('maj7', 'maj7')
    .replace('m7b5', '-7♭5')
    .replace('m7', '-7')
    .replace('m6', '-6')
    .replace('m9', '-9')
    .replace('dim7', '°7')
    .replace('7alt', '7alt')
    .replace('7b13', '7♭13')
    .replace('7b9', '7♭9')
    .replace('7#9', '7♯9')
    .replace('7#11', '7♯11')
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
