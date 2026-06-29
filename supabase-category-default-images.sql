-- Actualiza los eventos que todavía tienen la imagen genérica de fallback
-- para que usen la nueva foto default por categoría (ver CATEGORY_FALLBACK_IMG
-- en index.html). Los eventos con una imagen propia no se tocan.

update events set img = 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800&q=72'
  where category = 'cine' and img = 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=72';
update events set img = 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&q=72'
  where category = 'musica' and img = 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=72';
update events set img = 'https://images.unsplash.com/photo-1503095396549-807759245b35?w=800&q=72'
  where category = 'teatro' and img = 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=72';
update events set img = 'https://images.unsplash.com/photo-1531913764164-f85c52e6e654?w=800&q=72'
  where category = 'expo' and img = 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=72';
update events set img = 'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?w=800&q=72'
  where category = 'feria' and img = 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=72';
update events set img = 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=72'
  where category = 'gastro' and img = 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=72';
update events set img = 'https://images.unsplash.com/photo-1452860606245-08befc0ff44b?w=800&q=72'
  where category = 'taller' and img = 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=72';
update events set img = 'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=800&q=72'
  where category = 'charla' and img = 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=72';
update events set img = 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=800&q=72'
  where category = 'lectura' and img = 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=72';
update events set img = 'https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?w=800&q=72'
  where category = 'juegos' and img = 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=72';
update events set img = 'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=800&q=72'
  where category = 'deporte' and img = 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=72';
update events set img = 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800&q=72'
  where category = 'social' and img = 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=72';
