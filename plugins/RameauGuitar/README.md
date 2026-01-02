# RameauGuitar

Generador de progresiones armonicas para **guitarra clasica** en MuseScore 4.

## Estado

**Version:** 0.3.0

## Caracteristicas

### Implementado (v0.3.0)

- Motor de Markov con matrices de transicion (mismo que RameauSATB)
- Voicings adaptados a guitarra clasica
- Rango E2 (40) - E5 (76)
- Maximo 4 notas por acorde
- Un solo pentagrama (clave de Sol 8vb)
- 8 tonalidades optimizadas para guitarra: E, A, D, G, C, Am, Em, Dm
- Gravedad tonal configurable
- Cadencia V-I opcional
- Hasta 16 acordes por progresion

#### Validacion de Voicings (v0.2)

- Verificacion de span maximo (4 trastes)
- Algoritmo de asignacion de cuerdas
- Deteccion de voicings imposibles fisicamente
- Fallback a posiciones alternativas (abierta, II, V, VII)
- Preferencia por cuerdas al aire

#### Opciones de Salida (v0.3)

- **Bloque**: Acordes completos (redondas)
- **Arpegio ascendente**: p-i-m-a (bajo a agudo)
- **Arpegio descendente**: a-m-i-p (agudo a bajo)
- **Patron p-i-m-a-m-i**: Patron clasico de 6 notas
- Selector de duracion: negra, corchea, semicorchea

### Limitaciones Actuales

- No calcula posiciones de mano izquierda visualmente
- No genera diagramas de acordes
- No genera tablatura
- No minimiza cambios de posicion entre acordes

## Uso

1. Abrir MuseScore 4
2. Crear o abrir partitura de guitarra (1 pentagrama)
3. Home → Complementos → Rameau Guitar
4. Seleccionar tonalidad (E, A, D recomendadas)
5. Configurar numero de acordes
6. **Nuevo:** Elegir tipo de salida (bloque/arpegio)
7. **Nuevo:** Si es arpegio, elegir duracion base
8. Click "Previsualizar" para ver progresion
9. Click "Generar" para escribir en partitura

## Instalacion

```bash
# Desde el directorio del proyecto
cp -r plugins/RameauGuitar ~/Documents/MuseScore4/Plugins/

# Reiniciar MuseScore y activar en Complementos
```

## Arquitectura

```
RameauGuitar/
├── RameauGuitar.qml    # Plugin completo (inline)
└── README.md           # Esta documentacion
```

El plugin tiene todo el codigo inline (sin imports externos) debido a limitaciones de MuseScore 4.4 con carga de archivos .js.

## Algoritmo de Validacion de Voicings

```
1. Asignar cada nota MIDI a una cuerda
   - De grave a aguda
   - Una nota por cuerda maximo

2. Calcular traste de cada nota
   - fret = midi - openString

3. Verificar span
   - Ignorar cuerdas al aire (fret 0)
   - span = maxFret - minFret
   - Valido si span <= 4

4. Si invalido, buscar posicion alternativa
   - Probar: abierta (0-4), II (2-5), V (5-9), VII (7-11)
   - Usar primera posicion valida

5. Fallback: power chord simplificado
```

## Roadmap

### v0.4.0 - Posiciones

- [ ] Calcular posicion de mano izquierda (traste base)
- [ ] Mostrar posicion en la UI
- [ ] Minimizar cambios de posicion entre acordes
- [ ] Posiciones CAGED basicas

### v0.5.0 - Diagramas de Acordes

- [ ] Generar diagrama de trastes sobre la partitura
- [ ] Mostrar dedos (1-4) en cada cuerda
- [ ] Indicar cejilla cuando aplique
- [ ] Indicar cuerdas que no se tocan (X)

### v0.6.0 - Tablatura

- [ ] Generar tab simultanea con partitura
- [ ] Asignacion optima de cuerdas
- [ ] Indicar tecnicas (hammer-on, pull-off)

### v0.7.0 - Patrones Avanzados

- [ ] Tremolo
- [ ] Rasgueado basico
- [ ] Ritmos tipicos (bossa, vals, habanera)

### v1.0.0 - Release

- [ ] Biblioteca de voicings comunes
- [ ] Presets de estilo (Clasico, Flamenco, Bossa)
- [ ] Documentacion completa

## Notas Tecnicas

### Rango de Guitarra

| Cuerda | Nota al aire | MIDI | Max traste |
|--------|--------------|------|------------|
| 6 (grave) | E2 | 40 | 12 |
| 5 | A2 | 45 | 12 |
| 4 | D3 | 50 | 12 |
| 3 | G3 | 55 | 12 |
| 2 | B3 | 59 | 12 |
| 1 (aguda) | E4 | 64 | 12 |

Rango total: E2 (40) - E5 (76)

### Tonalidades Recomendadas

| Tonalidad | Cuerdas al aire | Dificultad |
|-----------|-----------------|------------|
| E mayor | 6, 2, 1 | Facil |
| A mayor | 5, 1 | Facil |
| D mayor | 4, 1 | Facil |
| G mayor | 6, 3, 1 | Media |
| C mayor | 5 | Media |
| Em | 6, 2, 1 | Facil |
| Am | 5, 1 | Facil |
| Dm | 4, 1 | Media |

### Patrones de Arpegio

| Patron | Dedos | Notas | Uso |
|--------|-------|-------|-----|
| Ascendente | p-i-m-a | 4 | Acompanamiento simple |
| Descendente | a-m-i-p | 4 | Variacion |
| Completo | p-i-m-a-m-i | 6 | Clasico (Tarrega, Sor) |

## Referencias

- [MuseScore Plugin API](https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/)
- [RameauGenerator (SATB)](../RameauGenerator/) - Plugin base

## Changelog

- **02 ene 2026**: v0.3.0 - Opciones de salida (bloque, arpegios, patron p-i-m-a-m-i)
- **02 ene 2026**: v0.2.0 - Validacion de voicings tocables (span <= 4 trastes)
- **01 ene 2026**: v0.1.0 - Version inicial con voicings basicos
