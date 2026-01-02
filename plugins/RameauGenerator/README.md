# RameauGenerator

Generador de progresiones armónicas **SATB** (4 voces) para MuseScore 4.

## Estado

**Versión:** 0.2.0

## Características

### Implementado (v0.2.0)

- Motor de Markov con matrices de transición completas
- **Modo mayor**: I, ii, iii, IV, V, vi, vii°
- **Modo menor armónico**: i, ii°, III, iv, V, VI, vii°
- Gravedad tonal configurable (libre ↔ estricto)
- Voice leading SATB con evitación de paralelas (5as y 8vas)
- Cadencia auténtica V-I opcional al final
- 10 tonalidades: C, D, E, F, G, A, Bb, Eb, Am, Em
- Hasta 32 acordes por progresión
- Preview antes de generar
- Generación en 4 pentagramas separados

### Rangos Vocales (MIDI)

| Voz | Rango | Notas |
|-----|-------|-------|
| Soprano | 60-79 | C4 - G5 |
| Alto | 55-72 | G3 - C5 |
| Tenor | 48-65 | C3 - F4 |
| Bass | 40-57 | E2 - A3 |

## Uso

1. Abrir MuseScore 4
2. Crear partitura con **4 pentagramas** (SATB):
   - Pentagrama 1: Soprano (clave de Sol)
   - Pentagrama 2: Alto (clave de Sol)
   - Pentagrama 3: Tenor (clave de Sol 8vb o Fa)
   - Pentagrama 4: Bass (clave de Fa)
3. Home → Complementos → Rameau Generator
4. Seleccionar tonalidad y modo
5. Configurar número de acordes (4-32)
6. Ajustar gravedad tonal
7. Activar/desactivar cadencia final
8. Click "Previsualizar" para ver progresión
9. Click "Generar" para escribir en partitura

## Instalación

```bash
cp -r plugins/RameauGenerator ~/Documents/MuseScore4/Plugins/

# Reiniciar MuseScore y activar en Complementos
```

## Arquitectura

```
RameauGenerator/
└── RameauGenerator.qml    # Plugin completo (inline)
```

Todo el código está inline en el .qml debido a limitaciones de MuseScore 4.4 con imports externos.

## Motor de Markov

### Matriz de Transición (Mayor)

```javascript
'I':    { 'ii': 0.15, 'IV': 0.25, 'V': 0.30, 'vi': 0.15, ... }
'ii':   { 'V': 0.60, 'viio': 0.15, ... }
'V':    { 'I': 0.70, 'vi': 0.14, ... }  // Fuerte resolución a I
```

### Gravedad Tonal

El slider de gravedad modifica las probabilidades:
- **0 (Libre)**: Markov puro, cualquier progresión posible
- **0.5 (Tonal)**: Balance entre variedad y resolución
- **1 (Estricto)**: V→I muy frecuente, comportamiento cadencial

### Voice Leading

El algoritmo busca minimizar el movimiento total:
1. Cada voz busca la nota más cercana
2. Se evitan quintas y octavas paralelas
3. Se mantiene orden: Bass < Tenor < Alto < Soprano
4. La sensible (grado 7) tiende a resolver a tónica

## Roadmap

### v0.3.0 - Honestidad en nombres

- [ ] Renombrar "Gravedad" → "Resolución"
- [ ] Etiquetas claras: Libre / Tonal / Estricto
- [ ] Preset "Secuencia de quintas" (vi→ii→V→I)
- [ ] Preset "Cíclico" (I→V→vi→IV)

### v0.4.0 - Estructura de frase

- [ ] Consciencia de frase (4, 8, 16 compases)
- [ ] Semicadencias en mitad de frase
- [ ] Período: antecedente + consecuente

### v0.5.0 - Modulación

- [ ] Modulación al relativo, dominante, subdominante
- [ ] Pivot chords
- [ ] Indicador visual de modulación

### v0.6.0 - Acordes de 7a

- [ ] Toggle triadas / 7as
- [ ] V7 siempre disponible
- [ ] Voice leading con 4 notas

## Referencias

- [MuseScore Plugin API](https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/)
- Kostka & Payne - Tonal Harmony
- Bach Chorales Dataset (371 corales analizados)

## Changelog

- **01 ene 2026**: v0.2.0 - Voice leading con evitación de paralelas
- **01 ene 2026**: v0.1.0 - Versión inicial con Markov básico
