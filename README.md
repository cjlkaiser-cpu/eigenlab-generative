# EigenLab Generative

Plugins generativos para MuseScore 4. Generan notas y progresiones directamente en la partitura.

## Filosofía

```
eigenlab-instruments/     → Plugins de AUDIO (VST3/AU, JUCE/C++)
eigenlab-generative/      → Plugins de PARTITURA (MuseScore, QML/JS)
```

## Plugins Disponibles

| Plugin | Versión | Instrumento | Estado |
|--------|---------|-------------|--------|
| [RameauGenerator](plugins/RameauGenerator/) | 0.2.0 | SATB (4 voces) | Funcional |
| [RameauGuitar](plugins/RameauGuitar/) | 0.3.0 | Guitarra clásica | Funcional |
| [RameauPiano](plugins/RameauPiano/) | 0.3.0 | Piano (grand staff) | Funcional |
| [RameauJazz](plugins/RameauJazz/) | 0.7.0 | Piano jazz | Funcional |

## Instalación

```bash
# Copiar todos los plugins
cp -r plugins/* ~/Documents/MuseScore4/Plugins/

# O copiar individualmente
cp -r plugins/RameauGenerator ~/Documents/MuseScore4/Plugins/
cp -r plugins/RameauGuitar ~/Documents/MuseScore4/Plugins/
cp -r plugins/RameauPiano ~/Documents/MuseScore4/Plugins/
cp -r plugins/RameauJazz ~/Documents/MuseScore4/Plugins/

# Reiniciar MuseScore 4
# Home → Complementos → Activar los plugins deseados
```

---

## RameauGenerator (SATB)

Generador de progresiones a 4 voces para coro o cuarteto.

**Características:**
- 4 pentagramas separados (Soprano, Alto, Tenor, Bajo)
- Cadenas de Markov con gravedad tonal
- Voice leading con evitación de paralelas
- Modo mayor y menor armónico
- Hasta 32 acordes

**Uso:** Crear partitura con 4 pentagramas SATB

---

## RameauGuitar

Generador de progresiones para guitarra clásica.

**Características:**
- Un solo pentagrama
- Voicings adaptados a guitarra (max 4 notas)
- Rango E2-E5
- Tonalidades guitarrísticas: E, A, D, G, C, Am, Em, Dm
- Validación de voicings (span ≤ 4 trastes)
- Opciones de salida: bloque, arpegio, patrón p-i-m-a-m-i

**Uso:** Crear partitura de guitarra (1 pentagrama)

---

## RameauPiano

Generador de progresiones para piano.

**Características:**
- Grand staff (2 pentagramas)
- LH: Bass + Tenor (clave de Fa)
- RH: Alto + Soprano (clave de Sol)
- Voice leading con mínimo movimiento
- Patrones LH: Bloque, Alberti, Stride, Arpegios
- Patrones RH: Bloque, Arpegio, Melodía

**Uso:** Crear partitura de piano (grand staff)

---

## RameauJazz

Generador de progresiones jazz con acordes de 7ª, 9ª y sustituciones.

**Características:**
- 38 tipos de acordes: maj7, m7, 7, m7b5, dim7, 9, 13, 7alt
- Progresiones ii-V-I con sustituciones (bII7)
- Dominantes secundarios (V7/ii, V7/V, etc.)
- Voicings: Shell, Drop 2, Rootless A/B, Block
- Walking bass con 4 patrones (Blue Note, Oleaje, Escalar, Cromático)
- Comping RH: Charleston, Anticipation, Syncopated
- Presets: Standard, Bebop, Bossa Nova, Modal, Ballad
- Sistema de modulación con 8 targets (incluyendo Coltrane changes)

**Uso:** Crear partitura de piano (grand staff)

---

## Arquitectura

```
eigenlab-generative/
├── plugins/
│   ├── RameauGenerator/
│   │   ├── RameauGenerator.qml
│   │   └── README.md
│   ├── RameauGuitar/
│   │   ├── RameauGuitar.qml
│   │   └── README.md
│   ├── RameauPiano/
│   │   ├── RameauPiano.qml
│   │   └── README.md
│   └── RameauJazz/
│       ├── RameauJazz.qml
│       └── README.md
├── README.md
├── ROADMAP.md
└── CLAUDE.md
```

> **Nota:** Todo el código está inline en los .qml porque MuseScore 4.4 no carga imports .js correctamente.

## Motor Común

Todos los plugins comparten el mismo motor de Markov:

```javascript
// Matriz de transición (fragmento)
'I':  { 'ii': 0.15, 'IV': 0.25, 'V': 0.30, 'vi': 0.15, ... }
'V':  { 'I': 0.70, 'vi': 0.14, ... }  // V→I dominante
```

**Características comunes:**
- Gravedad tonal configurable (libre ↔ estricto)
- Modos mayor y menor
- Cadencia V-I opcional
- Preview antes de generar

## Roadmap

Ver [ROADMAP.md](ROADMAP.md) para el plan completo de desarrollo.

## Relacionados

- **[RameauJazz Web](https://github.com/cjlkaiser-cpu/rameau-jazz-web)** - Webapp generativa con Vue.js + Tone.js (audio en tiempo real, visualización D3.js)

## Tecnologías

- **QML** - UI declarativa de Qt/MuseScore
- **JavaScript ES7** - Lógica del motor
- **MuseScore Plugin API 4.x** - Manipulación de partitura

## Referencias

- [MuseScore Plugin API](https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/)
- [Plugins for 4.x](https://musescore.org/en/node/337468)

## Licencia

MIT
