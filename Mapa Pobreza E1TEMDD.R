# ---
# TÍTULO: Mapa Temático de Pobreza Extrema por Entidad Federativa (2022)
# DESCRIPCIÓN: Script para cargar, limpiar y visualizar datos de pobreza extrema
#              de CONEVAL 2022 sobre un mapa de México.
# AUTOR: David Gael Osorio Del Olmo
# FECHA: 10/11/2025
# ---

# --- PASO 1: Cargar las librerías necesarias ---
# Necesitaremos 'tidyverse' para manejo de datos y 'ggplot2'
# 'sf' para manejar los datos geoespaciales (shapefiles)
# 'readr' para leer el CSV (parte de tidyverse)
# 'stringr' para limpiar texto (parte de tidyverse)
# 'viridis' para la escala de color perceptual
# 'janitor' para limpiar nombres de columnas
# 'httr' y 'utils' para descargar los archivos

# Usamos install.packages(c("tidyverse", "sf", "viridis", "janitor", "httr"))

library(tidyverse)
library(sf)
library(readr)
library(stringr)
library(viridis)
library(janitor)
library(httr) # Para descargar el archivo de forma robusta
library(readxl)
# --- PASO 2: Cargar y limpiar los datos (Desde el XLSX) ---

# 1. Definimos el nombre de tu archivo de EXCEL
file_pobreza <- "Anexo estadístico 2022.xlsx"

# 2. Leemos el .xlsx
#    Le decimos que lea la HOJA (sheet) "Cuadro 4A"
#    Saltamos 8 filas (títulos) para empezar a leer en la fila 9 (datos)
#    col_names = FALSE para que R no lea los encabezados feos y use ...1, ...2, ...3
datos_pobreza <- read_excel(
  file_pobreza, 
  sheet = "Cuadro 4A",  # <-- Le decimos qué hoja leer
  skip = 8,             # <-- Saltamos las 8 filas de títulos
  col_names = FALSE     # <-- Usamos nombres por defecto
)

# 3. Seleccionamos las columnas por su posición
#    ...3 = Columna 3 (Entidad federativa)
#    ...37 = Columna 37 (Pobreza Extrema -> Porcentaje -> 2022**)
#    (readxl usa '...' para los nombres por defecto)
datos_pobreza_limpio <- datos_pobreza %>%
  select(entidad = ...3, pct_pobreza_extrema = ...37) %>%
  
  # Filtramos filas vacías y el total nacional
  filter(!is.na(pct_pobreza_extrema), entidad != "Estados Unidos Mexicanos") %>%
  
  # Aseguramos que el dato sea numérico
  mutate(pct_pobreza_extrema = as.numeric(pct_pobreza_extrema)) %>%
  
  # --- Llave de Unión (Homologación) ---
  mutate(
    join_key = str_to_lower(entidad),
    join_key = iconv(join_key, from = "latin1", to = "ASCII//TRANSLIT"),
    join_key = str_replace(join_key, "veracruz de ignacio de la llave", "veracruz"),
    join_key = str_replace(join_key, "coahuila de zaragoza", "coahuila"),
    join_key = str_replace(join_key, "michoacan de ocampo", "michoacan"),
    join_key = str_trim(join_key)
  )

# --- PASO 3: Cargar y limpiar el Marco Geoestadístico (INEGI) ---

# Usaremos un shapefile de entidades de INEGI 2022, hospedado por CONABIO.
# Definimos la URL y los nombres de archivo.
url_shapefile <- "http://www.conabio.gob.mx/informacion/gis/maps/geo/dest22gw.zip"
dir_temp <- tempdir() # Carpeta temporal para descargar
zip_file <- file.path(dir_temp, "mexico_entidades.zip")
shp_path <- file.path(dir_temp, "dest22gw.shp") # Nombre del archivo .shp dentro del zip

# Descargamos el archivo ZIP
# Usamos GET de 'httr' y write_disk para guardarlo
GET(url_shapefile, write_disk(zip_file, overwrite = TRUE))

# Descomprimimos el archivo en la carpeta temporal
unzip(zip_file, exdir = dir_temp)

# Leemos el archivo .shp con 'sf'
# st_read es la función clave de 'sf' para leer datos vectoriales
mapa_mx <- st_read(shp_path, quiet = TRUE) %>%
  clean_names() %>% # Limpiamos nombres de columnas (ej. NOM_ENT -> nom_ent)
  
  # --- Llave de Unión (Homologación) ---
  # Creamos la misma "llave" limpia que en los datos de pobreza
  mutate(
    join_key = str_to_lower(nom_ent), # 'nom_ent' es la columna con nombres de estado
    join_key = iconv(join_key, from = "UTF-8", to = "ASCII//TRANSLIT"), # Quitar acentos
    join_key = str_replace(join_key, "distrito federal", "ciudad de mexico"), # Homologar CDMX
    join_key = str_replace(join_key, "veracruz de ignacio de la llave", "veracruz"),
    join_key = str_replace(join_key, "coahuila de zaragoza", "coahuila"),
    join_key = str_replace(join_key, "michoacan de ocampo", "michoacan"),
    join_key = str_trim(join_key)
  )

# --- PASO 4: Unir Datos y Graficar el Mapa ---

# Unimos el mapa (objeto sf) con los datos de pobreza (dataframe)
# Usamos un 'left_join' para mantener todas las geometrías del mapa.
mapa_final_datos <- left_join(mapa_mx, datos_pobreza_limpio, by = "join_key")

# Gráfica empieza aquí 
# Usamos ggplot() + geom_sf() que es la gramática de gráficos para datos 'sf'
ggplot(data = mapa_final_datos) +
  # aes(fill = ...) mapea nuestra variable numérica al color de relleno
  geom_sf(aes(fill = pct_pobreza_extrema), 
          color = "white", # 'color' es el borde de las entidades
          linewidth = 0.1) + # 'linewidth' (en lugar de 'size') para el grosor
  
  # Usamos una escala de color perceptual (Por si hay daltónicos y se vea bien)
  # 'viridis' (opción "magma").
  # direction = -1 invierte la escala para que más oscuro = más pobreza
  scale_fill_viridis_c(
    option = "magma", 
    direction = -1,
    name = "Porcentaje (%)",
    guide = guide_colorbar(
      title.position = "top",
      title.hjust = 0.5,
      barwidth = unit(0.5, 'cm'),
      barheight = unit(10, 'cm')
    )
  ) +
  
  # Agregamos Títulos y Fuentes (según las instrucciones)
  labs(
    title = "Pobreza Extrema en México por Entidad Federativa (2022)",
    subtitle = "Porcentaje de la población en situación de pobreza extrema",
    caption = "Fuente: Estimaciones del CONEVAL con base en la ENIGH 2022 (INEGI).\nMarco Geoestadístico: INEGI (2022) vía CONABIO."
  ) +
  
  # Usamos un tema limpio, sin ejes (lat/lon)
  theme_void() +
  
  # Ajustes finales a la posición de los textos
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    plot.caption = element_text(hjust = 0, size = 9, color = "grey30"),
    legend.position = "right",
    legend.title = element_text(size = 10)
  )

