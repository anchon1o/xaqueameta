# Xaque á meta

Carrera por turnos con piezas de ajedrez, en pixel art medieval. Disponible en gallego, castellano, catalán y euskera.

Es una sola página web (`index.html`), sin dependencias ni servidor: todo el juego, los sprites y las reglas van dentro del archivo.

## Publicarlo en GitHub Pages

1. Entra en [github.com](https://github.com) con tu cuenta.
2. Arriba a la derecha pulsa **+** y luego **New repository**.
3. En **Repository name** escribe `xaque-a-meta`, deja marcado **Public** y pulsa **Create repository**.
4. En la página del repositorio vacío, pulsa el enlace **uploading an existing file**.
5. Descomprime el zip en tu ordenador y arrastra a esa ventana los tres archivos: `index.html`, `README.md` y `.nojekyll`.
   - El archivo `.nojekyll` está oculto en algunos sistemas. Si no lo ves, no pasa nada: el juego funciona igual sin él.
6. Abajo pulsa **Commit changes**.
7. Ve a la pestaña **Settings** del repositorio y, en el menú de la izquierda, entra en **Pages**.
8. En **Source** elige **Deploy from a branch**. En **Branch** elige `main` y la carpeta `/ (root)`, y pulsa **Save**.
9. Espera uno o dos minutos y recarga esa página. Arriba aparecerá la dirección del juego, del tipo:
   `https://TU-USUARIO.github.io/xaque-a-meta/`

## Alternativa: Vercel

1. Sube los archivos a GitHub como en los pasos 1 a 6.
2. Entra en [vercel.com](https://vercel.com), pulsa **Add New…** y luego **Project**.
3. Elige el repositorio `xaque-a-meta` y pulsa **Import**.
4. No cambies nada de la configuración y pulsa **Deploy**.
5. Al terminar tendrás una dirección del tipo `https://xaque-a-meta.vercel.app`.

## Actualizar el juego

Cuando haya una versión nueva de `index.html`:

1. En el repositorio, pulsa sobre `index.html`.
2. Pulsa el icono de los tres puntos (arriba a la derecha del archivo) y luego **Delete file**, y confirma con **Commit changes**.
3. Vuelve a la página principal del repositorio, pulsa **Add file** → **Upload files**, arrastra el `index.html` nuevo y pulsa **Commit changes**.

GitHub Pages y Vercel publican el cambio solos en uno o dos minutos.

## Notas

- La tipografía pixelada se carga de Google Fonts. Sin conexión el juego funciona igual, con una letra de sistema.
- El idioma elegido se guarda en el navegador de cada jugador.
- by ancho
