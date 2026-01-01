# EigenLab Generative

Plugins generativos para MuseScore 4. Generan notas y progresiones directamente en la partitura.

## Filosofia

```
eigenlab-instruments/     → Plugins de AUDIO (VST3/AU, JUCE/C++)
eigenlab-generative/      → Plugins de PARTITURA (MuseScore, QML/JS)
```

## Estado Actual

| Plugin | Version | Estado |
|--------|---------|--------|
| **RameauGenerator** | 0.2.0 | Funcional - SATB |

## Instalacion

```bash
# Copiar plugins al directorio de MuseScore
cp -r plugins/* ~/Documents/MuseScore4/Plugins/

# En MuseScore 4:
# Home → Complementos → Activar RameauGenerator
```

## RameauGenerator

Generador de progresiones armonicas basado en cadenas de Markov con gravedad tonal.

### Caracteristicas (v0.2.0)

- Generacion SATB en 4 pentagramas separados
- Cadenas de Markov con matriz de transicion empirica (Bach/Mozart)
- Gravedad tonal: control caos ↔ estructura
- Modos mayor y menor armonico
- Cadencia autentica (V-I) opcional
- Voice leading con evitacion de paralelas
- 10 tonalidades (C, G, D, A, E, B, F, Bb, Eb, Ab)

### Uso

1. Crear partitura SATB (4 pentagramas: Soprano, Alto, Tenor, Bajo)
2. Home → Complementos → RameauGenerator
3. Configurar tonalidad, modo, numero de acordes
4. Ajustar gravedad tonal (caotico ↔ estricto)
5. Click "Previsualizar" para ver progresion
6. Click "Generar" para escribir en partitura

### Limitaciones Conocidas

- Cifrado americano y grados romanos solo en preview (API MuseScore 4 pendiente)
- No soporta inversiones aun
- No genera ritmo variado (solo redondas)

## Arquitectura

```
eigenlab-generative/
├── plugins/
│   └── RameauGenerator/
│       ├── RameauGenerator.qml   # Plugin principal (todo inline)
│       ├── MarkovEngine.js       # Motor Markov (referencia)
│       ├── VoiceLeading.js       # Voice leading (referencia)
│       └── Chords.js             # Acordes (referencia)
├── README.md
├── ROADMAP.md
└── CLAUDE.md
```

> Nota: Los archivos .js son referencia. El codigo esta integrado en el .qml
> porque MuseScore 4.4 no carga imports externos correctamente.

## Roadmap

Ver [ROADMAP.md](ROADMAP.md) para el plan completo de desarrollo.

### Proximas versiones

- **v0.3** - Analisis armonico en partitura
- **v0.4** - Modo guitarra (tablatura + acordes)
- **v0.5** - Modo piano (gran staff optimizado)
- **v1.0** - Release estable con presets

## Tecnologias

- **QML** - UI declarativa de Qt/MuseScore
- **JavaScript ES7** - Logica del motor
- **MuseScore Plugin API 4.x** - Manipulacion de partitura

## Referencias

- [MuseScore Plugin API](https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/)
- [Rameau Machine](https://github.com/...) - App web origen del motor

## Licencia

MIT
