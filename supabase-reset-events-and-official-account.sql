-- 1. Borra todos los eventos de ejemplo/actuales (las interacciones asociadas
--    se borran solas por el "on delete cascade" de la tabla interactions).
delete from events;

-- 2. Convierte tu cuenta actual en la cuenta oficial "Sonda Oficial":
--    organizadora, verificada, con una descripción acorde a la marca.
--    Reemplazá el email si no es el que usás para iniciar sesión.
update profiles
set
  role = 'organizer',
  verified = true,
  first_name = 'Sonda',
  last_name = 'Oficial',
  display_name = 'Sonda Oficial',
  bio = 'La cuenta oficial de Sonda. Acá compartimos los planes que la ciudad nos manda: cine al aire libre, ferias, recitales íntimos, charlas y todo lo que vale la pena no perderse en Buenos Aires.'
where id = (select id from auth.users where email = 'martoknoll@gmail.com');
