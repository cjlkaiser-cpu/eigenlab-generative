# RameauGuitar

Generador de progresiones armonicas para **guitarra clasica** en MuseScore 4.

## Estado

**Version:** 0.1.0 (Alpha)

## Caracteristicas

### Implementado (v0.1.0)

- Motor de Markov con matrices de transicion (mismo que RameauSATB)
- Voicings adaptados a guitarra clasica
- Rango E2 (40) - C5 (72)
- Maximo 4 notas por acorde
- Un solo pentagrama (clave de Sol 8vb)
- 8 tonalidades optimizadas para guitarra: E, A, D, G, C, Am, Em, Dm
- Gravedad tonal configurable
- Cadencia V-I opcional
- Hasta 16 acordes por progresion

### Limitaciones Actuales

- No verifica que el voicing sea fisicamente tocable
- No considera cuerdas al aire vs pisadas
- No calcula posiciones de mano izquierda
- No genera diagramas de acordes
- No genera tablatura

## Uso

1. Abrir MuseScore 4
2. Crear o abrir partitura de guitarra (1 pentagrama)
3. Home → Complementos → Rameau Guitar
4. Seleccionar tonalidad (E, A, D recomendadas)
5. Configurar numero de acordes
6. Click "Previsualizar" para ver progresion
7. Click "Generar" para escribir en partitura

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

## Roadmap

### v0.2.0 - Voicings Tocables

- [ ] Verificar span maximo de trastes (4-5 trastes)
- [ ] Evitar voicings imposibles fisicamente
- [ ] Preferir cuerdas al aire cuando sea posible
- [ ] Algoritmo de asignacion de cuerdas

### v0.3.0 - Opciones de Salida

- [ ] Selector en UI: tipo de salida
- [ ] Acordes bloque (actual)
- [ ] Arpegio ascendente (p-i-m-a)
- [ ] Arpegio descendente (a-m-i-p)
- [ ] Patron completo (p-i-m-a-m-i)
- [ ] Selector de duracion base (corchea, semicorchea)

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

- [ ] Validacion completa de voicings
- [ ] Biblioteca de voicings comunes
- [ ] Presets de estilo (Clasico, Flamenco, Bossa)
- [ ] Documentacion completa

## Notas Tecnicas

### Rango de Guitarra

| Cuerda | Nota al aire | MIDI |
|--------|--------------|------|
| 6 (grave) | E2 | 40 |
| 5 | A2 | 45 |
| 4 | D3 | 50 |
| 3 | G3 | 55 |
| 2 | B3 | 59 |
| 1 (aguda) | E4 | 64 |

Rango practico hasta traste 12: E2 (40) - E5 (76)
Rango usado en v0.1: E2 (40) - C5 (72)

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

## Referencias

- [MuseScore Plugin API](https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/)
- [RameauGenerator (SATB)](../RameauGenerator/) - Plugin base

## Changelog

- **01 ene 2026**: v0.1.0 - Version inicial con voicings basicos
