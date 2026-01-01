# EigenLab Generative

Plugins generativos para MuseScore 4. Generan notas y progresiones directamente en la partitura.

## Filosofia

```
eigenlab-instruments/     → Plugins de AUDIO (VST3/AU, JUCE/C++)
eigenlab-generative/      → Plugins de PARTITURA (MuseScore, QML/JS)
```

Los plugins de `eigenlab-instruments` generan sonido en DAWs.
Los plugins de `eigenlab-generative` generan notas en MuseScore.

## Plugins

| Plugin | Descripcion | Estado |
|--------|-------------|--------|
| **RameauGenerator** | Genera progresiones armonicas SATB con cadenas de Markov | En desarrollo |

## Instalacion

### MuseScore 4.4+

```bash
# Copiar plugins al directorio de MuseScore
cp -r plugins/* ~/Documents/MuseScore4/Plugins/

# Reiniciar MuseScore y habilitar en:
# Menu → Plugins → Manage Plugins
```

## Arquitectura

```
eigenlab-generative/
├── plugins/
│   └── RameauGenerator/
│       ├── RameauGenerator.qml      # Plugin principal
│       ├── MarkovEngine.js          # Motor de Markov (de Rameau Machine)
│       ├── VoiceLeading.js          # Reglas SATB
│       ├── Chords.js                # Definiciones de acordes
│       └── manifest.json            # Metadatos del plugin
├── README.md
└── CLAUDE.md
```

## RameauGenerator

Basado en el motor de [Rameau Machine](../EigenLab/Physics/Physics%20Sound%20Lab/generativos/rameau-machine/), genera progresiones armonicas usando:

- **Cadenas de Markov** con matriz de transicion por grado
- **Gravedad tonal** que modifica probabilidades segun tension
- **Voice Leading SATB** estricto (evita paralelas, cruces)
- **Cadencias** detectadas y forzadas (autentica, plagal, rota)

### Uso

1. Crear partitura con 4 pentagramas (SATB) o Grand Staff
2. Seleccionar compases vacios
3. Ejecutar plugin: Menu → Plugins → EigenLab → Rameau Generator
4. Configurar: tonalidad, numero de acordes, estilo
5. Click "Generar"

### Parametros

| Parametro | Descripcion | Valores |
|-----------|-------------|---------|
| Tonalidad | Clave de la progresion | C, G, D, F, Bb, etc. |
| Modo | Mayor o menor | major, minor |
| Acordes | Numero de acordes a generar | 4-32 |
| Gravedad | Control caos/estructura | 0.0 (caos) - 1.0 (estricto) |
| Estilo | Reglas de voice leading | barroco, clasico, romantico, jazz |

## Roadmap

### v0.1 - MVP
- [ ] Generar progresion basica I-IV-V-I
- [ ] Voice leading SATB funcional
- [ ] UI minima (tonalidad, # acordes)

### v0.2 - Markov completo
- [ ] Matriz de transicion completa (7 grados)
- [ ] Gravedad tonal dinamica
- [ ] Modo menor

### v0.3 - Cadencias
- [ ] Detectar/forzar cadencias
- [ ] Semicadencias
- [ ] Cadencia rota (deceptiva)

### v1.0 - Release
- [ ] Presets de estilo
- [ ] Exportar configuracion
- [ ] Documentacion completa

## Tecnologias

- **QML** - Framework de UI de MuseScore
- **JavaScript ES7** - Logica del motor
- **MuseScore Plugin API** - Manipulacion de partitura

## Relacionados

- [Rameau Machine](../EigenLab/Physics/Physics%20Sound%20Lab/generativos/rameau-machine/) - App web generativa (origen del motor)
- [Contrapunctus](../EigenLab/Physics/Physics%20Sound%20Lab/generativos/contrapunctus/) - Ejercicios de contrapunto
- [eigenlab-instruments](../eigenlab-instruments/) - Plugins de audio VST3/AU

## Licencia

MIT
