# Cómo activar las alertas por mail y el resumen semanal

Esto tiene varias partes porque Supabase no manda mails por su cuenta: hace falta un
servicio de email (Resend), dos Edge Functions, y conectar todo con SQL.

## 1. Crear cuenta en Resend

1. Entrá a https://resend.com y creá una cuenta gratis.
2. En **API Keys**, creá una key nueva y copiala (la vas a necesitar en el paso 3).
3. (Opcional pero recomendado) Verificá un dominio propio en **Domains** para mandar desde
   tu propio email en vez de `onboarding@resend.dev`. Si no tenés dominio, podés arrancar
   con el dominio de prueba de Resend.

## 2. Instalar la CLI de Supabase y loguearte

```bash
npm install -g supabase
supabase login
supabase link --project-ref <PROJECT_REF>
```

`<PROJECT_REF>` es el ID de tu proyecto, lo encontrás en la URL del dashboard
(`https://supabase.com/dashboard/project/<PROJECT_REF>`).

## 3. Configurar los secrets de las funciones

```bash
supabase secrets set RESEND_API_KEY=tu_api_key_de_resend
supabase secrets set NOTIFY_FROM_EMAIL="Sonda <onboarding@resend.dev>"
supabase secrets set APP_URL=https://tu-url-de-la-app
```

## 4. Desplegar las dos Edge Functions

Ya están en el repo en `supabase/functions/notify-new-event` y `supabase/functions/weekly-digest`.

```bash
supabase functions deploy notify-new-event --no-verify-jwt
supabase functions deploy weekly-digest --no-verify-jwt
```

`--no-verify-jwt` es necesario porque las llama directamente la base de datos
(con la service role key como autenticación propia, ver siguiente paso), no un usuario logueado.

## 5. Conectar la base de datos con las funciones

1. Copiá tu **service role key** desde el dashboard de Supabase: **Settings → API → service_role**.
   Es secreta, nunca la subas a un repositorio.
2. Abrí `supabase-email-notifications.sql` (en la raíz del repo), reemplazá `<PROJECT_REF>` y
   `<SERVICE_ROLE_KEY>` por los valores reales en una copia local (no la subas con los valores reales).
3. Corré el script completo en el SQL Editor de Supabase.

Con esto:
- Cada vez que se inserta un evento nuevo, se llama a `notify-new-event`, que les manda un mail
  a todos los que siguen a ese organizador.
- Todos los lunes a las 9am (hora Argentina) se llama a `weekly-digest`, que le manda a cada
  usuario un resumen de los eventos de la semana de la gente que sigue, más hasta 3 recomendados
  según sus categorías favoritas.

## 6. Probar

- Publicá un evento con una cuenta organizadora y fijate que le llegue el mail a alguien que la sigue.
- Para probar el resumen semanal sin esperar al lunes, podés invocar la función a mano:
  ```bash
  supabase functions invoke weekly-digest
  ```
