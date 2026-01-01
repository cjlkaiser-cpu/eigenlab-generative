# Roadmap - EigenLab Generative

Plan de desarrollo para plugins generativos de MuseScore.

---

## v0.2.0 - SATB Funcional (Actual)

- [x] Motor de Markov con matrices de transicion
- [x] Gravedad tonal (caos ↔ estructura)
- [x] Modo mayor y menor armonico
- [x] Voice leading SATB basico
- [x] Evitacion de quintas/octavas paralelas
- [x] Generacion en 4 pentagramas separados
- [x] Cadencia autentica V-I opcional
- [x] UI con preview de progresion
- [x] 10 tonalidades soportadas

---

## v0.3.0 - Analisis Armonico

**Objetivo:** Mostrar cifrado americano y grados romanos en la partitura.

- [ ] Investigar API MuseScore 4 para añadir texto/simbolos
- [ ] Cifrado americano sobre Soprano (C, Dm, G7, Am...)
- [ ] Grados romanos bajo el Bajo (I, ii, V, vi...)
- [ ] Colores por funcion armonica (T=verde, S=azul, D=rojo)
- [ ] Opcion para mostrar/ocultar analisis

### Alternativas si API no soporta:
- Generar imagen/SVG del analisis
- Exportar analisis a archivo separado
- Usar lyrics como workaround

---

## v0.4.0 - Modo Guitarra

**Objetivo:** Generar progresiones optimizadas para guitarra.

- [ ] Voicings de guitarra (max 6 notas, cuerdas al aire)
- [ ] Diagramas de acordes sobre partitura
- [ ] Tablatura automatica
- [ ] Posiciones CAGED
- [ ] Acordes con cejilla vs abiertos
- [ ] Transposicion con capo virtual
- [ ] Progresiones tipicas de guitarra:
  - Folk/Pop (I-V-vi-IV)
  - Blues (I-I-I-I-IV-IV-I-I-V-IV-I-V)
  - Bossa nova
  - Flamenco

### Parametros nuevos:
| Parametro | Descripcion |
|-----------|-------------|
| Afinacion | Standard, Drop D, Open G... |
| Posicion maxima | Limitar trastes (ej: 0-5) |
| Permitir cejilla | Si/No |
| Estilo | Folk, Jazz, Clasico |

---

## v0.5.0 - Modo Piano

**Objetivo:** Generar progresiones optimizadas para piano.

- [ ] Grand Staff (clave Sol + clave Fa)
- [ ] Distribucion mano izquierda / mano derecha
- [ ] Patrones de acompanamiento:
  - Acordes bloque
  - Arpegio ascendente/descendente
  - Alberti bass
  - Stride (jazz)
  - Broken chords
- [ ] Rango de octavas por mano
- [ ] Duplicaciones inteligentes

### Parametros nuevos:
| Parametro | Descripcion |
|-----------|-------------|
| Patron LH | Bloque, arpegio, stride... |
| Patron RH | Melodia, acordes, arpegio... |
| Rango LH | Octavas mano izquierda |
| Rango RH | Octavas mano derecha |

---

## v0.6.0 - Inversiones y Bajo Cifrado

**Objetivo:** Control sobre inversiones y notacion barroca.

- [ ] Seleccion de inversion (fundamental, 1a, 2a, 3a)
- [ ] Bajo cifrado (6, 6/4, 7, etc.)
- [ ] Conduccion de bajo por grados conjuntos
- [ ] Linea de bajo melodica
- [ ] Pedales (notas sostenidas en bajo)

---

## v0.7.0 - Ritmo y Duraciones

**Objetivo:** Generar ritmo variado, no solo redondas.

- [ ] Patron ritmico seleccionable
- [ ] Duraciones: redonda, blanca, negra, corchea
- [ ] Sincopa y anticipaciones
- [ ] Ritmos por estilo:
  - Coral (homofonico)
  - Barroco (contrapunto ritmico)
  - Pop (acordes en tiempos debiles)
  - Bossa (ritmo caracteristico)
- [ ] Generacion de melodia sobre acordes

---

## v0.8.0 - Estilos y Presets

**Objetivo:** Configuraciones predefinidas por epoca/genero.

### Presets historicos:
| Preset | Descripcion |
|--------|-------------|
| Barroco | Paralelas estrictas, sensible resuelve, cadencias frecuentes |
| Clasico | Balance tension/resolucion, frases de 4/8 compases |
| Romantico | Cromatismo, modulaciones, acordes extendidos |
| Impresionista | Acordes paralelos, escalas modales |

### Presets de genero:
| Preset | Descripcion |
|--------|-------------|
| Pop | I-V-vi-IV, simplicidad armonica |
| Jazz | ii-V-I, extensiones (7, 9, 13), tritono sub |
| Blues | I7-IV7-I7-V7, blue notes |
| Folk | Acordes diatonicos, pedales |
| Gospel | Plagales, subdominante menor |

---

## v0.9.0 - Modulacion

**Objetivo:** Cambios de tonalidad dentro de la progresion.

- [ ] Modulacion a relativo mayor/menor
- [ ] Modulacion al V (dominante)
- [ ] Modulacion cromatica
- [ ] Pivot chords (acordes comunes)
- [ ] Modulacion por secuencia
- [ ] Indicador visual de cambio de tonalidad

---

## v1.0.0 - Release Estable

**Objetivo:** Version pulida lista para distribucion.

- [ ] Todos los modos funcionales (SATB, Guitarra, Piano)
- [ ] Analisis armonico completo
- [ ] Presets de estilo
- [ ] Documentacion completa
- [ ] Ejemplos y tutoriales
- [ ] Tests de regresion
- [ ] Instalador/paquete para MuseScore Hub

---

## Futuro (post v1.0)

### Nuevos plugins potenciales:

| Plugin | Descripcion |
|--------|-------------|
| **CounterpointGenerator** | Genera contrapunto a 2-4 voces (especies Fux) |
| **MelodyGenerator** | Genera melodias sobre progresion dada |
| **BachChorale** | Genera corales estilo Bach con ML |
| **JazzImprov** | Genera solos de jazz sobre changes |
| **OrchestrationHelper** | Sugiere orquestacion para reduccion de piano |

### Integracion con otros proyectos:

- **Contrapunctus/NeuroFux**: Importar ejercicios de Schoenberg
- **Rameau Machine**: Sync bidireccional web ↔ MuseScore
- **eigenlab-instruments**: Generar → exportar MIDI → sintetizar con VST

---

## Contribuir

Las contribuciones son bienvenidas. Para proponer features:

1. Abrir issue en GitHub describiendo la funcionalidad
2. Discutir viabilidad con la API de MuseScore
3. Implementar en branch separado
4. PR con tests y documentacion

---

*Ultima actualizacion: Enero 2026*
