# RameauJazz Web App - Roadmap

## Versiones

### v0.1.0 - MVP (Completado)
- [x] Motor de Markov con 38 grados de acordes
- [x] Matriz de transiciones completa
- [x] Sistema de modulación (8 targets)
- [x] 5 estilos de voicing
- [x] Audio Tone.js (piano FM, walking bass, drums)
- [x] Visualización D3.js (force graph)
- [x] Piano Roll con canvas
- [x] Círculo de quintas interactivo
- [x] Control de tempo con tap tempo
- [x] Control de swing
- [x] Presets de estilo
- [x] Mixer de volumen

---

### v0.2.0 - Export & Persistence (Actual)
**Objetivo**: Permitir guardar y exportar el trabajo

#### Export
- [x] **Export MIDI** - Descargar progresión como archivo .mid
  - Incluir piano, bass y drums en tracks separados
  - Metadata (tempo, time signature, key)
- [ ] **Export Audio** - Grabar y descargar como WAV/MP3
  - Usar Tone.Recorder
  - Opciones de calidad (128kbps, 320kbps, WAV)
- [ ] **Export PDF** - Lead sheet con acordes
  - Integrar con jsPDF o similar
  - Formato Real Book style

#### Persistence
- [ ] **Guardar progresiones** - LocalStorage
  - Nombre, fecha, descripción
  - Lista de progresiones guardadas
- [ ] **Presets personalizados** - Configuraciones de usuario
  - Guardar combinaciones de parámetros
  - Importar/exportar presets como JSON

---

### v0.3.0 - Interactividad Avanzada
**Objetivo**: Mayor control sobre la generación

#### Edición Manual
- [ ] **Drag & drop acordes** - Reordenar progresión
- [ ] **Click para cambiar acorde** - Selector contextual
- [ ] **Insertar/eliminar acordes** - En cualquier posición
- [ ] **Copiar/pegar secciones** - Clipboard de acordes

#### Constraints
- [ ] **Forzar cadencias** - V-I al final, ii-V-I, etc.
- [ ] **Bloquear acordes** - Mantener acordes específicos fijos
- [ ] **Excluir acordes** - Blacklist de grados no deseados
- [ ] **Longitud variable** - 4, 8, 12, 16, 32 compases

#### Análisis
- [ ] **Detección de patrones** - ii-V-I, turnarounds, etc.
- [ ] **Sugerencias contextuales** - "Prueba un bII7 aquí"
- [ ] **Comparación con standards** - Similitud con temas conocidos

---

### v0.4.0 - Melodía
**Objetivo**: Generar líneas melódicas sobre la armonía

#### Motor de Melodía
- [ ] **Notas de acorde** - Arpegios básicos
- [ ] **Aproximaciones cromáticas** - Bebop vocabulary
- [ ] **Escalas por acorde** - Modos correctos automáticamente
- [ ] **Frases de vocabulario** - Licks y patrones comunes
- [ ] **Contorno melódico** - Control de dirección y rango

#### UI de Melodía
- [ ] **Track de melodía** en piano roll
- [ ] **Densidad rítmica** - Slider corcheas a semicorcheas
- [ ] **Registro** - Rango de la melodía
- [ ] **Solo/Mute** por track

---

### v0.5.0 - Modos y Escalas
**Objetivo**: Soporte completo para armonía modal

#### Modos
- [ ] **7 modos mayores** - Ionian a Locrian
- [ ] **Modos menores** - Melódico, armónico, natural
- [ ] **Modos simétricos** - Disminuido, aumentado, whole tone
- [ ] **Escalas exóticas** - Frigio dominante, lidio b7, etc.

#### Armonía Modal
- [ ] **Cadenas de acordes modales** - Evitar resoluciones tonales
- [ ] **Pedal tones** - Bajo estático
- [ ] **Quartal voicings** - Acordes por cuartas
- [ ] **So What voicings** - Estilo Miles Davis

---

### v0.6.0 - Ritmo Avanzado
**Objetivo**: Patrones rítmicos más sofisticados

#### Comping Patterns
- [ ] **Charleston** - On the beat
- [ ] **Freddie Green** - 4 negras
- [ ] **Bud Powell** - Anticipaciones
- [ ] **Red Garland** - Block chords
- [ ] **Bill Evans** - Voicings abiertos

#### Drums Avanzados
- [ ] **Patrones de ride** - Múltiples variaciones
- [ ] **Hi-hat pedal** - 2 y 4
- [ ] **Kicks y snare** - Acentos en downbeats
- [ ] **Fills** - Transiciones entre secciones
- [ ] **Brushes mode** - Para baladas

#### Time Signatures
- [ ] **3/4** - Jazz waltz
- [ ] **5/4** - Take Five style
- [ ] **6/8** - Afro-Cuban
- [ ] **7/4** - Odd meters

---

### v0.7.0 - Samples & Soundfonts
**Objetivo**: Audio de mayor calidad

#### Instrumentos
- [ ] **Piano samples** - Steinway o similar
- [ ] **Upright bass samples** - Fingered y arco
- [ ] **Drum kit samples** - Jazz kit real
- [ ] **Rhodes samples** - Fender Rhodes real
- [ ] **Wurlitzer** - Alternativa al Rhodes

#### SoundFont Support
- [ ] **Carga de SF2/SF3** - Soundfonts personalizados
- [ ] **MIDI playback** - Reproducir con cualquier soundfont
- [ ] **Presets de instrumentos** - Acoustic, Electric, etc.

---

### v0.8.0 - Colaboración
**Objetivo**: Funcionalidades sociales y de compartir

#### Sharing
- [ ] **URLs compartibles** - Progresión codificada en URL
- [ ] **Embed widget** - iFrame para blogs/webs
- [ ] **QR code** - Para compartir rápido

#### Social
- [ ] **Galería pública** - Progresiones de la comunidad
- [ ] **Favoritos** - Guardar progresiones de otros
- [ ] **Forks** - Modificar progresiones existentes
- [ ] **Comentarios** - Discusión sobre progresiones

#### Colaboración en Tiempo Real
- [ ] **WebSocket sync** - Múltiples usuarios editando
- [ ] **Cursor de otros usuarios** - Ver quién edita qué
- [ ] **Chat integrado** - Comunicación en sesión

---

### v0.9.0 - Educación
**Objetivo**: Herramientas de aprendizaje

#### Análisis Armónico
- [ ] **Números romanos** - Análisis automático
- [ ] **Funciones armónicas** - T/SD/D explicadas
- [ ] **Voice leading** - Visualización de movimiento
- [ ] **Resoluciones** - Flechas de tendencia

#### Ejercicios
- [ ] **Quiz de acordes** - Identificar funciones
- [ ] **Ear training** - Reconocer progresiones
- [ ] **Dictado armónico** - Transcribir lo que suena
- [ ] **Completar progresión** - Llenar los espacios

#### Teoría Integrada
- [ ] **Tooltips educativos** - Explicaciones contextuales
- [ ] **Links a recursos** - Videos, artículos
- [ ] **Ejercicios progresivos** - Curriculum estructurado

---

### v1.0.0 - Production Ready
**Objetivo**: Aplicación completa y pulida

#### Performance
- [ ] **Web Workers** - Audio processing fuera del main thread
- [ ] **IndexedDB** - Storage más robusto
- [ ] **Service Worker** - Offline support
- [ ] **PWA completa** - Instalable en móviles

#### UX
- [ ] **Responsive design** - Móviles y tablets
- [ ] **Touch gestures** - Swipe, pinch to zoom
- [ ] **Keyboard shortcuts** - Power users
- [ ] **Dark/Light themes** - Toggle de tema
- [ ] **Accesibilidad** - ARIA labels, screen readers

#### Internacionalización
- [ ] **i18n** - Múltiples idiomas
- [ ] **Nomenclatura** - Do/Re/Mi vs C/D/E
- [ ] **Formatos locales** - Fechas, números

#### Testing
- [ ] **Unit tests** - Vitest
- [ ] **E2E tests** - Playwright
- [ ] **Visual regression** - Chromatic

---

## Backlog (Sin priorizar)

### Ideas Futuras
- [ ] **AI suggestions** - LLM para sugerir próximo acorde
- [ ] **Style transfer** - "Suena como Bill Evans"
- [ ] **MIDI input** - Tocar acordes con teclado MIDI
- [ ] **Audio analysis** - Detectar acordes de grabaciones
- [ ] **Integration con DAWs** - VST/AU plugin
- [ ] **API pública** - Endpoints para desarrolladores
- [ ] **Mobile app** - React Native o Flutter
- [ ] **Desktop app** - Electron o Tauri

### Géneros Adicionales
- [ ] **Blues** - 12-bar blues, turnarounds
- [ ] **Gospel** - Acordes extendidos, shouts
- [ ] **Funk** - Voicings percusivos, 9ths
- [ ] **Latin** - Montunos, clave patterns
- [ ] **R&B/Neo-Soul** - Erykah Badu chords
- [ ] **Classical** - Common practice period

---

## Contribuir

¿Interesado en contribuir? Ver [CONTRIBUTING.md](CONTRIBUTING.md)

Prioridades actuales:
1. ~~Export MIDI (v0.2.0)~~ ✅
2. Export Audio WAV/MP3 (v0.2.0)
3. Guardar progresiones (v0.2.0)
4. Edición manual de acordes (v0.3.0)

---

*Última actualización: Enero 2026*
