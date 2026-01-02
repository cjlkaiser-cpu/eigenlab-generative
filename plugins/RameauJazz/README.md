# RameauJazz

Generador de progresiones **jazz** para piano en MuseScore 4.

## Estado

**Version:** 0.3.0 (Alpha)

## Caracteristicas

### Implementado (v0.1.0)

- Acordes de 7a: maj7, m7, 7, m7b5, dim7
- Acordes de 9a: maj9, m9, 9, 13
- Acordes alterados: 7alt, 7b9, 7#9
- Matriz de Markov basada en ii-V-I
- Sustituciones: bII7 (tritono), bVII7
- Grand staff (piano)

#### Estilos de Voicing

| Estilo | LH | RH | Uso |
|--------|----|----|-----|
| **Shell** | Root | 3-7 | Trio, combo |
| **Drop 2** | Root-drop | 3-5-7 | Solo piano |
| **Rootless A** | Root | 3-5-7-9 | Con bajista |
| **Rootless B** | Root | 7-9-3-5 | Con bajista |
| **Block** | Root-3 | 5-7-9 | Baladas |

#### Complejidad de Acordes

| Nivel | Acordes |
|-------|---------|
| 7as | maj7, m7, 7, m7b5 |
| 9as | maj9, m9, 9, 13 |
| Mixto | Alternancia aleatoria |

### Implementado (v0.2.0)

- Walking bass como opcion de output
- Aproximaciones al siguiente acorde (look-ahead)
- Selector de estilo de bajo (Bloque vs Walking)

### Implementado (v0.3.0) - Blue Note Style

- Patron **Blue Note (pro)** con tecnicas profesionales
- **Double chromatic approach**: dos semitonos antes del target
- **Enclosure**: nota arriba + abajo → target
- **Corcheas swing**: 25% de compases con subdivision
- **Ghost notes**: notas de paso entre beats 3-4
- Variacion aleatoria constante para evitar mecanicidad
- 4 patrones: Blue Note, Oleaje, Escalar, Cromatico

#### Patrones Walking Bass

Todos los patrones siguen las reglas clasicas de jazz:
- **Beat 1**: Root (ancla armonica) - SIEMPRE
- **Beat 2**: Nota de paso (2ª, 3ª, o cromatica)
- **Beat 3**: Target harmonico (5ª, 3ª, o 7ª)
- **Beat 4**: Approach cromatico (semitono hacia siguiente root)

| Patron | Descripcion | Tecnicas |
|--------|-------------|----------|
| **Blue Note (pro)** | Estilo profesional | Double chromatic, enclosures, corcheas swing |
| **Oleaje** | Alterna ↑/↓ | Variacion en beat 2, approach simple |
| **Escalar** | Grados de escala | 1→2→3→app o 1→7→6→app |
| **Cromatico** | Chromatic walkup | 4 semitonos hacia target |

#### Blue Note Style (v0.3)

El patron **Blue Note** implementa tecnicas de bajistas profesionales:

| Tecnica | Probabilidad | Descripcion |
|---------|--------------|-------------|
| **Corcheas swing** | 25% | Dos corcheas en beat 3-4 con ghost note |
| **Double chromatic** | 20% | Dos semitonos antes del target (ej: D-Db-C) |
| **Enclosure** | 15% | Nota arriba + nota abajo → target |
| **Variacion beat 2** | 100% | Alterna entre escalar (40%), arpegio (30%), cromatico (30%) |

Ejemplo de linea Blue Note en Dm7 → G7:
```
Beat:    1       2       3    &    4
Notas:   D       E       A    Bb   F#   (con corcheas en 3-&)
         root   escalar  5ª  ghost  approach
```

### Progresiones tipicas generadas

```
IIm7 → V7 → Imaj7              (ii-V-I basico)
IIm7 → bII7 → Imaj7            (con sustituto tritono)
Imaj7 → VIm7 → IIm7 → V7       (turnaround)
IIm7 → V7alt → Imaj9           (con dominante alterado)
```

## Uso

1. Abrir MuseScore 4
2. Crear partitura de piano (grand staff)
3. Home → Complementos → Rameau Jazz
4. Seleccionar tonalidad
5. Elegir complejidad (7as, 9as, mixto)
6. Elegir estilo de voicing
7. Click "Previsualizar" para ver progresion
8. Click "Generar" para escribir en partitura

## Instalacion

```bash
cp -r plugins/RameauJazz ~/Documents/MuseScore4/Plugins/

# Reiniciar MuseScore y activar en Complementos
```

## Teoria de Voicings

### Shell Voicing

El voicing minimo para jazz. Solo 3 notas: fundamental, tercera, septima.

```
Cmaj7 Shell:
LH: C2
RH: E4 - B4
```

La quinta se omite porque no define la calidad del acorde.

### Drop 2

Voicing cerrado con la segunda voz desde arriba bajada una octava.

```
Cmaj7 cerrado: C - E - G - B
Cmaj7 Drop 2:  G - C - E - B  (G baja octava)
```

Muy usado en guitarra jazz y piano solo.

### Rootless Voicings

Sin fundamental (el bajista la toca). Dos posiciones:

```
Cmaj9 Rootless A: E - G - B - D  (3-5-7-9)
Cmaj9 Rootless B: B - D - E - G  (7-9-3-5)
```

Alternar A y B para voice leading suave.

## Matriz de Transicion

```
ii-V-I es el nucleo:
  IIm7 → V7   (65%)
  V7 → Imaj7  (60%)

Sustituciones:
  IIm7 → bII7 (10%)  - Sustituto tritono del V
  bII7 → Imaj7 (85%) - Resolucion por semitono

Turnarounds:
  Imaj7 → VIm7 (20%)
  VIm7 → IIm7 (35%)
```

## Roadmap

### v0.2.0 - Walking Bass ✓

- [x] Linea de bajo en negras (4 por compas)
- [x] Reglas de jazz: Beat1=root, Beat2=paso, Beat3=target, Beat4=approach
- [x] Patrones basicos: Oleaje, Escalar, Cromatico

### v0.3.0 - Blue Note Style ✓

- [x] Patron Blue Note (pro) con tecnicas profesionales
- [x] Double chromatic approach (20%)
- [x] Enclosure: nota arriba + abajo → target (15%)
- [x] Corcheas swing con ghost notes (25%)
- [x] Variacion aleatoria en beat 2 (escalar/arpegio/cromatico)
- [x] Duraciones mixtas (negras + corcheas)

### v0.4.0 - Ritmo

- [ ] Comping patterns (ritmos de acompanamiento)
- [ ] Charleston, anticipaciones
- [ ] Swing feel

### v0.4.0 - Mas Sustituciones

- [ ] Dominantes secundarios (V7/ii, V7/V)
- [ ] Acordes de paso diminuidos
- [ ] Cadenas de ii-V

### v0.5.0 - Estilos

- [ ] Preset: Bebop (rapido, alterados)
- [ ] Preset: Modal (menos cambios)
- [ ] Preset: Bossa Nova (brasileno)
- [ ] Preset: Ballad (lento, extensiones)

### v1.0.0 - Release

- [ ] Todos los voicings funcionando
- [ ] Walking bass opcional
- [ ] Presets de estilo
- [ ] Sin crashes

## Notas Tecnicas

### Tipos de Acordes

| Tipo | Intervalos | Simbolo |
|------|------------|---------|
| maj7 | 1-3-5-7 | Cmaj7, C△7 |
| m7 | 1-b3-5-b7 | Cm7, C-7 |
| 7 | 1-3-5-b7 | C7 |
| m7b5 | 1-b3-b5-b7 | Cm7b5, Cø |
| dim7 | 1-b3-b5-bb7 | Cdim7, C°7 |
| maj9 | 1-3-5-7-9 | Cmaj9 |
| 9 | 1-3-5-b7-9 | C9 |
| 7alt | 1-3-#5-b7-b9 | C7alt |

### Funciones Armonicas Jazz

| Funcion | Grados | Resolucion |
|---------|--------|------------|
| Tonica (T) | Imaj7, IIIm7, VIm7 | Estable |
| Subdominante (SD) | IIm7, IVmaj7 | → V7 |
| Dominante (D) | V7, VIIm7b5, bII7 | → I |

## Referencias

- Mark Levine - "The Jazz Piano Book"
- Jamey Aebersold - "Jazz Handbook"
- [RameauPiano](../RameauPiano/) - Plugin hermano

## Changelog

- **02 ene 2026**: v0.3.0 - Blue Note style: double chromatic, enclosures, corcheas swing
- **02 ene 2026**: v0.2.0 - Walking bass con 4 patrones y aproximaciones
- **02 ene 2026**: v0.1.0 - Version inicial con voicings shell/drop2/rootless
