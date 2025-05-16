#!/bin/bash

# Comprobación e instalación de dependencias
check_and_install() {
  for pkg in youtube-dl ffmpeg; do
    if ! command -v $pkg &> /dev/null; then
      echo "$pkg no está instalado. Instalando..."
      apt update && apt install -y $pkg
    fi
  done
}

# Ejecutar comprobación e instalación
check_and_install

# Obtener URL del usuario (validar que no esté vacía)
while true; do
  read -p "Introduce la URL del video de YouTube: " URL
  if [[ -z "$URL" ]]; then
    echo "La URL no puede estar vacía. Intenta de nuevo."
  else
    break
  fi
done

# Mostrar formatos disponibles
echo -e "\nObteniendo formatos disponibles...\n"
youtube-dl -F "$URL"

# Pedir formato de vídeo sin audio
read -p "Introduce el código del formato que deseas descargar (vídeo sin audio): " FORMAT

# Borrar archivos previos para no tener conflictos
rm -f video_no_audio.* audio.*

# Descargar vídeo sin audio
echo -e "\nDescargando vídeo sin audio...\n"
youtube-dl -f "$FORMAT" -o "video_no_audio.%(ext)s" "$URL" || { echo "Error en descarga de vídeo"; exit 1; }

# Capturar extensión real del vídeo descargado
VIDEO_FILE=$(ls video_no_audio.* 2>/dev/null | head -n 1)

# Extraer audio mp3
echo -e "\nExtrayendo audio en formato MP3...\n"
youtube-dl --extract-audio --audio-format mp3 -o "audio.%(ext)s" "$URL" || { echo "Error en extracción de audio"; exit 1; }

# Mostrar info final
echo -e "\nInformación del archivo de vídeo ($VIDEO_FILE):\n"
ffmpeg -i "$VIDEO_FILE" -hide_banner

echo -e "\nInformación del archivo de audio (audio.mp3):\n"
ffmpeg -i audio.mp3 -hide_banner
