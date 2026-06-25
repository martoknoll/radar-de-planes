# Auditoría de producto — Radar de Planes (Sonda)

Archivo auditado: `index.html` (2974 líneas, ~108KB, sin build step). Stack: Leaflet 1.9.4, Supabase JS v2, Tabler Icons 2.44.0, geocoding vía Nominatim.

**Nota sobre la paleta**: los valores reales en `:root` son `--coral:#00F5D4` (cian, no el coral #FF6B4A mencionado) y `--mint:#B6FF3B` (lima brillante, no el mint #4ADE9C mencionado), más `--secondary:#7C5CFF` (violeta). No es un bug, pero vale la pena confirmar si el naming de las variables quedó desactualizado respecto a una guía de marca anterior — hoy el nombre de la variable no describe el color real, lo que puede confundir a quien edite el CSS más adelante.

---

## 1. Bugs de UI/UX

| # | Ubicación | Severidad | Problema | Sugerencia |
|---|---|---|---|---|
| 1.1 | `index.html` ~2271-2285, función `geocodeAddress()` | **Crítico** | El fetch a Nominatim no tiene timeout ni `AbortController`. Si Nominatim tarda o no responde, el botón queda en "Buscando ubicación..." indefinidamente sin que el usuario pueda cancelar. | Agregar `AbortController` con timeout (~8s) y permitir reintentar/cancelar. |
| 1.2 | ~2272 | Medio | El fetch a Nominatim no manda `User-Agent` (su ToS lo exige). Puede causar throttling/bloqueo silencioso del servicio. | Agregar header `User-Agent` identificando la app. |
| 1.3 | ~2273 | Bajo | Si Nominatim devuelve un error no-JSON (ej. 503 con HTML), `response.json()` explota y cae en el catch genérico — el usuario no distingue "dirección no encontrada" de "el servicio está caído". | Diferenciar mensajes según el tipo de error (red vs. no resultados). |
| 1.4 | ~2328, `handleFormSubmit()` | Medio | El botón de submit se deshabilita mientras sube el evento, pero no hay spinner ni mensaje — para el usuario el botón "no responde". | Agregar texto/spinner tipo "Publicando..." en el botón mientras está disabled. |
| 1.5 | ~1607-1616, `fetchEvents()` | Medio | Si falla el fetch a Supabase, la app cae silenciosamente a `SEED_EVENTS` (datos demo) sin avisar al usuario que está viendo contenido de ejemplo, no datos reales. | Mostrar un banner/toast si se usó el fallback. |
| 1.6 | ~2716-2725, `deleteEventAsAdmin()` | Medio | Actualiza el estado local (quita el evento de la lista) sin esperar confirmación de que el delete en Supabase tuvo éxito. Si falla, la UI muestra el evento como borrado pero sigue existiendo en la base. | Esperar el resultado antes de actualizar el estado local; mostrar error si falla. |
| 1.7 | ~2374-2385, `toggleFollow()` | Bajo-Medio | Actualiza el `Set` de "siguiendo" de forma optimista antes de confirmar con Supabase. Si la llamada falla, no hay toast de error — el estado queda desincronizado hasta el próximo refetch. | Revertir el cambio local y avisar con un toast si la operación falla. |
| 1.8 | ~2676 (botón eliminar en admin) | Medio | Borrar un evento o cambiar el rol de un usuario desde el panel de admin no tiene ningún diálogo de confirmación — es un solo tap y es irreversible. | Agregar confirmación (al menos un `confirm()` nativo como mínimo viable, idealmente un modal). |
| 1.9 | ~1175-1182 | Bajo | El único breakpoint mobile específico es `max-width:430px`. Pantallas de 480-600px (muchos Android) no tienen reglas propias y pueden verse apretadas. | Agregar un breakpoint intermedio (~600px). |
| 1.10 | Entre 430px y 980px (sin breakpoint dedicado) | Bajo | No hay reglas específicas para tablets (~768px, ej. iPad). El layout puede verse mal proporcionado en ese rango. | Agregar breakpoint ~768px si se detectan problemas reales al probar. |
| 1.11 | ~1909-1921 | Bajo-Medio | En mobile, si el usuario está en la vista "Lista" y toca un marcador (indirectamente, vía mini-card), no cambia automáticamente a la vista "Mapa" — puede no ver el popup que se abrió. | Auto-cambiar a vista mapa al seleccionar un marcador en mobile. |
| 1.12 | ~2263-2283 (estado de geocoding) | Bajo | El estado de geocoding no tiene `aria-live`/`role="status"`, así que lectores de pantalla no anuncian "Buscando..."/"Encontrado"/error. | Agregar `aria-live="polite"` al contenedor de estado. |
| 1.13 | ~2533 (botón "dejar de seguir" en cuenta) | Bajo | El botón solo tiene un ícono, sin `aria-label`; un lector de pantalla anuncia "button" sin contexto. | Agregar `aria-label="Dejar de seguir"`. |
| 1.14 | ~2555 | Bajo | Botones de "Cerrar sesión"/"Panel de administración" usan `style="width:100%"` inline en vez de una clase CSS reutilizable — funciona pero es deuda de mantenimiento menor. | Mover a clase CSS. |
| 1.15 | ~1338 / ~1876 / ~2051 | Bajo | La URL de imagen de fallback está repetida literal en 3 lugares del archivo. Cambiarla a futuro requiere editar las 3. | Extraer a una constante `FALLBACK_IMG` usada en los 3 sitios (de hecho ya existe `FALLBACK_IMG`, confirmar que las 3 referencias apunten a la constante y no a un string duplicado). |

---

## 2. Iconos rotos o inexistentes

- **Librería usada**: Tabler Icons 2.44.0 (vía CDN, clases `ti ti-*`) + emojis usados como ícono "decorativo" de categoría (`pin-emoji`) + un único uso de entidad `&times;` (`x-mark`) para los botones de cerrar en la mayoría de los sheets.
- **No se encontraron clases de Tabler inexistentes** — todos los `ti-*` usados son nombres válidos de la librería.
- **Inconsistencia 2.1**: el botón de cerrar del panel de admin usa `<i class="ti ti-x">` mientras que el resto de los sheets (detalle, formulario, cuenta) usan `<span class="x-mark">&times;</span>`. Es el remanente del fix que hicimos en PR #25 — funciona, pero ahora hay **dos patrones distintos** para el mismo botón en el mismo archivo. Severidad baja, pero conviene unificar a uno de los dos (recomiendo el ícono de Tabler, que fue justamente el fix más robusto).
- **Inconsistencia 2.2**: las categorías mezclan emoji (`emoji:'🎬'`) e ícono Tabler (`icon:'ti-movie'`) — el emoji se usa en el pin del mapa, el ícono en chips/listas. Es intencional y no está roto, pero si Tabler tarda en cargar (CDN lento), el usuario ve chips sin ícono mientras los pines del mapa sí muestran emoji — inconsistencia visual transitoria.
- **Inconsistencia 2.3**: el array `CATEGORIES` guarda el ícono sin el prefijo `ti-` en algunos casos y se concatena `class="ti ${cat.icon}"` — funciona porque siempre se concatena igual, pero es un patrón frágil si alguien agrega una categoría nueva sin seguir la convención exacta.

---

## 3. Revisión de flujos de usuario

### 3.1 Visitante descubriendo eventos (mapa → filtro → detalle → cerrar)
- Flujo funciona de punta a punta. Fricciones puntuales:
  - Si el usuario no activó ubicación, la distancia se muestra como "—" sin explicación de por qué (línea ~2044). Pequeño punto de confusión.
  - El share (botón compartir) usa `navigator.share` con fallback a portapapeles; en algunos navegadores/iOS el `clipboard.write` puede fallar silenciosamente y el toast de "copiado" se muestra igual aunque no haya copiado nada (falso positivo).
  - Reportar un evento ("Marcamos este plan para revisar") es puramente cosmético: no persiste nada en la base, es un toast sin efecto real — fricción de expectativa para el usuario que cree haber reportado algo.

### 3.2 Crear evento (form + geocoding + pin draggable)
- Punto más frágil de toda la app: **el geocoding no tiene timeout** (ver 1.1) y la ayuda visual no aclara que hay *dos* formas de fijar el pin (arrastrar o tocar el mapa) — el texto solo menciona "arrastrar".
- El campo "Organizador" se prellena con el email del usuario logueado (fix que hicimos hace unas semanas) — pero el usuario puede no notar que ya está prellenado y publicar con su email como nombre de organizador cuando en realidad quería poner el nombre de una marca/colectivo.
- Doble submit: si Supabase tarda en responder, no hay nada que impida que el usuario haga doble-tap en "Publicar" generando un evento duplicado (el botón se deshabilita pero sin feedback visual claro de que ya está procesando — ver 1.4).

### 3.3 Seguir/dejar de seguir organizador
- Funciona, ya lo confirmaste manualmente con el mail de alerta. Fricciones menores:
  - El botón "Seguir" solo aparece si el usuario está logueado y mirando el detalle de un evento publicado por otra cuenta — un visitante no logueado no tiene ninguna pista de que esa funcionalidad existe hasta que crea una cuenta.
  - Actualización optimista sin manejo de error (ver 1.7).

### 3.4 Flujo de admin
**Lo que el panel permite hoy:**
- Ver todos los eventos (lista simple, sin buscador/filtro) y borrarlos uno por uno.
- Ver todos los perfiles, cambiar su rol (user/organizer/admin) y el flag "verificado".

**Lo que NO permite hoy** (gaps reales para operar el producto):
- No se pueden **editar** eventos (título, fecha, ubicación, etc.) — solo borrar y recrear.
- No hay buscador/filtro en ninguna de las dos listas (eventos o usuarios) — con más de ~30 eventos ya es incómodo de usar.
- No se ve el email de los usuarios en la lista de perfiles (solo `display_name`), lo que dificulta identificar cuentas reales en producción.
- No hay confirmación antes de borrar ni antes de promover a un usuario a "admin" (riesgo de auto-sabotaje, no solo de terceros).
- No hay métricas de ningún tipo (vistas, clicks a "cómo llegar", eventos por organizador).
- No hay moderación real de reportes (el botón "reportar" del visitante no persiste nada que el admin pueda ver).

---

## 4. Espacio de administración: arquitectura propuesta

**Recomendación: ruta protegida dentro de la SPA actual (no `admin.html` separado), por ahora.**

Por qué:
- El panel ya vive como un `sheet` dentro de `index.html` y reutiliza el mismo cliente de Supabase, las mismas funciones de fetch/auth y el mismo CSS. Separarlo a un archivo nuevo significaría duplicar la inicialización de Supabase, el sistema de toasts, el CSS base, etc. — en un proyecto sin build step, esa duplicación se vuelve deuda real rápido (cualquier cambio de estilo/lógica compartida hay que hacerlo dos veces).
- El volumen de funcionalidad de admin que falta (edición de eventos, búsqueda, métricas) sigue siendo manejable como sheets adicionales dentro del mismo archivo, al menos hasta que el archivo se vuelva difícil de navegar (ver sección 5 sobre cuándo conviene splitear).
- La única razón fuerte para separarlo sería querer una URL distinta (`/admin`) por temas de SEO o de no cargar el bundle del admin para visitantes comunes — pero hoy todo es un solo archivo sin build, así que esa separación de bundle no aplica realmente (el archivo entero se descarga igual).

**Prioridad sugerida para construir el panel real** (de más a menos urgente, pensando en que ya hay una red de organizadores de KON CLUB para poblar de eventos):

1. **Edición de eventos** (no solo borrar) — si KON CLUB va a subir eventos reales, va a haber errores de tipeo/fecha que hoy obligan a borrar y recrear el evento (perdiendo follows/notificaciones ya disparadas).
2. **Buscador/filtro en las listas de admin** — imprescindible apenas haya más de ~20-30 eventos u organizadores.
3. **Confirmación antes de acciones destructivas** (borrar evento, promover a admin) — barata de implementar, evita errores costosos.
4. **Ver email + fecha de creación de cada usuario** — necesario para soporte/moderación real.
5. **Métricas básicas** (eventos activos, vistas si se decide trackearlas, clicks a "cómo llegar") — esto sí es más trabajo (requiere agregar tracking de eventos de analítica que hoy no existe en absoluto) y lo dejaría para después de validar que hay organizadores activos generando contenido.

---

## 5. Arquitectura general y nuevas páginas

### Estado actual
- Un solo archivo de 2974 líneas / ~108KB, sin build step, sin módulos. Todo el JS vive en un único `<script>` con variables globales (`state`, `els`, `map`, `currentUser`, etc.) mutadas directamente por handlers async, sin un dispatcher central.
- **Duplicación real**: la lógica para renderizar una "tarjeta de evento" está reimplementada por separado en al menos 5 lugares (`eventCardHtml()`, el detalle, la franja de "cerca de vos", "mis planes" en la cuenta, y la lista de admin). Cualquier cambio visual al formato de evento exige tocar 5 funciones.
- No hay rutas/URLs propias para nada — toda la navegación es manipulación de `innerHTML` y overlays, no hay `history.pushState` ni deep-linking a un evento específico.

### ¿Sigue siendo sostenible el archivo único?
**Sí, por ahora, con un matiz**: el tamaño (108KB, ~3000 líneas) todavía es manejable para edición manual y no amerita meter un build step todavía — eso traería complejidad (bundler, npm, CI) que hoy no se justifica para el ritmo de cambios. El verdadero problema no es el tamaño del archivo sino la **duplicación de templates de evento**: antes de agregar más superficies que muestren eventos (perfil de organizador, página individual de evento, etc.) convendría extraer esa lógica de render a una sola función reutilizable, aunque siga viviendo en el mismo archivo. Esto es deuda técnica que vale la pena pagar pronto, no por elegancia sino porque cada feature nueva (como el follow) ya tuvo que tocar varios de esos lugares.

### Nuevas páginas con más impacto de negocio (priorizadas)

1. **Página individual de evento con URL propia** (`/evento/:id` o `?evento=id`, aunque sea con `history.pushState` dentro de la misma SPA en vez de un archivo nuevo). Hoy un evento no se puede compartir como link directo navegable — el botón "compartir" copia texto, no un link funcional a una vista pre-cargada de ese evento. Esto es alto impacto: es lo que hace que un organizador de KON CLUB pueda mandar "mirá este plan" por WhatsApp y que quien lo reciba vea directamente el evento, no la home.
2. **Página de perfil de organizador** (`/organizador/:id`), con su lista de eventos pasados/futuros y un botón de seguir — esto le da a cada organizador de KON CLUB un link propio para compartir en sus redes, lo cual ayuda a la adquisición orgánica de usuarios sin que vos tengas que traerlos uno por uno.
3. **SEO en eventos individuales**: si el objetivo es "validar si la falta de información es la barrera real para que la gente salga", que Google indexe eventos individuales (con título/fecha/lugar en meta tags) es la forma más barata de conseguir tráfico no pagado de gente buscando "qué hacer en Palermo esta semana", etc. Esto depende de tener URLs propias por evento primero (punto 1).

No recomendaría separar la landing/mapa/admin en archivos `.html` distintos todavía — el costo de duplicar la inicialización compartida (Supabase, CSS, toasts) supera el beneficio mientras el equipo sea una sola persona editando. Si en el futuro el archivo supera, digamos, 6000-8000 líneas o empieza a haber más de 2-3 personas tocándolo a la vez, ahí sí valdría la pena evaluar un split real (o recién en ese punto, un build step mínimo tipo Vite sin frameworks).

---

## Top 5 — qué arreglaría/agregaría primero

Pensando en que el objetivo es validar si la falta de información es la barrera real para salir más, y que ya hay una red de organizadores (KON CLUB) lista para poblar de eventos:

1. **Edición de eventos en el panel de admin** (hoy solo se puede borrar). Sin esto, cualquier error de tipeo de un organizador real rompe el flujo de confianza del producto.
2. **Página individual de evento con link compartible** (deep link real, no solo texto copiado). Es la pieza que más directamente ayuda a "validar si falta información" — sin un link que funcione, no podés medir si la gente realmente comparte y hace clic en eventos.
3. **Arreglar el geocoding sin timeout/feedback** (1.1) — es el punto más frágil de todo el flujo de publicar un evento, y los organizadores de KON CLUB van a ser justamente quienes más lo usen.
4. **Confirmación antes de borrar eventos/cambiar roles en admin** — barato, evita que un error tuyo (sos el único admin hoy) borre contenido real sin posibilidad de deshacer.
5. **Verificar un dominio propio en Resend** (ya lo discutimos en el chat, no está en este audit de UI pero es bloqueante de producto) — sin esto, ningún usuario real que no sea tu propio email recibe notificaciones, lo cual mata de entrada la hipótesis de "la falta de información es la barrera" porque las alertas no le llegan a nadie más que a vos.

---

Quedo a la espera de tu confirmación antes de abrir cualquier branch o PR con fixes.
