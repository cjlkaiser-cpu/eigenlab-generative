# RameauJazz Web App

Generador de progresiones armónicas jazz con motor de Markov, visualización interactiva y síntesis de audio en tiempo real.

![Vue.js](https://img.shields.io/badge/Vue.js-3.4-4FC08D?logo=vue.js)
![Tone.js](https://img.shields.io/badge/Tone.js-14.7-F734A3)
![D3.js](https://img.shields.io/badge/D3.js-7.8-F9A03C?logo=d3.js)
![Vite](https://img.shields.io/badge/Vite-5.0-646CFF?logo=vite)

## Características

### Motor de Armonía
- **38 grados de acordes jazz** - Diatónicos, dominantes secundarios, sustitutos tritonales, borrowed chords, Coltrane changes
- **Matriz de Markov** - Transiciones probabilísticas basadas en práctica común del jazz
- **Sistema de modulación** - 8 targets incluyendo ciclo Coltrane (Giant Steps)
- **Control de gravedad tonal** - Desde caos total hasta movimiento estricto funcional
- **5 estilos de voicing** - Shell, Drop2, Rootless A/B, Block

### Audio (Tone.js)
- **Piano FM** - Síntesis FM estilo Rhodes con tremolo, chorus y reverb
- **Walking Bass** - Generador de líneas de bajo caminante estilo Blue Note
- **Drummer** - Patrones de ride y hi-hat con swing variable
- **Tap Tempo** - Control de tempo interactivo
- **Swing ajustable** - 0% (straight) a 100% (full swing)

### Visualización
- **Force Graph (D3.js)** - Grafo force-directed de transiciones armónicas
  - Nodos = acordes (color por función: T/SD/D)
  - Links = transiciones (grosor por probabilidad)
  - Click para previsualizar acordes
- **Piano Roll (Canvas)** - Timeline visual de voicings
  - Piano vertical con teclas activas
  - Notas coloreadas por mano (izq/der)
  - Playhead animado
- **Círculo de Quintas** - Selector interactivo de tonalidad

### UI/UX
- Tema oscuro estilo GitHub
- Presets de estilo: Standard, Bebop, Bossa Nova, Modal, Ballad
- Mixer con volumen por instrumento
- Display de progresión con colores por función

## Stack Tecnológico

| Componente | Tecnología | Versión |
|------------|------------|---------|
| Framework UI | Vue.js 3 (Composition API) | 3.4+ |
| State Management | Pinia | 2.1+ |
| Audio | Tone.js | 14.7+ |
| Visualización | D3.js | 7.8+ |
| Build Tool | Vite | 5.0+ |

## Instalación

```bash
cd web/rameau-jazz
npm install
npm run dev
```

Abre http://localhost:3000 en tu navegador.

## Uso

1. **Generar progresión**: Click en "Generar" para crear 8 acordes
2. **Reproducir**: Click en Play para escuchar la progresión
3. **Ajustar tempo**:
   - Botones +/- para cambios de 5 BPM
   - Click en el display para tap tempo
   - Scroll wheel para ajuste fino
4. **Cambiar tonalidad**: Click en el Círculo de Quintas
5. **Explorar acordes**: Click en nodos del Force Graph para previsualizar
6. **Ajustar estilo**: Selecciona preset (Bebop, Bossa, etc.)

## Arquitectura

```
src/
├── main.js                 # Entry point
├── App.vue                 # Layout principal
├── stores/
│   └── harmony.js          # Estado global (Pinia)
├── engine/
│   ├── JazzDegrees.js      # 38 definiciones de acordes
│   ├── JazzTransitions.js  # Matriz de Markov
│   ├── ChordTypes.js       # Intervalos por tipo de acorde
│   ├── MarkovEngine.js     # Motor de selección probabilística
│   ├── ModulationSystem.js # Sistema de modulación (8 targets)
│   └── Voicings.js         # 5 estilos de voicing
├── audio/
│   ├── ToneSetup.js        # Configuración Tone.js
│   ├── JazzSynth.js        # Sintetizador FM (Rhodes-like)
│   ├── WalkingBass.js      # Generador de bajo caminante
│   ├── Drummer.js          # Patrones de batería
│   ├── AudioEngine.js      # Orquestador principal
│   └── index.js            # Exports
├── components/
│   ├── TransportBar.vue    # Play/Pause/Tempo/Swing
│   ├── KeySelector.vue     # Selector de tonalidad
│   ├── GravitySlider.vue   # Control de gravedad tonal
│   ├── ModulationPanel.vue # Controles de modulación
│   ├── VoicingSelector.vue # Selector de voicing
│   ├── StylePresets.vue    # Presets de estilo
│   ├── MixerPanel.vue      # Volumen por instrumento
│   ├── ProgressionDisplay.vue # Acordes generados
│   └── TensionMeter.vue    # Indicador de tensión
├── visualization/
│   ├── ForceGraph.vue      # D3 force-directed graph
│   ├── PianoRoll.vue       # Canvas piano roll
│   └── CircleOfFifths.vue  # Círculo de quintas SVG
└── styles/
    └── jazz-theme.css      # Variables CSS del tema
```

## Motor de Markov

### Grados de Acordes (38 total)

```javascript
// Diatónicos (7)
'Imaj7', 'IIm7', 'IIIm7', 'IVmaj7', 'V7', 'VIm7', 'VIIm7b5'

// Dominantes secundarios (6)
'V7/ii', 'V7/iii', 'V7/IV', 'V7/V', 'V7/vi'

// Sustitutos tritonales (6)
'bII7', 'bIII7', 'bV7', 'bVI7', 'bVII7'

// Borrowed chords (7)
'bIII', 'bVI', 'bVII', 'IVm7', 'bVImaj7', 'bVIImaj7'

// Acordes disminuidos (4)
'#Idim7', '#IIdim7', '#IVdim7', 'VIIdim7'

// Alterados y extensiones (8)
'V7alt', 'V7b9', 'V7#9', 'V7b13', 'IImaj7', 'bIImaj7'
```

### Funciones Armónicas

| Función | Color | Descripción |
|---------|-------|-------------|
| T (Tónica) | Verde | Resolución, estabilidad |
| SD (Subdominante) | Amarillo | Preparación, movimiento |
| D (Dominante) | Rojo | Tensión, necesita resolver |

### Targets de Modulación

| Target | Intervalo | Probabilidad | Nivel |
|--------|-----------|--------------|-------|
| Relativo menor | -3 | 20% | Básico |
| Dominante | +7 | 20% | Básico |
| Subdominante | +5 | 15% | Básico |
| Paralelo | 0 | 10% | Extendido |
| bVII | -2 | 8% | Extendido |
| 3ª mayor abajo | -4 | 8% | Coltrane |
| 3ª mayor arriba | +4 | 8% | Coltrane |
| Tritono | +6 | 5% | Coltrane |

## Audio Engine

### Señal de Audio

```
┌─────────────┐    ┌─────────┐    ┌────────┐    ┌──────────┐
│  FM Synth   │───▶│ Tremolo │───▶│ Chorus │───▶│  Reverb  │───┐
│  (Rhodes)   │    │  4Hz    │    │  0.3   │    │  2.5s    │   │
└─────────────┘    └─────────┘    └────────┘    └──────────┘   │
                                                                │
┌─────────────┐    ┌─────────┐    ┌────────┐                   │
│  MonoSynth  │───▶│ Filter  │───▶│ Reverb │───────────────────┤
│  (Bass)     │    │ Lowpass │    │  1.5s  │                   │
└─────────────┘    └─────────┘    └────────┘                   │
                                                                │
┌─────────────┐                                                │   ┌────────────┐
│ MetalSynth  │────────────────────────────────────────────────┼──▶│ Compressor │──▶ Output
│  (Drums)    │                                                │   └────────────┘
└─────────────┘                                                │
```

### Walking Bass Algorithm

```
Beat 1: Root (raíz del acorde)
Beat 2: Passing tone (escalar, arpegio o cromático)
Beat 3: Target (5ª o 3ª) - swing triplet opcional
Beat 4: Chromatic approach al siguiente root
```

## Desarrollo

```bash
# Desarrollo con hot reload
npm run dev

# Build de producción
npm run build

# Preview del build
npm run preview
```

## Créditos

- Basado en el motor de [RameauJazz](../../../plugins/RameauJazz) para MuseScore
- Inspirado en [Rameau Machine](https://github.com/...) (proyecto original)
- Teoría armónica: Jean-Philippe Rameau, *Traité de l'harmonie* (1722)
- Coltrane Changes: John Coltrane, *Giant Steps* (1960)

## Licencia

MIT License - Ver [LICENSE](../../LICENSE)
