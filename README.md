# Análisis de Cabida · Córdoba

Herramienta web para analizar lotes de Córdoba capital: normativa urbana, cabida máxima en m² y cartera de lotes de Grupo ECIPSA.

**Sitio:** _(completar con la URL nueva)_

## Qué hace

- **Lote:** buscás por dirección, nomenclatura (04-02-065-002), cuenta o coordenadas, o tocás el lote en el mapa. La ficha junta ocupación del suelo (Ord. 8256 / 8057 y modificatorias, convenios), uso (8133, 13131), fraccionamiento (8060), centro de manzana, patrimonio, loteos, valores de referencia y todas las ordenanzas que alcanzan al lote.
- **Cabida máxima:** FOS, FOT, alturas, retiros y centro de manzana aplicados a la geometría real del lote, con las reglas generales del texto actualizado de la 8256 (Arts. 7, 9 bis, 16, 24 bis, 26, 33 bis, 34, 35, 36, 40 bis, 42). Todo editable.
- **Ordenanzas:** marco normativo (índice municipal "Ocupación del suelo V8" + Digesto) e índice de todas las normas citadas en las capas oficiales.
- **Cartera:** sin login, compartida por todo el equipo: se guardan los lotes con foto del análisis, estado, precio e incidencia por m², notas, escenarios, mapa, tabla y exportación a Excel. Avisa si la norma cambió desde el análisis.

## Archivos

| Archivo | Qué es |
|---|---|
| `index.html` | La herramienta entera (React 18 UMD + Babel standalone + Leaflet desde CDN, sin build). |
| `data/digesto.json` | Índice de normas del Digesto municipal (número interno `Nro=`, PDF y marco normativo). |
| `sql/001_inicial.sql` | Esquema del Supabase: cartera de lotes, notas y permisos para la clave anon. Se puede correr dos veces. |
| `.github/workflows/deploy.yml` | Publica en GitHub Pages en cada push a `main`. |

## Datos

- **En vivo, públicos:** capas WFS/WMS de IDECOR (Municipalidad de Córdoba y Catastro provincial), Georef (datos.gob.ar), OpenStreetMap, dólar MEP de dolarapi.com.
- **Cartera, abierta:** Supabase de Grupo ECIPSA, sin login. **Quien tenga la URL del sitio puede ver y editar la cartera** (precios y notas incluidos). La base no permite borrar: los lotes se dan de baja con `eliminado = true` y las notas son solo de alta.

## Puesta en marcha

1. Supabase → **SQL Editor:** correr `sql/001_inicial.sql`.
2. En `index.html`, completar `SB_URL` y `SB_KEY` (Project Settings → API → URL y clave **anon**). Nunca la `service_role`.
3. Cada persona pone su nombre arriba a la derecha (queda en su navegador) y se usa como autor de lo que carga.

**Recuperar un lote dado de baja (SQL Editor):**
```sql
select id, nombre, updated_at from public.lotes where eliminado order by updated_at desc;
update public.lotes set eliminado = false where id = '...';
```

## Reglas

- Nada de datos de lotes ni de personas en el repo.
- La clave que aparece en `index.html` es la pública (anon) de Supabase; la protección la dan las políticas RLS de `sql/001_inicial.sql`.
- Es una estimación preliminar: no reemplaza la visación ni el certificado de uso del suelo.
