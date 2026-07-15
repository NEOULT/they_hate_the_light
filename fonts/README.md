# Fuentes Pixel Art para el Botón

## Opciones de Fuentes para Probar

### 1. Not Jam Sci Mono 10

- **URL:** https://not-jam.itch.io/not-jam-sci-mono-10
- **Estilo:** Monospace sci-fi, estructura blocky
- **Licencia:** CC0 (gratis para uso comercial)
- **Tamaño:** 10px

### 2. BoldPixels

- **URL:** https://yukipixels.itch.io/boldpixels
- **Estilo:** Bold y blocky, ideal para botones
- **Licencia:** Gratis
- **Tamaño:** 16px

### 3. Terminal Square

- **URL:** https://bragorn.itch.io/terminal-square-pixel-font
- **Estilo:** Terminal robótico, cuadrada y blocky
- **Licencia:** Gratis
- **Tamaño:** Variable

### 4. Silver

- **URL:** https://poppyworks.itch.io/silver
- **Estilo:** Retro pixel, soporte multilenguaje
- **Licencia:** Gratis (name your own price)
- **Tamaño:** Variable

## Instrucciones de Importación en Godot

1. **Descargar** la fuente que quieras probar (formato .ttf o .otf)
2. **Arrastrar** el archivo a la carpeta `fonts/` en Godot
3. **Seleccionar** el nodo Label "Texto" en button.tscn
4. En el Inspector, ir a **Theme Overrides > Fonts**
5. **Arrastrar** el archivo de fuente al campo de fuente
6. Ajustar **Theme Overrides > Font Sizes** a 72 (o el tamaño deseado)

## Configuración Importante para Pixel Art

En **Project Settings > Rendering > Textures > Canvas Textures > Default Texture Filter**:

- Cambiar a **Nearest** para que las fuentes pixel art se vean nítidas

## Probar las Fuentes

Para probar cada fuente, simplemente cambia el campo de fuente en el Inspector del nodo Label "Texto".
