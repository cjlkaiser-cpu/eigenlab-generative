# EigenLab Generative

Plugins generativos para MuseScore 4. Generan notas y progresiones directamente en la partitura.

## Filosofia

```
eigenlab-instruments/     → Plugins de AUDIO (VST3/AU, JUCE/C++)
eigenlab-generative/      → Plugins de PARTITURA (MuseScore, QML/JS)
```

## Plugins Disponibles

| Plugin | Version | Instrumento | Estado |
|--------|---------|-------------|--------|
| [RameauGenerator](plugins/RameauGenerator/) | 0.2.0 | SATB (4 voces) | Funcional |
| [RameauGuitar](plugins/RameauGuitar/) | 0.3.0 | Guitarra clasica | Funcional |
| [RameauPiano](plugins/RameauPiano/) | 0.3.0 | Piano (grand staff) | Funcional |

## Instalacion

```bash
# Copiar todos los plugins
cp -r plugins/* ~/Documents/MuseScore4/Plugins/

# O copiar individualmente
cp -r plugins/RameauGenerator ~/Documents/MuseScore4/Plugins/
cp -r plugins/RameauGuitar ~/Documents/MuseScore4/Plugins/
cp -r plugins/RameauPiano ~/Documents/MuseScore4/Plugins/

# Reiniciar MuseScore 4
# Home → Complementos → Activar los plugins deseados
```

---

## RameauGenerator (SATB)

Generador de progresiones a 4 voces para coro o cuarteto.

**Caracteristicas:**
- 4 pentagramas separados (Soprano, Alto, Tenor, Bajo)
- Cadenas de Markov con gravedad tonal
- Voice leading con evitacion de paralelas
- Hasta 32 acordes

**Uso:** Crear partitura con 4 pentagramas SATB

---

## RameauGuitar

Generador de progresiones para guitarra clasica.

**Caracteristicas:**
- Un solo pentagrama
- Voicings adaptados a guitarra (max 4 notas)
- Rango E2-E5
- Tonalidades guitarristicas: E, A, D, G, C, Am, Em, Dm
- **Validacion de voicings** (span <= 4 trastes)
- **Opciones de salida:** bloque, arpegio, patron p-i-m-a-m-i

**Uso:** Crear partitura de guitarra (1 pentagrama)

---

## RameauPiano

Generador de progresiones para piano.

**Caracteristicas:**
- Grand staff (2 pentagramas)
- LH: Bass + Tenor (clave de Fa)
- RH: Alto + Soprano (clave de Sol)
- Voice leading con minimo movimiento
- **Patrones LH:** Bloque, Alberti, Stride, Arpegios
- **Patrones RH:** Bloque, Arpegio, Melodía

**Uso:** Crear partitura de piano (grand staff)

---

## Arquitectura

```
eigenlab-generative/
├── plugins/
│   ├── RameauGenerator/
│   │   ├── RameauGenerator.qml
│   │   └── *.js (referencia)
│   ├── RameauGuitar/
│   │   ├── RameauGuitar.qml
│   │   └── README.md
│   └── RameauPiano/
│       ├── RameauPiano.qml
│       └── README.md
├── README.md
├── ROADMAP.md
└── CLAUDE.md
```

> **Nota:** Todo el codigo esta inline en los .qml porque MuseScore 4.4 no carga imports .js correctamente.

## Motor Comun

Todos los plugins comparten el mismo motor de Markov:

```javascript
// Matriz de transicion (fragmento)
'I':  { 'ii': 0.15, 'IV': 0.25, 'V': 0.30, 'vi': 0.15, ... }
'V':  { 'I': 0.70, 'vi': 0.14, ... }  // V→I dominante
```

**Caracteristicas comunes:**
- Gravedad tonal configurable (libre ↔ estricto)
- Modos mayor y menor
- Cadencia V-I opcional
- Preview antes de generar

## Roadmap

Ver [ROADMAP.md](ROADMAP.md) para el plan completo.

### Proximos pasos

| Plugin | Siguiente version |
|--------|-------------------|
| RameauGenerator | v0.3 - Honestidad en nombres |
| RameauGuitar | v0.4 - Posiciones CAGED |
| RameauPiano | v0.4 - Sincronizacion LH/RH |

### Plugins futuros

- **RameauAnalysis** - Analiza partituras existentes
- **RameauJazz** - Acordes de 7a, 9a, sustituciones

## Tecnologias

- **QML** - UI declarativa de Qt/MuseScore
- **JavaScript ES7** - Logica del motor
- **MuseScore Plugin API 4.x** - Manipulacion de partitura

## Referencias

- [MuseScore Plugin API](https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/)
- [Rameau Machine](https://github.com/...) - App web origen del motor

## Licencia

MIT
