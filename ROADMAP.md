# Roadmap - EigenLab Generative

Plan de desarrollo para plugins generativos de MuseScore.

---

## Filosofía de Diseño

### Principios

1. **Honestidad:** No usar nombres de épocas históricas falsamente. "Barroco" no es un slider.
2. **Paso a paso:** Cada versión construye sobre la anterior.
3. **Dependencias claras:** Modulación requiere estructura de frase.
4. **Separación por arquitectura:** Jazz necesita 7as → plugin separado si es necesario.

### Diagrama de Dependencias

```
v0.2 (actual)
    │
    ▼
v0.3 Honestidad en nombres
    │
    ▼
v0.4 Estructura de frase ────┬────→ v0.5 Modulación
                             │
                             └────→ Cadencias inteligentes
                                          │
                                          ▼
                                    v0.6 Acordes de 7a
                                          │
                                          ▼
                                    v0.7 Presets completos
                                          │
                                          ▼
                                    v1.0 Release
                                          │
                                          ▼
                                    Plugins separados (Jazz, Guitarra, Piano)
```

---

## v0.2.0 - SATB Funcional (Actual)

- [x] Motor de Markov con matrices de transición
- [x] Gravedad tonal (caos ↔ estructura)
- [x] Modo mayor y menor armónico
- [x] Voice leading SATB básico
- [x] Evitación de quintas/octavas paralelas
- [x] Generación en 4 pentagramas separados
- [x] Cadencia auténtica V-I opcional
- [x] UI con preview de progresión
- [x] 10 tonalidades soportadas
- [x] Hasta 32 acordes

---

## v0.3.0 - Honestidad y Claridad

**Objetivo:** Renombrar parámetros para reflejar lo que realmente hacen.

### Cambios de nomenclatura

| Actual | Nuevo | Razón |
|--------|-------|-------|
| "Gravedad tonal" | **Resolución** | Más claro |
| Valores 0-1 | **Libre / Tonal / Estricto** | Etiquetas comprensibles |

### Por qué NO usamos épocas históricas

| Etiqueta falsa | Problema |
|----------------|----------|
| "Barroco" | Bach es más complejo que V→I. Tiene secundarias, secuencias, cromatismo. |
| "Clásico" | Mozart requiere estructura de frase, no solo probabilidades. |
| "Romántico" | Necesita acordes alterados, mediantes cromáticas. |
| "Jazz" | Imposible sin acordes de 7a mínimo. |

### Nuevos presets de progresión

| Preset | Comportamiento |
|--------|----------------|
| **Libre** | Markov puro, cualquier progresión |
| **Tonal** | Balance entre tensión y resolución |
| **Cadencial** | V→I muy frecuente (~80%) |
| **Secuencia de 5as** | Favorece vi→ii→V→I |
| **Cíclico (Pop)** | I→V→vi→IV en loop |

### Tareas v0.3

- [ ] Renombrar slider "Gravedad" → "Resolución"
- [ ] Añadir etiquetas claras (Libre/Tonal/Estricto)
- [ ] Implementar preset "Secuencia de quintas"
- [ ] Implementar preset "Cíclico"
- [ ] Actualizar UI con selector de preset
- [ ] Documentar qué hace realmente cada preset

---

## v0.4.0 - Estructura de Frase

**Objetivo:** Añadir consciencia de frase musical. Prerrequisito para modulación.

### Conceptos

```
Frase = Antecedente + Consecuente

Antecedente (cc. 1-4):  Tensión ──→ Semicadencia (V)
Consecuente (cc. 5-8):  Tensión ──→ Cadencia final (I)
```

### Nuevos parámetros

| Parámetro | Valores | Efecto |
|-----------|---------|--------|
| **Longitud de frase** | 4, 8, 16 compases | Fuerza cadencia cada N |
| **Tipo de frase** | Período, Sentence, Libre | Estructura interna |
| **Cadencia intermedia** | Semicadencia, Rota, Ninguna | Cómo termina antecedente |

### Tareas v0.4

- [ ] Añadir parámetro "Cadencia cada N acordes"
- [ ] Implementar semicadencia (termina en V)
- [ ] Implementar período (antecedente + consecuente)
- [ ] Forzar cadencia auténtica al final de frase
- [ ] UI para configurar estructura
- [ ] Preview muestra estructura de frase

---

## v0.5.0 - Modulación

**Objetivo:** Cambiar de tonalidad durante la progresión. Requiere v0.4.

### Tipos de modulación soportados

| Tipo | Ejemplo (desde C) | Método |
|------|-------------------|--------|
| **Relativo** | C → Am | Pivot chord (vi = i) |
| **Dominante** | C → G | Pivot + V/V |
| **Subdominante** | C → F | Pivot (IV = I) |
| **Paralelo** | C → Cm | Directo o mediante |

### Decisiones de diseño

**¿Cuándo modular?**
- En puntos estructurales (mitad de la pieza)
- Usuario configura frecuencia

**¿Cómo modular?**
- Pivot chord (acorde común reinterpretado)
- Dominante secundaria (V/V → V → I nueva)

**¿Cómo mostrar?**
- Indicador en preview
- Opcional: cambio de armadura en partitura

### Ejemplo de modulación por pivot

```
C mayor:  I  - vi - ii - V  - I
          C  - Am - Dm - G  - C

Modulación C → G usando vi = ii:

C mayor:  I  - vi ─┬─ V  - I   (ahora en G)
          C  - Am ─┘─ D  - G
               └── Am = vi en C = ii en G (pivot)
```

### Nuevos parámetros

| Parámetro | Valores |
|-----------|---------|
| **Modulación** | On / Off |
| **Destinos** | Relativo, V, IV, Paralelo, Libre |
| **Frecuencia** | Rara / Normal / Frecuente |
| **Método** | Pivot / Dominante secundaria / Directo |

### Tareas v0.5

- [ ] Toggle modulación on/off
- [ ] Selector de destinos permitidos
- [ ] Implementar pivot chord detection
- [ ] Implementar modulación al V
- [ ] Implementar modulación al relativo
- [ ] Mostrar modulación en preview
- [ ] Actualizar keyPitch dinámicamente
- [ ] Tests de modulación

---

## v0.6.0 - Acordes de 7a

**Objetivo:** Habilitar acordes de séptima para armonía más rica.

### Por qué es importante

- Prerrequisito para cualquier jazz
- Enriquece armonía clásica/romántica
- Permite dominantes con 7a (V7→I)

### Cambios arquitectónicos

```javascript
// Actual (triadas)
'I':  { root: 0, third: 4, fifth: 7 }

// Nuevo (con 7a opcional)
'I':     { root: 0, third: 4, fifth: 7 }
'Imaj7': { root: 0, third: 4, fifth: 7, seventh: 11 }
'V7':    { root: 7, third: 11, fifth: 2, seventh: 5 }
```

### Nuevos parámetros

| Parámetro | Valores |
|-----------|---------|
| **Tipo de acordes** | Triadas / Con 7as / Mixto |
| **7a en dominante** | Siempre / A veces / Nunca |

### Voice leading con 7as

- 7a resuelve por grado conjunto descendente
- En V7→I: la 7a (F) baja a 3a de I (E)
- Evitar duplicar la 7a

### Tareas v0.6

- [ ] Añadir definiciones de acordes con 7a
- [ ] Toggle triadas/7as en UI
- [ ] Actualizar voice leading para 4 notas
- [ ] Resolución correcta de 7a
- [ ] V7 como opción siempre disponible
- [ ] Tests de voice leading con 7as

---

## v0.7.0 - Presets Completos

**Objetivo:** Combinaciones predefinidas de todos los parámetros.

### Presets propuestos

| Preset | Resolución | Frase | Modulación | 7as |
|--------|------------|-------|------------|-----|
| **Coral simple** | Estricto | 4 cc | No | No |
| **Período clásico** | Tonal | 8 cc (4+4) | Al V | Solo V7 |
| **Romántico** | Libre | 16 cc | Sí (libre) | Sí |
| **Pop** | Cíclico | 4 cc | No | No |
| **Círculo de 5as** | Secuencia | 8 cc | Sí (por 5as) | Mixto |

### Usuario puede crear presets

- Guardar configuración actual
- Cargar preset guardado
- Exportar/importar presets

### Tareas v0.7

- [ ] Implementar sistema de presets
- [ ] 5 presets incluidos
- [ ] Guardar preset personalizado
- [ ] UI de gestión de presets

---

## v1.0.0 - Release Estable

**Objetivo:** Versión pulida lista para distribución.

### Checklist

- [ ] Todos los features funcionando
- [ ] UI pulida y consistente
- [ ] Documentación completa
- [ ] Ejemplos de uso
- [ ] Tests de regresión
- [ ] Sin crashes conocidos
- [ ] Feedback de beta testers incorporado

---

## Post v1.0 - Plugins Separados

### RameauAnalysis

Análisis armónico de partituras existentes.

- Lee partitura y detecta acordes
- Muestra cifrado americano
- Muestra grados romanos
- Detecta cadencias
- Detecta modulaciones
- Colorea por función (T/S/D)

### RameauJazz

Plugin separado porque requiere:
- Acordes de 7a obligatorios
- 9as, 11as, 13as
- Voicings específicos de jazz
- Sustitución de tritono
- ii-V-I como base
- Reglas de voice leading diferentes

### RameauGuitar

- Voicings de guitarra (6 cuerdas)
- Diagramas de acordes
- Tablatura
- Posiciones CAGED
- Capo virtual

### RameauPiano

- Grand staff (Sol + Fa)
- Patrones mano izquierda (Alberti, arpegio, stride)
- Distribución LH/RH inteligente

---

## Análisis: ¿Por Qué Este Orden?

### v0.3 antes de todo

Sin nombres honestos, los usuarios no entienden qué hace el plugin.

### v0.4 (Frase) antes de v0.5 (Modulación)

Modular sin estructura = modulaciones aleatorias sin sentido.
Con estructura = "modula al V en compás 8, vuelve en 16".

### v0.6 (7as) después de modulación

Las 7as enriquecen pero no son estructurales.
Se pueden añadir sin cambiar la lógica de frase/modulación.

### Jazz como plugin separado

No es solo "añadir 7as". Es:
- Diferente vocabulario armónico
- Diferentes reglas de voice leading
- Diferente estética
- Merece su propio espacio

---

## Referencias para Implementación

### Corpus para validar matrices

- [Bach Chorales Dataset](https://github.com/cuthbertLab/music21) - 371 corales analizados
- Kostka & Payne - Estadísticas de progresiones
- Tymoczko - Geometry of Music

### APIs de MuseScore

- [Plugin API Docs](https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/)
- [Foro de desarrollo](https://musescore.org/en/forum/8)

---

*Última actualización: Enero 2026*
