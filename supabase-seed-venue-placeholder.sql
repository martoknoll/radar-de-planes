-- Cuenta placeholder de un espacio cultural: "La Usina Cultural"
-- Correlo en el SQL editor de Supabase.
-- Crea el usuario auth, el perfil de organizador verificado, la dirección del espacio y 5 eventos.

do $$
declare
  venue_user_id uuid := gen_random_uuid();
begin

  -- 1. Crear usuario en auth.users
  insert into auth.users (
    id, instance_id, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    raw_app_meta_data, raw_user_meta_data,
    is_super_admin, role, aud
  ) values (
    venue_user_id,
    '00000000-0000-0000-0000-000000000000',
    'lusinacultural@sonda.app',
    crypt('Sonda2026!', gen_salt('bf')),
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}',
    '{}',
    false, 'authenticated', 'authenticated'
  );

  -- 2. Crear/actualizar perfil como organizador verificado con dirección del espacio
  insert into profiles (
    id, display_name, first_name, last_name, username,
    role, verified,
    bio,
    venue_address, venue_lat, venue_lng
  ) values (
    venue_user_id,
    'La Usina Cultural',
    'La Usina', 'Cultural',
    'lusinacultural',
    'organizer', true,
    'Espacio cultural independiente en Villa Crespo. Música, teatro, talleres y más.',
    'Av. Corrientes 5234, Villa Crespo, CABA',
    -34.5997,
    -58.4430
  )
  on conflict (id) do update set
    display_name   = excluded.display_name,
    first_name     = excluded.first_name,
    last_name      = excluded.last_name,
    username       = excluded.username,
    role           = excluded.role,
    verified       = excluded.verified,
    bio            = excluded.bio,
    venue_address  = excluded.venue_address,
    venue_lat      = excluded.venue_lat,
    venue_lng      = excluded.venue_lng;

  -- 3. Crear eventos bajo esa cuenta
  insert into events (title, category, price, date, time, address, organizer, description, img, lat, lng, created_by) values

    (
      'Jazz en vivo: Trío Baudelaire',
      'musica',
      '$3.500',
      '2026-07-03',
      '21:00',
      'Av. Corrientes 5234, Villa Crespo',
      'La Usina Cultural',
      'Una noche de jazz íntimo con el Trío Baudelaire. Reserva de lugar recomendada.',
      'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&q=72',
      -34.5997, -58.4430,
      venue_user_id
    ),

    (
      'Taller de cerámica para principiantes',
      'taller',
      '$5.000',
      '2026-07-05',
      '11:00',
      'Av. Corrientes 5234, Villa Crespo',
      'La Usina Cultural',
      'Aprendé las técnicas básicas de modelado en arcilla. Incluye materiales. Cupos limitados a 10 personas.',
      'https://images.unsplash.com/photo-1452860606245-08befc0ff44b?w=800&q=72',
      -34.5997, -58.4430,
      venue_user_id
    ),

    (
      'Obra de teatro: "Las paredes hablan"',
      'teatro',
      '$2.500',
      '2026-07-04',
      '20:30',
      'Av. Corrientes 5234, Villa Crespo',
      'La Usina Cultural',
      'Obra de teatro independiente del colectivo Escena Abierta. Dramaturgia de Paula Soria.',
      'https://images.unsplash.com/photo-1503095396549-807759245b35?w=800&q=72',
      -34.5997, -58.4430,
      venue_user_id
    ),

    (
      'Feria de diseño y arte local',
      'feria',
      'Gratis',
      '2026-07-05',
      '14:00',
      'Av. Corrientes 5234, Villa Crespo',
      'La Usina Cultural',
      'Más de 20 diseñadores y artistas locales presentan sus trabajos. Entrada libre y gratuita.',
      'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?w=800&q=72',
      -34.5997, -58.4430,
      venue_user_id
    ),

    (
      'Charla: Economía creativa y espacios culturales',
      'charla',
      'Gratis',
      '2026-07-03',
      '18:00',
      'Av. Corrientes 5234, Villa Crespo',
      'La Usina Cultural',
      'Panel con gestores culturales sobre el modelo de espacios independientes en Buenos Aires. Abierto a todo público.',
      'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=800&q=72',
      -34.5997, -58.4430,
      venue_user_id
    );

end $$;
