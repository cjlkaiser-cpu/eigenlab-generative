# RameauPiano

Generador de progresiones armonicas para **piano** en MuseScore 4.

## Estado

**Version:** 0.2.0

## Caracteristicas

### Implementado (v0.2.0)

- Motor de Markov con matrices de transicion (mismo que RameauSATB)
- Distribucion SATB en grand staff:
  - **Mano izquierda (LH)**: Bass + Tenor → Pentagrama 2 (clave de Fa)
  - **Mano derecha (RH)**: Alto + Soprano → Pentagrama 1 (clave de Sol)
- 14 tonalidades: C, G, D, A, E, F, Bb, Eb, Ab, Cm, Gm, Dm, Am, Em
- Gravedad tonal configurable
- Cadencia V-I opcional
- Hasta 32 acordes por progresion
- Voice leading con minimo movimiento entre acordes

#### Patrones Mano Izquierda (v0.2)

| Patron | Descripcion | Notas |
|--------|-------------|-------|
| **Bloque** | Bass+Tenor juntos (redonda) | 2 |
| **Bajo-Acorde** | Bajo solo, luego tenor | 2 |
| **Arpegio ↑** | Bajo a agudo | 2 |
| **Arpegio ↓** | Agudo a bajo | 2 |
| **Alberti** | Clasico 1-5-8-5 | 4 |
| **Stride** | Jazz/Ragtime bajo-acorde-8va-acorde | 4 |

Duraciones LH: Blanca, Negra, Corchea

### Limitaciones Actuales

- RH solo acordes en bloque (no patrones)
- Sin duplicacion de octavas
- Sin sincronizacion ritmica LH/RH avanzada

## Uso

1. Abrir MuseScore 4
2. Crear partitura de piano (grand staff, 2 pentagramas)
3. Home → Complementos → Rameau Piano
4. Seleccionar tonalidad y modo
5. Configurar numero de acordes
6. **Nuevo:** Elegir patron LH (Bloque, Alberti, Stride, etc.)
7. **Nuevo:** Si no es Bloque, elegir duracion LH
8. Click "Previsualizar" para ver progresion
9. Click "Generar" para escribir en partitura

## Instalacion

```bash
# Desde el directorio del proyecto
cp -r plugins/RameauPiano ~/Documents/MuseScore4/Plugins/

# Reiniciar MuseScore y activar en Complementos
```

## Arquitectura

```
RameauPiano/
├── RameauPiano.qml    # Plugin completo (inline)
└── README.md          # Esta documentacion
```

## Distribucion de Voces

```
┌─────────────────────────────────────┐
│  Mano Derecha (Clave Sol)           │
│  ├── Soprano (voz mas aguda)        │
│  └── Alto                           │
├─────────────────────────────────────┤
│  Mano Izquierda (Clave Fa)          │
│  ├── Tenor                          │
│  └── Bass (fundamental)             │
└─────────────────────────────────────┘
```

### Rangos

| Voz | Rango MIDI | Notas |
|-----|------------|-------|
| Bass | 36-55 | C2 - G3 |
| Tenor | 48-60 | C3 - C4 |
| Alto | 58-72 | Bb3 - C5 |
| Soprano | 64-79 | E4 - G5 |

## Patrones LH en Detalle

### Alberti Bass

Patron clasico usado por Mozart, Haydn, etc.

```
Patron: 1 - 5 - 8 - 5
        │   │   │   │
       Do  Sol Do' Sol
        ↓   ↓   ↓   ↓
       bajo 5ta 8va 5ta
```

### Stride

Patron de jazz/ragtime con salto bajo-acorde.

```
Patron: bajo - acorde - 8va - acorde
         │       │       │      │
        Do    Sol+Mi    Do'  Sol+Mi
         ↓       ↓       ↓      ↓
       grave   medio   agudo  medio
```

## Roadmap

### v0.3.0 - Patrones Mano Derecha

- [ ] Acordes bloque (actual)
- [ ] Melodia + acompanamiento
- [ ] Arpegio
- [ ] Broken chords

### v0.4.0 - Sincronizacion

- [ ] Coordinar duraciones LH/RH
- [ ] Patrones ritmicos combinados
- [ ] Compases completos

### v0.5.0 - Estilos

- [ ] Preset: Coral (acordes bloque ambas manos)
- [ ] Preset: Clasico (Alberti LH + melodia RH)
- [ ] Preset: Romantico (arpegios amplios)
- [ ] Preset: Pop (bajo + acordes)
- [ ] Preset: Jazz (stride + voicings)

### v0.6.0 - Acordes de 7a

- [ ] Toggle triadas / 7as
- [ ] Maj7, m7, dom7, dim7
- [ ] Distribucion de 7a entre manos

### v1.0.0 - Release

- [ ] Todos los patrones funcionando
- [ ] Presets de estilo
- [ ] Documentacion completa
- [ ] Sin crashes

## Notas Tecnicas

### Grand Staff en MuseScore

- Pentagrama 1 (RH): track 0
- Pentagrama 2 (LH): track 4

### Voice Leading

El algoritmo busca minimizar el movimiento total de las voces:
1. Cada voz busca la nota mas cercana a su posicion anterior
2. Se asegura orden correcto (bass < tenor < alto < soprano)
3. Se mantiene separacion minima entre voces adyacentes

## Referencias

- [MuseScore Plugin API](https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/)
- [RameauGenerator (SATB)](../RameauGenerator/) - Plugin base
- [RameauGuitar](../RameauGuitar/) - Plugin hermano

## Changelog

- **02 ene 2026**: v0.2.0 - Patrones LH (Bloque, Alberti, Stride, Arpegios)
- **01 ene 2026**: v0.1.0 - Version inicial con distribucion LH/RH basica
