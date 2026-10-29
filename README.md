# Análisis de Cabida

Pantalla de inicio (`index.html`) con provincias y ciudades. Cada ciudad es una página independiente en su carpeta (`cordoba/index.html`, con sus datos en `cordoba/data/`). La cartera es un solo Supabase con la columna `ciudad`.

**Sumar una ciudad:** crear `<ciudad>/index.html` (con `const CIUDAD = '<ciudad>'`) y agregarla en la lista `PROVINCIAS` del `index.html` de inicio. · Córdoba

Herramienta web para analizar lotes de Córdoba capital: normativa urbana, cabida máxima en m² y cartera de lotes de Grupo ECIPSA.

**Sitio:** https://mmmsa221.github.io/AnalisisCabida/ · se entra desde el hall de herramientas https://mmmsa221.github.io/ (repo [mmmsa221/mmmsa221.github.io](https://github.com/mmmsa221/mmmsa221.github.io)).

## Qué hace

- **Lote:** buscás por dirección, nomenclatura (04-02-065-002), cuenta o coordenadas, o tocás el lote en el mapa. La ficha junta ocupación del suelo (Ord. 8256 / 8057 y modificatorias, convenios), uso (8133, 13131), fraccionamiento (8060), centro de manzana, patrimonio, loteos, valores de referencia y todas las ordenanzas que alcanzan al lote.
- **Cabida máxima:** FOS, FOT, alturas, retiros y centro de manzana aplicados a la geometría real del lote, con las reglas generales del texto actualizado de la 8256 (Arts. 7, 9 bis, 16, 24 bis, 26, 33 bis, 34, 35, 36, 40 bis, 42). Todo editable.
- **Ordenanzas:** marco normativo (índice municipal "Ocupación del suelo V8" + Digesto) e índice de todas las normas citadas en las capas oficiales.
- **Cartera:** compartida por quienes tienen la herramienta `cabida`: se guardan los lotes con foto del análisis, estado, precio e incidencia por m², notas, escenarios, mapa, tabla y exportación a Excel. Avisa si la norma cambió desde el análisis.

## Ingreso y permisos

No tiene login propio: usa la sesión única del hall. Quién puede entrar se define por **grupos** en el Supabase de Herramientas (`admin.grupo_miembros`). Ver [docs/ACCESOS.md](https://github.com/mmmsa221/mmmsa221.github.io/blob/main/docs/ACCESOS.md) en el repo del hall.

> `cordoba/index.html` es una versión anterior, **sin control de sesión**, y sigue publicada en `/AnalisisCabida/cordoba/`. La herramienta vigente es `index.html` de la raíz.

## Archivos

| Archivo | Qué es |
|---|---|
| `index.html` | La herramienta vigente: provincias, ciudades y análisis (React 18 UMD + Babel standalone + Leaflet desde CDN, sin build). |
| `cordoba/index.html` | Versión anterior, solo Córdoba. Sin control de sesión. |
| `cordoba/data/digesto.json` | Índice de normas del Digesto municipal (número interno `Nro=`, PDF y marco normativo). |
| `sql/001_inicial.sql` | Esquema del Supabase: cartera de lotes, notas y permisos para la clave anon. Se puede correr dos veces. |
| `.github/workflows/deploy.yml` | Publica en GitHub Pages en cada push a `main`. |

## Datos

- **En vivo, públicos:** capas WFS/WMS de IDECOR (Municipalidad de Córdoba y Catastro provincial), Georef (datos.gob.ar), OpenStreetMap, dólar MEP de dolarapi.com.
- **Cartera:** Supabase de Herramientas de Grupo ECIPSA. Solo la leen y editan los usuarios logueados que tienen `cabida` en sus herramientas. Los lotes se dan de baja con `eliminado = true`.

## Puesta en marcha

1. Supabase → **SQL Editor:** correr `sql/001_inicial.sql`.
2. En `cordoba/index.html`, completar `SB_URL` y `SB_KEY` (Project Settings → API → URL y clave **anon**). Nunca la `service_role`.
3. El ingreso es el del hall (`/sesion.js` + `ECI.exigir('cabida')` en `index.html`). El nombre del autor sale del usuario logueado.

**Recuperar un lote dado de baja (SQL Editor):**
```sql
select id, nombre, updated_at from public.lotes where eliminado order by updated_at desc;
update public.lotes set eliminado = false where id = '...';
```

## Reglas

- Nada de datos de lotes ni de personas en el repo.
- La clave que aparece en `cordoba/index.html` es la pública (anon) de Supabase; la protección la dan las políticas RLS de `sql/001_inicial.sql`.
- Es una estimación preliminar: no reemplaza la visación ni el certificado de uso del suelo.
